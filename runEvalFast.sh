#!/bin/sh

pip3 install tqdm ipython opencv-python==3.4.2.17 tensorboard==1.15.0
pip3 install torch --upgrade
cd /eccv20dataset/adobe_svbrdf-master
python3 script_evalEncoder.py --sceneId $1 --rgbMode im --isFast
#python3 script_evalEncoder.py --sceneId $1 --rgbMode imscannet --isFast
python3 script_evalEncoder.py --sceneId $1 --rgbMode imscannet --maskMode mmap --isFast
python3 script_evalW.py --sceneId $1 --rgbMode im --isFast
#python3 script_evalW.py --sceneId $1 --rgbMode imscannet --isFast
python3 script_evalW.py --sceneId $1 --rgbMode imscannet --maskMode mmap --isFast
