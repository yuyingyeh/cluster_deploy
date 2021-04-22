#!/bin/sh

pip install opencv-python==3.4.2.17
pip install joblib
pip install imageio==2.6

cd /eccv20dataset/yyeh/material-preprocess
python script_extractScanNet.py --sceneId $1 --machine cluster

pip3 install tqdm
pip3 install scikit-learn
pip3 install opencv-python==3.4.2.17

python script_preprocess.py --sceneId $1 --machine cluster
bash script_runInvRender.sh $1 0 "cluster"

pip3 install torch --upgrade
python script_preprocess2.py --sceneId $1 --machine cluster --renderDefault --renderWhite
