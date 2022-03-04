# 网上教程 https://blog.csdn.net/linxinloningg/article/details/122525742

# Install cuda10.0 by runfile
wget https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux
sudo sh cuda_10.0.130_410.48_linux
echo export PATH=$PATH:/usr/local/cuda-10.0/bin >> ~/.zshrc
echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.0/lib64 >> ~/.zshrc
echo export CUDA_HOME=$CUDA_HOME:/usr/local/cuda-10.0 >> ~/.zshrc
source ~/.zshrc
rm -rf /usr/local/cuda-10.1

# Install cudnn7.6.5 by tar
wget https://minio.cvmart.net/user-file/24466/0151ae98cd7b430ebad6108f4501cd7f.tgz
tar -xvf 0151ae98cd7b430ebad6108f4501cd7f.tgz
sudo cp cuda/include/cudnn*.h /usr/local/cuda-10.0/include/ 
sudo cp cuda/lib64/libcudnn* /usr/local/cuda-10.0/lib64/
sudo chmod a+r /usr/local/cuda-10.0/include/cudnn*.h /usr/local/cuda-10.0/lib64/libcudnn*

# Install opencv3.4.16
wget https://minio.cvmart.net/user-file/24466/31c66879e16d4ebb95585a4591cca760.zip
unzip 31c66879e16d4ebb95585a4591cca760.zip
cd opencv-3.4.16
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local  ..
make -j8
sudo make install

# Install tensorrt7.0.0.11
wget https://minio.cvmart.net/user-file/24466/97ef25d5664842aeb06a7f5226851348.gz
tar -xvf 97ef25d5664842aeb06a7f5226851348.gz
echo "export LD_LIBRARY_PATH=/project/train/src_repo/TensorRT-7.0.0.11/lib:/project/train/src_repo/TensorRT-7.0.0.11/targets/x86_64-linux-gnu/lib:$LD_LIBRARY_PATH"  >> ~/.zshrc
source ~/.zshrc
cd TensorRT-7.0.0.11/python 
pip install tensorrt-7.0.0.11-cp36-none-linux_x86_64.whl 
cd ../../TensorRT-7.0.0.11/uff 
pip install uff-0.6.5-py2.py3-none-any.whl
cd ../graphsurgeon 
pip install graphsurgeon-0.4.1-py2.py3-none-any.whl

# Run tensorrtx

# Generate .wts from pytorch with .pt,
cd /project/train/src_repo
git clone -b v6.0 https://github.com/ultralytics/yolov5.git
# git clone https://github.com/ultralytics/yolov5.git
git clone https://github.com/wang-xinyu/tensorrtx.git
cd /project/train/src_repo/yolov5
wget https://github.com/ultralytics/yolov5/releases/download/v6.0/yolov5s.pt
# wget https://github.com/ultralytics/yolov5/releases/download/v6.1/yolov5s.pt
pip install -r requirements.txt
cp /project/train/src_repo/tensorrtx/yolov5/gen_wts.py /project/train/src_repo/yolov5
python gen_wts.py -w yolov5s.pt -o yolov5s.wts

#build tensorrtx/yolov5 and run
cd /project/train/src_repo/tensorrtx/yolov5
mkdir build
cd /project/train/src_repo/tensorrtx/yolov5/build
cp /project/train/src_repo/yolov5/yolov5s.wts /project/train/src_repo/tensorrtx/yolov5/build/
cmake ..
make
sudo ./yolov5 -s yolov5s.wts yolov5s.engine s
sudo ./yolov5 -d yolov5s.engine ../samples

# solve can not find .lib 
'''sudo cp /usr/local/cuda-10.0/lib64/libcublas.so.10.0  /usr/local/lib/libcublas.so.10.0 && sudo ldconfigsudo 
cp /usr/local/cuda-10.0/lib64/libcudart.so.10.0 /usr/local/lib/libcudart.so.10.0 && sudo ldconfig
cp /project/train/src_repo/TensorRT-7.0.0.11/targets/x86_64-linux-gnu/lib/libnvinfer.so.7 /usr/local/lib/libnvinfer.so.7 && sudo ldconfig
cp /project/train/src_repo/TensorRT-7.0.0.11/targets/x86_64-linux-gnu/lib/libmyelin.so.1 /usr/local/lib/libmyelin.so.1 && sudo ldconfig
cp /usr/local/cuda-10.0/lib64/libnvrtc.so.10.0 /usr/local/lib/libnvrtc.so.10.0 && sudo ldconfig
cp -r /project/train/src_repo/TensorRT-7.0.0.11/targets/x86_64-linux-gnu/lib/* /usr/local/lib && sudo ldconfig'''