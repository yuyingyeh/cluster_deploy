#!/bin/sh

apt-get update
apt-get -y install libopencv-dev
cd /siggraphasia20dataset/code/Routine/DatasetCreation/material
python renderImgMatPred.py --sceneId 0001_00 --rgbMode im --matMode cs
python renderImgMatPred.py --sceneId 0001_00 --rgbMode imscannet --matMode cs
python renderImgMatPred.py --sceneId 0028_00 --rgbMode im --matMode cs
python renderImgMatPred.py --sceneId 0028_00 --rgbMode imscannet --matMode cs
python renderImgMatPred.py --sceneId 0001_00 --rgbMode im --matMode w
python renderImgMatPred.py --sceneId 0001_00 --rgbMode imscannet --matMode w
python renderImgMatPred.py --sceneId 0028_00 --rgbMode im --matMode w
python renderImgMatPred.py --sceneId 0028_00 --rgbMode imscannet --matMode w
