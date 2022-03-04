import json
import torch
import sys
import numpy as np
from pathlib import Path
import cv2
from ensemble_boxes import weighted_boxes_fusion

from models.experimental import attempt_load
from utils.torch_utils import select_device
from utils.general import check_img_size, non_max_suppression, scale_coords
from utils.augmentations import letterbox

# scale_coords:# Rescale coords (xyxy) from img1_shape to img0_shape
# letterbox: # Resize and pad image while meeting stride-multiple constraints


model_path = r"/project/train/models/exp/weights/best.pt"

@torch.no_grad()
def init():
    weights = model_path
    device = 'cuda:0'  # cuda device, i.e. 0 or 0,1,2,3 or

    half = True  # use FP16 half-precision inference
    device = select_device(device)
    w = str(weights[0] if isinstance(weights, list) else weights)
    model = torch.jit.load(w) if 'torchscript' in w else attempt_load(weights, map_location=device)
    if half:
        model.half()  # to FP16
    model.eval()
    return model


def process_image(handle=None, input_image=None, args=None, **kwargs):
    device = 'cuda:0'  # cuda device, i.e. 0 or 0,1,2,3 or
    half = True  # use FP16 half-precision inference
    conf_thres = 0.5  # confidence threshold
    iou_thres = 0.5  # NMS IOU threshold

    max_det = 1000  # maximum detections per image
    imgsz = [640, 640]
    names = {0 : 'smoke', 1:'fire'}

    stride = 32
    fake_result = {}
    fake_result["algorithm_data"] = {
        "is_alert": False,
        "target_count": 0,
        "target_info": []
    }
    fake_result["model_data"] = {
        "objects": []
    }
    img = letterbox(input_image, imgsz, stride, True)[0]
    img = img.transpose((2, 0, 1))[::-1]  # HWC to CHW, BGR to RGB
    img= img.copy()
    img = torch.from_numpy(img)
    img = img.half() if half else img.float()  # uint8 to fp16/32
    img /= 255.0  # 0 - 255 to 0.0 - 1.0
    img = img.unsqueeze(0)
    img = img.to(device)
    pred = handle(img, augment=False, visualize=False)[0]

    pred = non_max_suppression(pred, conf_thres, iou_thres, None, False, max_det=max_det)

    for i, det in enumerate(pred):  # per image
        det[:, :4] = scale_coords(img.shape[2:], det[:, :4], input_image.shape).round()
        for *xyxy, conf, cls in reversed(det):
            xyxy_list = torch.tensor(xyxy).view(1, 4).view(-1).tolist()
            conf_list = conf.tolist()
            label = names[int(cls)]
            fake_result['model_data']['objects'].append({
                "xmin": int(xyxy_list[0]),
                "ymin": int(xyxy_list[1]),
                "xmax": int(xyxy_list[2]),
                "ymax": int(xyxy_list[3]),
                "confidence": conf_list,
                "name": label
            })
    fake_result['algorithm_data']['is_alert'] = True if len(fake_result['algorithm_data']['target_info']) > 0 else False
    fake_result['algorithm_data']["target_count"] = len(fake_result['algorithm_data']['target_info'])
    fake_result['algorithm_data']['target_info'] = fake_result['model_data']['objects']

    return json.dumps(fake_result, indent=4)

if __name__ == "__main__":
    handle = init()
    img = cv2.imread(r"/home/data/664/smoke_nature_mountain_multiplex_sample_set_p_day_20220113_86.jpg")
    process_image(handle=handle, input_image=img)