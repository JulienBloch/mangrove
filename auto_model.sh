#!/bin/bash

# get all files that want to make model from
# all masks must be .shp files with their .dbf etc files and be labelled:
# 		image_mask.shp where image.tif is the image they are a shape file for
FILES=()
MASKS=()
I=0
today=$(date +%F)

# indicate mask
MASK="./model_ims/mask.shp"

for file in ./model_ims/*.tif; do
	FILES[I]=$file
	MASKS[I]=$MASK
	((I++))
done
# indicate RAM in Mb
RAM=4000

# make stats file
# point to otbcli_ComputeImageStatistics
/Users/julien/OTB-6.0.0-Darwin64/bin/otbcli_ComputeImagesStatistics -il $FILES -out ./model_ims/model_stats.xml -ram $RAM 

# train this model type
CLASSIFIER="libsvm"

# with these parameters:
KERNEL="linear"
OPTIMIZE=true

/Users/julien/OTB-6.0.0-Darwin64/bin/otbcli_TrainImagesClassifier -io.il $FILES -io.vd $MASKS -io.imstat ./model_ims/model_stats.xml -sample.vfn ID -ram $RAM -classifier $CLASSIFIER -classifier.libsvm.k $KERNEL -classifier.libsvm.c 1 -classifier.libsvm.opt $OPTIMIZE -io.out "./models/$(date +%F)_model.txt"

# validation? no!