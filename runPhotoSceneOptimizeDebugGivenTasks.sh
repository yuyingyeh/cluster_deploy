#!/bin/bash
sceneId=$1
gpuId=0
#modeName="${2:-"statWeight"}"
#modeId="${3:-1}"
OLDIFS=$IFS;
IFS=',';
for i in vggWeight,1; do
    set -- $i;
    # echo $1 and $2;
    modeName=$1
    modeId=$2

    matRes=8
    runDebugInvRender=false
    preprocessRoot="/eccv20dataset/yyeh/material-preprocess"

    export CUDA_VISIBLE_DEVICES=$gpuId

    #condaRoot="/root/miniconda3/etc/profile.d/conda.sh"
    condaRoot="/eccv20dataset/yyeh/miniconda3/etc/profile.d/conda.sh"
    . $condaRoot
    #source $condaRoot

    # Graph Classification
    orSnRoot="/eccv20dataset/yyeh/OpenRoomScanNetView"
    scene="scene$sceneId"
    if [ ! -s "$orSnRoot/$scene/selectedGraphDict.txt" ]
    then
        #cd /eccv20dataset/yyeh/material-preprocess
        cd $preprocessRoot
        python genMatClsList.py --sceneId $sceneId --machine cluster

        #cd /eccv20dataset/yyeh/material-preprocess
        #bash script_runMaterialClassifier.sh $sceneId $gpuId cluster

        #apt-get update
        #apt-get -y install libopencv-dev
        #conda activate /viscompfs/users/ruizhu/envs/semanticInverse
        #cd /eccv20dataset/yyeh/semanticInverse
        #python train/trainMatCls-20210311_real.py --task_name tmp --test_real \
        #    --resume 20210312-162028--matcls_clsLoss_SUP_bs32 DATASET.num_workers 16 SOLVER.ims_per_batch 24 \
        #    TEST.ims_per_batch 24 DATA.im_height 240 DATA.im_width 320 SOLVER.lr 0.00005 DATASET.mini False \
        #    SOLVER.if_test_dataloader True DATA.if_load_png_not_hdr True MODEL_MATCLS.enable True \
        #    SOLVER.if_test_dataloader False  TEST.vis_max_samples 1000000 MODEL_MATCLS.if_est_sup True \
        #    MODEL_MATCLS.real_images_list "$orSnRoot/$scene/real_images_list.txt"

        cd $preprocessRoot
        bash script_runGraphClassifier.sh $sceneId $gpuId cluster
        echo "New graph dict saved at $orSnRoot/$scene/selectedGraphDict.txt !"
    else
        echo "$orSnRoot/$scene/selectedGraphDict.txt exists! Skip!"
    fi

    #pip3 install pathlib
    #bash script_optMatAll.sh $sceneId $gpuId "cluster" $modeName $modeId $matRes $isHomo false $isDebug


    # conda install scikit-image opencv scikit-learn
    apt-get update
    apt-get install -y libglu1

    cd $preprocessRoot
    isDebug=true

    ### >>> Run Homogeneous
    echo "Run Homo!"
    isHomo=true
    modeIdHomo=1
    if [ "$isDebug" = true ]; then matDirName="optMatDebugHomo"; else matDirName="optMatHomo"; fi
    conda activate diffmat
    #python -c "import imageio; imageio.plugins.freeimage.download()"
    bash script_optMatAll.sh $sceneId $gpuId "cluster" $modeName $modeIdHomo $matRes true false "$isDebug" "$runDebugInvRender"
    # bash script_optMatAll.sh 0022_01 0 cluster statWeight 1 8 true false true false
    python combineResultNew.py --sceneId $sceneId --modeName $modeName --modeId $modeIdHomo --isSelect --isHomo --isDebug --machine cluster
    ### <<< Run Homogeneous

    ### >>> Homogeneous Regularization
    modeNameHomo="Weight"
    bash script_optMatAll.sh $sceneId $gpuId "cluster" $modeNameHomo $modeIdHomo $matRes true false "$isDebug" "$runDebugInvRender"
    ### <<< Homogeneous Regularization

    ### >>> Run MaterialGAN
    echo "Run MaterialGAN!"
    # matplotlib opencv imageio
    if [ "$isDebug" = true ]; then matDirName="optMatDebugGan"; else matDirName="optMatGan"; fi
    conda activate pytorch-py37
    imageio_download_bin freeimage
    bash script_optMatGAN.sh $sceneId $gpuId "cluster" $modeName $modeId false "$isDebug" "$runDebugInvRender"
    # bash script_optMatGAN.sh 0022_01 0 cluster statWeight 1 false true false
    python combineResultNew.py --sceneId $sceneId --modeName $modeName --modeId $modeId --isSelect --isGan --isDebug --machine cluster
    # python combineResultNew.py --sceneId 0022_01 --modeName statWeight --modeId 1 --isSelect --isGan --isDebug --machine cluster
    ### <<< Run MaterialGAN

    ### >>> Run MaTch
    echo "Run MaTch!"
    isHomo=false
    if [ "$isDebug" = true ]; then matDirName="optMatDebug"; else matDirName="optMat"; fi
    conda activate diffmat
    bash script_optMatAll.sh $sceneId $gpuId "cluster" $modeName $modeId $matRes false false "$isDebug" "$runDebugInvRender"
    # bash script_optMatAll.sh 0022_01 0 cluster statWeight 1 8 false false true false
    python combineResultNew.py --sceneId $sceneId --modeName $modeName --modeId $modeId --isSelect --isDebug --machine cluster
    ### <<< Run MaTch
done;
IFS=$OLDIFS


