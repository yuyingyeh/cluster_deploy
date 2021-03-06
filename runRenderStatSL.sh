#!/bin/sh

apt-get update
apt-get -y install libopencv-dev
pip3 install tqdm opencv-python==3.4.2.17
mkdir -p /eccv20dataset/yyeh/OpenRoomScanNetView/scene$1/renderUVSL
cd /eccv20dataset/yyeh/OpenRoomScanNetView/scene$1/renderUVSL
python renderImgMappedSL.py --sceneId $1 --task $2 --vId $3 --lightName $4

#python3 fromHDRtoLDR.py --sceneId $1 --rgbMode $2 --matMode $3 --maskMode mmap
