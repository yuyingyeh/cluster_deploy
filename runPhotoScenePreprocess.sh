#!/bin/sh

preprocessRoot="/eccv20dataset/yyeh/material-preprocess"
orSnRoot="/eccv20dataset/yyeh/OpenRoomScanNetView"
sceneId=$1
scene="scene$sceneId"
gpuId=0
isDebug=${2:-false}

pip install opencv-python==3.4.2.17
pip install joblib
pip install imageio==2.6

cd $preprocessRoot
python script_extractScanNet.py --sceneId $sceneId --machine cluster

pip3 install tqdm
pip3 install scikit-learn
pip3 install opencv-python==3.4.2.17
apt-get update
apt-get -y install libopencv-dev

python script_preprocess.py --sceneId $sceneId --machine cluster
bash script_runInvRender.sh $sceneId $gpuId "cluster"

pip3 install torch --upgrade
if [ "$isDebug" = true ] ; then
    python script_preprocess2.py --sceneId $sceneId --machine cluster --renderDefault --renderWhite
    graphDictFile="$orSnRoot/$scene/selectedGraphDict_random.txt"
else
    # don't need to render default if not for debug
    python script_preprocess2.py --sceneId $sceneId --machine cluster --renderWhite
    graphDictFile="$orSnRoot/$scene/selectedGraphDict.txt"
fi

# Need to first get selectedGraphDict.txt
# Graph Classification
if [ ! -s $graphDictFile ]
then
    if [ "$isDebug" = false ] ; then
        ##### vvv skip here if debug vvv #####
        cd $preprocessRoot
        python genMatClsList.py --sceneId $sceneId --machine cluster
        cd $preprocessRoot
        bash script_runMaterialClassifier.sh $sceneId $gpuId cluster
        ##### ^^^ skip here if debug ^^^ #####
    fi
    cd $preprocessRoot
    bash script_runGraphClassifier.sh $sceneId $gpuId cluster
    echo "New graph dict saved at $graphDictFile !"
else
    echo "$graphDictFile exists! Skip!"
fi
cd $preprocessRoot

if [ "$isDebug" = true ] ; then
    python script_preprocess2.py --sceneId $1 --machine cluster --renderAssignedMatch --renderAssignedGan
fi

