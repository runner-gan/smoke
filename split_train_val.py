# ----------------------------------------------------------------------#
#   创建图片、标签、索引文件夹
#   
# ----------------------------------------------------------------------#

import os
import random
import shutil
from shutil import copyfile

random.seed(0)

xmlfilepath = '/home/data/664/'

saveBasePath = "/home/data/664/ImageSets/Main"
tr_imgfilepath = '/home/data/664/images/train/'
v_imgfilepath = '/home/data/664/images/val/'
t_imgfilepath = '/home/data/664/images/test/'
tr_labelfilepath = '/home/data/664/labels/train/'
v_labelfilepath = '/home/data/664/labels/val/'
t_labelfilepath = '/home/data/664/labels/test/'

file_list = [saveBasePath,tr_imgfilepath,v_imgfilepath,t_imgfilepath,tr_labelfilepath,v_labelfilepath,t_labelfilepath]

for _ in file_list:
    if os.path.exists(_):
        shutil.rmtree(_)
        os.makedirs(_)
        print("create %s"%_)
    else:
        os.makedirs(_)

# ----------------------------------------------------------------------#
#   想要增加测试集修改trainval_percent
#   train_percent不需要修改
# ----------------------------------------------------------------------#
trainval_percent = 1
train_percent = 0.8

temp_xml = os.listdir(xmlfilepath)
total_xml = []
for xml in temp_xml:
    if xml.endswith(".xml"):
        total_xml.append(xml)

num = len(total_xml)
list = range(num)
tv = int(num * trainval_percent)
tr = int(tv * train_percent)
random.seed(1)
trainval = random.sample(list, tv)
train = random.sample(trainval, tr)

print("imageset size:",num)
print("train and val size:", tv)
print("train size:", tr)
print("val size:",tv - tr)
print("test size:",num - tv)

ftrainval = open(os.path.join(saveBasePath, 'trainval.txt'), 'w')#os.path.join可以根据系统自动选择目录之间的分隔符/或者\
ftest = open(os.path.join(saveBasePath, 'test.txt'), 'w')
ftrain = open(os.path.join(saveBasePath, 'train.txt'), 'w')
fval = open(os.path.join(saveBasePath, 'val.txt'), 'w')

for i in list:
    name = total_xml[i][:-4]
    if i  in trainval:
        ftrainval.write(name + '\n')
        if i in train:
            ftrain.write(name + '\n')
            copyfile(xmlfilepath + name + '.jpg',tr_imgfilepath+name + '.jpg')
        else:
            fval.write(name + '\n')
            copyfile(xmlfilepath + name + '.jpg',v_imgfilepath+name + '.jpg')
    else:
        ftest.write(name + '\n')
        copyfile(xmlfilepath + name + '.jpg',t_imgfilepath+name + '.jpg')

ftrainval.close()
ftrain.close()
fval.close()
ftest.close()