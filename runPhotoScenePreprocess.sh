#!/bin/sh

preprocessRoot="/eccv20dataset/yyeh/material-preprocess"
orSnRoot="/eccv20dataset/yyeh/OpenRoomScanNetView"
condaRoot="/eccv20dataset/yyeh/miniconda3/etc/profile.d/conda.sh"
sceneId=$1
scene="scene$sceneId"
gpuId=0
withMatLabel=${2:-false}
isDebug=${3:-false}

# >>> Environment
apt-get update
apt-get -y install libopencv-dev
. $condaRoot
conda activate pytorch-py37
# <<< Environment

cd $preprocessRoot
# Extract ScanNet
python script_extractScanNet.py --sceneId $sceneId --machine cluster

# Preprocess: render openrooms, sample view
python script_preprocess.py --sceneId $sceneId --machine cluster

# Run inverse renering net
bash script_runInvRender.sh $sceneId $gpuId "cluster"

##### Unknown reason above cannot use job to run, use bash script_runInvRenderMulti.sh to process

# Preprocess2: consensus aware view selection, save warped mask and other labels
if [ "$isDebug" = true ] ; then
    python script_preprocess2.py --sceneId $sceneId --machine cluster --renderDefault --renderWhite
    graphDictFile="$orSnRoot/$scene/selectedGraphDict_random.txt"
else
    # don't need to render default if not for debug
    python script_preprocess2.py --sceneId $sceneId --machine cluster
    graphDictFile="$orSnRoot/$scene/selectedGraphDict.txt"
fi

# Graph Classification: to get selectedGraphDict.txt
if [ ! -s $graphDictFile ]
then
    if [[ "$isDebug" = false ]] && [[ "$withMatLabel" = false ]] ; then
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

