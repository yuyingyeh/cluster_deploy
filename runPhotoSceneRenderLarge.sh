#!/bin/bash
sceneId=$1
gpuId=0
modeName="${2:-"vggstatWeight"}"
modeId="${3:-1}"
withMatLabel="${4:-false}"
res=8
runDebugInvRender=false
preprocessRoot="/eccv20dataset/yyeh/material-preprocess"


# >>> Environment
apt-get update
apt-get install -y libglu1
apt-get -y install libopencv-dev
condaRoot="/eccv20dataset/yyeh/miniconda3/etc/profile.d/conda.sh"
. $condaRoot
conda activate pytorch-py37
# <<< Environment

python script_renderCombLightBaseline.py --sceneId $sceneId --modeName $modeName --modeId 1 --machine $machine --isLarge --baseline second --forceOutput --camName paper
