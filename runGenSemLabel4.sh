#!/bin/sh

pip3 install tqdm opencv-python==3.4.2.17
cd /siggraphasia20dataset/code/Routine/DatasetCreation/material
python3 genSemanticLabel4.py --dirId $1 --phase $2 --sceneSplit $3
