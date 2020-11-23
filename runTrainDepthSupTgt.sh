#!/bin/sh

pip3 install dominate visdom opencv-python==3.4.2.17
cd /eccv20dataset/yyeh/Synthetic2Realistic
python3 script_trainSupTgtOnly.py
