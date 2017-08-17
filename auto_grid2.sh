#!/bin/bash

# get all files that want to make model from
# all masks must be .shp files with their .dbf etc files and be labelled:
# 		image_mask.shp where image.tif is the image they are a shape file for
FILES=()
MASKS=()
I=0
today=$(date +%F)

# indicate mask
MASK="/media/ml/2tdata/mangrove/model_ims/combined_mask.shp"

for file in /media/ml/2tdata/mangrove/model_ims/*.tif; do
	FILES[I]=$file
	MASKS[I]=$MASK
	((I++))
done

# indicate RAM in Mb
RAM=24000

# make stats file
# point to otbcli_ComputeImageStatistics
# /home/ml/julien_ws/OTB-6.0.0-Linux64/bin/otbcli_ComputeImagesStatistics -il $FILES -out /media/ml/2tdata/mangrove/model_ims/model_stats.xml -ram $RAM 

# train this model type
CLASSIFIER="boost"

# with these parameters:
MAXTRAIN=24000
MAXVALID=24000
BOUNDMIN=true
#KERNEL="linear"
#OPTIMIZE=true
FIELDNAME="id"

# grid search for 2 Adaboost parameters:
# Weak classifiers: boost.w (steps of 5, 20 - 25)
# Maximum depth of tree: boost.m (steps of 2, 2 - 10)

WEAK=5
DEPTH=2
COUNT=5

for i in $(seq 4 $COUNT); do 
	let W=WEAK*i
	for j in $(seq 1 $COUNT); do 
		let D=DEPTH*j
	
		#-sample.mt $MAXTRAIN -sample.mv $MAXVALID
		# point to otbcli_TrainImagesClassifier
		/home/ml/julien_ws/OTB-6.0.0-Linux64/bin/otbcli_TrainImagesClassifier -sample.bm $BOUNDMIN -io.il $FILES -io.vd $MASKS -io.imstat /media/ml/2tdata/mangrove/model_ims/model_stats.xml -sample.mt $MAXTRAIN -sample.mv $MAXVALID -sample.vfn $FIELDNAME -ram $RAM -classifier $CLASSIFIER -classifier.boost.t "real" -classifier.boost.w $W -classifier.boost.D $D -io.out "/media/ml/2tdata/mangrove/models/$(date +%F)_W$W_D$D_model.txt" -io.confmatout "/media/ml/2tdata/mangrove/models/$(date +%F)_W$W_D$D_confmat.csv"

done



# validation?