#!/bin/bash
sceneId=$1
gpuId=0
modeName="${2:-"vggstatWeight"}"
modeId="${3:-1}"
withMatLabel="${4:-false}"
res=8
runDebugInvRender=false
preprocessRoot="/eccv20dataset/yyeh/material-preprocess"

export CUDA_VISIBLE_DEVICES=$gpuId

# >>> Environment
apt-get update
apt-get install -y libglu1
apt-get -y install libopencv-dev
condaRoot="/eccv20dataset/yyeh/miniconda3/etc/profile.d/conda.sh"
. $condaRoot
conda activate pytorch-py37
# <<< Environment

# Assume we have inv render results already!
cd $preprocessRoot
# Preprocess2: consensus aware view selection, save warped mask and other labels
python script_preprocess2.py --sceneId $sceneId --machine cluster
#graphDictFile="$orSnRoot/$scene/selectedGraphDict.txt"

# Graph Classificat``ion
orSnRoot="/eccv20dataset/yyeh/OpenRoomScanNetView"
scene="scene$sceneId"
if [ ! -s "$orSnRoot/$scene/selectedGraphDict.txt" ]
then
    if [ "$withMatLabel" = false ] ; then
        cd $preprocessRoot
        python genMatClsList.py --sceneId $sceneId --machine cluster
        cd $preprocessRoot
        bash script_runMaterialClassifier.sh $sceneId $gpuId cluster
    fi
    cd $preprocessRoot
    bash script_runGraphClassifier.sh $sceneId $gpuId cluster
    echo "New graph dict saved at $orSnRoot/$scene/selectedGraphDict.txt !"
else
    echo "$orSnRoot/$scene/selectedGraphDict.txt exists! Skip!"
fi

cd $preprocessRoot

### >>> Run MaTch
echo "Run MaTch!"
isHomo=false
isHomoTag=""
machine="cluster"
conda activate diffmat

# >>>> For first round optimization
bash script_optMatAll.sh $sceneId $gpuId $machine $modeName $modeId $res $isHomo false
# bash script_optMatAll.sh 0001_00 0 cluster vggstatWeight 1 8 false false
bash script_addAreaLight.sh $sceneId $machine
CUDA_VISIBLE_DEVICES=$gpuId python script_renderSingleLights.py --sceneId $sceneId --modeName $modeName --modeId $modeId --machine $machine $isHomoTag
# python script_renderSingleLights.py --sceneId 0001_00 --modeName vggstatWeight --modeId 1 --machine cluster
python computeLightCoefExposure.py --sceneId $sceneId --machine $machine --taskName $modeName --modeId $modeId $isHomoTag
# python computeLightCoefExposure.py --sceneId 0001_00 --machine cluster --taskName vggstatWeight --modeId 1
CUDA_VISIBLE_DEVICES=$gpuId python script_renderCombLight.py --sceneId $sceneId --modeName $modeName --modeId $modeId --machine $machine $isHomoTag

# >>>> For second round optimization
CUDA_VISIBLE_DEVICES=$gpuId python script_renderCombLightPerPixel.py --sceneId $sceneId --modeName $modeName --modeId $modeId --machine $machine $isHomoTag
bash script_optMatAll.sh $sceneId $gpuId $machine $modeName $modeId $res $isHomo true
CUDA_VISIBLE_DEVICES=$gpuId python script_renderCombLight.py --sceneId $sceneId --modeName $modeName --modeId $modeId --machine $machine --useGlobalLight $isHomoTag

python combineResultNew.py --sceneId $sceneId --modeName $modeName --modeId 1 --machine $machine $isHomoTag
python combineResultNew.py --sceneId $sceneId --modeName $modeName --modeId 1 --machine $machine $isHomoTag --useGlobalLight
python combineResultNew.py --sceneId $sceneId --modeName $modeName --modeId 1 --machine $machine $isHomoTag --isSelect
python combineResultNew.py --sceneId $sceneId --modeName $modeName --modeId 1 --machine $machine $isHomoTag --useGlobalLight --isSelect
# --isSelect --nSelectView 9
# add above to show sampled views
### <<<Run MaTch

python runRenderBaseline.py --sceneId $sceneId --gpuId 0 --modeName $modeName --modeId 1 --machine $machine
