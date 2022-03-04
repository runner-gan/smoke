#!/bin/bash
# 创建默认目录，训练过程中生成的模型文件、日志、图必须保存在这些固定目录下，训练完成后这些文件将被保存
rm -rf /project/train/models/result-graphs && rm -rf /project/train/log
mkdir -p /project/train/result-graphs && mkdir -p /project/train/log

project_root_dir=/project/train/src_repo
dataset_dir=/home/data
log_file=/project/train/log/log.txt
# -z判断变量值是否为空,fi为if语句的结束,相当于end if 
if [ ! -z $1 ]; then
    num_train_steps=$1
else
    num_train_steps=300
fi

if [ ! -z $2 ]; then
    batch_size=$2
else
    batch_size=16
fi

if [ ! -z $3 ]; then
    workers=$3
else
    workers=2
fi

echo "Spliting dataset..." \
&& python -u ${project_root_dir}/yolov5/utils/split_train_val.py | tee -a ${log_file}
echo "Converting dataset..." \
&& python3 -u ${project_root_dir}/yolov5/utils/xml_to_txt.py | tee -a ${log_file} \
&& cd ${project_root_dir}  \
&& echo "Start training..." \
&& cd yolov5 && python3 -u train.py --hyp /project/train/src_repo/yolov5/data/hyps/smoke.yaml --resume /project/train/models/exp/weights/last.pt --data /project/train/src_repo/yolov5/data/smoke.yaml --project /project/train/models  --batch-size ${batch_size} --epochs ${num_train_steps} --workers ${workers} 2>&1 | tee -a ${log_file} \
&& echo "Done!!!" \
&& echo "Copy result images to /project/train/result-graphs ..." \
&& cp /project/train/models/exp/*.jpg /project/train/models/exp/*.png /project/train/result-graphs | tee -a ${log_file} \
&& echo "Finished!!!"
