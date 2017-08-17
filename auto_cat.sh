#!/bin/bash

# The purpose of this script is to automatically download
# Planetlabs orthotiles and to categorize the images
# based on a specified model. The images are then 
# colormapped according to the scheme specified in 
# colormap.txt

# A geojson of the regions of interest must be present

# get planetlabs images of baja mexico (planetscope orthotile)
# pip install planet should be done first
# https://www.planet.com/docs/api-quickstart-examples/cli/
# export PL_API_KEY=3e452f7b18c74bf98bab80fe667ff4cf

# today=$(date +%F)

# planet data search --item-type PSScene4Band --geom map.geojson --date acquired gt 2017-01-10 --date acquired lt $today

# planet data search --item-type PSScene4Band --geom map.geojson --date acquired gt 2017-01-10 --date acquired lt $today --range cloud_cover lt .1

#planet data download --item-type PSScene4Band --geom map.geojson --date acquired gt 2017-01-10 --date acquired lt $today --range cloud_cover lt .1 --asset-type analytic

# put images in "new images" folder
# get cloudmasks of each images
# classify each image and output in out folder

# Indicate where Orfeo Toolbox is installed:
OTB="/home/ml/julien_ws/OTB-6.0.0-Linux64/"

# Indicate where the files to be classified are stored:
for image in /media/ml/2tdata/mangrove/model_ims/*.tif; do

	# make statistics file for band normalization
	$OTB"bin/otbcli_ComputeImagesStatistics" -il $image -out "$(basename "$image" .tif)_stats.xml"

	#classify image
	# make sure this points to actual otbcli_ImageClassifier
	$OTB"/bin/otbcli_ImageClassifier" -in $image -imstat "$(basename "$image" .tif)_stats.xml" -model /media/ml/2tdata/mangrove/models2/2017-08-08_model.txt -out "classified/$(basename "$image" .tif)_classified.tif"

	#change labels to colors
	$OTB"/bin/otbcli_ColorMapping" -in "classified/$(basename "$image" .tif)_classified.tif" -out "classified/$(basename "$image" .tif)_classified.tif" -method custom -method.custom.lut /media/ml/2tdata/mangrove/colormap
done