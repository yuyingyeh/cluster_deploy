#!/bin/sh

pip3 install tqdm ipython
pip3 install torch --upgrade
cd /siggraphasia20dataset/adobe_svbrdf-master
python3 script_optimGANdatasetAllclusterWfixN.py --start $1 --end $2
