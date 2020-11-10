#!/bin/sh

apt-get update
apt-get -y install libopencv-dev
cd /siggraphasia20dataset/code/Routine/DatasetCreation/material
python renderImgSN.py --sceneId $1 --forceOutput
pip3 install tqdm opencv-python==3.4.2.17
python3 fromHDRtoLDR.py --sceneId $1 --rgbMode imscannet --matMode _
