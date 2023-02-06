#!/bin/bash
# Geoscripting 2023
# Oxbow Gang:
              # Isabeau Verbrugge
              # Joost van Dalen
              # Nikolas Theofanous
              # Wessel van Leesten
              # Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

# Create a data and an output folder
mkdir -p data || exit 1 # Or do manually when downloading the data from Teams
mkdir -p output || exit 1

# MANUALLY create a Python environment
# Use conda env create --file createEnv.yaml
source activate geo_env

# MANUALLY upload the data from Teams into the right folder
# This function double-checks if the step is performed
FILE="data/earth_data_dates.zip"
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE does not exist. Please download and export data from Teams into data folder"
    echo "Zipped folder is missing. Exiting..." >&2
    exit 1 # Stop entire function if the data from GEE is not found
fi

echo "Running 7 scripts numbered from 2-8"
# Downlaoad the .tif files from the Global Surface Water Explorer (GSW)
# Metadata from:
python "scripts/2-downloadGSWdata.py" "data/" "seasonality"

# Execute function 3 to retrieve the river area based on the biggest polygon and data from GSW
# Argument 1: the raster file downloaded from GSW
# Argument 2: Threshold used (val <= threshold). Select 0 for seasonality to select all cells, if 'occurrence' is used we recommend setting it to 50
# Argument 3: File name for saving the river polygon (as data/[FILE].geojson) 
# NOTE: If you get "ModuleNotFoundError: No module named 'rasterio'" make sure you downloaded + activated geo_env
python "scripts/3-selectRiverAreas.py" "seasonality_130E_0Nv1_4_2021.tif" 0

# Execute function 4 to preprocess the SAR polygons from GEE
# This function loops over the entire time-series and processes all data to identify the oxbow lakes within the image
Rscript scripts/4-identifyOxbowLakes.R


# Execute function 5
# This function creates a single file with the oxbow lakes in all years. They are multipolygons per year
Rscript scripts/5-createMergedFiles.R


# Execute function 6
# This function saves a HTML link to an interactive map
Rscript scripts/6-interactiveMap.R


# Execute function 7
# This function creates a moving gif file that shows the change in oxbow lakes
python "scripts/7-createChangeGIF.py"


# Execute function 8
# This function asks for user input of the year. It returns a map in the output folder showing the oxbow lakes in the chosen year. It then loops back to the beginning and you can run the script again to create another plot or type quit to stop.

echo -e "\n#### Script 8 ####\n"
echo "This script can be run for as many years as you like"
# Code adapted from https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_09_02.html
while true; do
	echo -e "\nGive the year (2015-2023) for which to plot oxbow lakes ('quit' for quit)"
	
	read var
	
	if [ "$var" == "quit" ]; then
		break
	elif (("$var" < "2024"))  && (("$var" > "2014")); then
		Rscript scripts/8-createStaticMap.R $var
	else
		echo Supply a valid year
	fi
	
done
