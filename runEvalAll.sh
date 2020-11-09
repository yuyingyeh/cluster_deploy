#!/bin/sh

pip3 install tqdm ipython opencv-python==3.4.2.17 tensorboard==1.15.0
pip3 install torch --upgrade
cd /eccv20dataset/adobe_svbrdf-master
python3 script_evalEncoder.py --sceneId 0001_00 --rgbMode im
python3 script_evalEncoder.py --sceneId 0001_00 --rgbMode imscannet
python3 script_evalEncoder.py --sceneId 0028_00 --rgbMode im
python3 script_evalEncoder.py --sceneId 0028_00 --rgbMode imscannet
python3 script_evalW.py --sceneId 0001_00 --rgbMode im
python3 script_evalW.py --sceneId 0001_00 --rgbMode imscannet
python3 script_evalW.py --sceneId 0028_00 --rgbMode im
python3 script_evalW.py --sceneId 0028_00 --rgbMode imscannet
