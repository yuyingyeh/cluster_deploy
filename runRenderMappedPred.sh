#!/bin/sh

apt-get update
apt-get -y install libopencv-dev
cd /siggraphasia20dataset/code/Routine/DatasetCreation/material
python renderImgMatPred.py --sceneId $1 --rgbMode $2 --matMode $3 --maskMode mmap --forceOutput
pip3 install tqdm opencv-python==3.4.2.17
python3 fromHDRtoLDR.py --sceneId $1 --rgbMode $2 --matMode $3 --maskMode mmap
