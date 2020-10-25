#!/bin/sh

pip3 install tqdm ipython opencv-python==3.4.2.17 tensorboard==1.15.0
pip3 install torch --upgrade
cd /siggraphasia20dataset/adobe_svbrdf-master
python3 script_trainEncoder.py --classW $1 --scaleW $2
