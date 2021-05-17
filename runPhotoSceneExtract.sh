#!/bin/sh

pip install opencv-python==3.4.2.17
pip install joblib
pip install imageio==2.6

cd /eccv20dataset/yyeh/material-preprocess
python script_extractScanNet.py --sceneId $1 --machine cluster


