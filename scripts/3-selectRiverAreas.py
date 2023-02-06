#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
# Geoscripting 2023x
# Oxbow Gang:
              # Isabeau Verbrugge
              # Joost van Dalen
              # Nikolas Theofanous
              # Wessel van Leesten
              # Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

Steps taken within this function:
    1. Load .tiff file
    2. Clip raster to bbox manually set (corresponds to the earlier created one in GEE)
    3. Select all river cells covered in water based on user-defind threshold (0 for 'seasonality', 50 for 'occurrence'
    4. Create binary raster
    5. Convert raster to shapes and convert to single-part polygon
    6. Select the largest polygon which corresponds to the river area
    7. Export river polygon as .geojson                                                                          
    """
import sys 
import rasterio
from rasterio.mask import mask
import geopandas as gpd
import numpy as np
import shapely
from shapely.geometry import shape
from shapely.geometry.multipolygon import MultiPolygon

def getRiverPolygon(*argv):


    print("#### Script 3 ####\n")
    print("Starting on function getRiverPolygon which identifies the river flowing through the area")
    # Get arguments out of the list for more readable code
    # To prevent double indexes like argv[0][0]
    variables = argv[0]

    # Refactor variable paths to make it more user-friendly
    rasterpath = "data/" + str(variables[0])
    threshold = int(variables[1])
    
    # Get bounding box from te polygons
    bbox = [138.2858054484003674, -3.5682801082388473, 139.2891321754671594, -2.5547098609382686]
    
    # To polygon
    # Note: without this step, it will clip by individual polygons instead of the entire bbox
    bbox_extent = shapely.geometry.box(*bbox, ccw=True)
    
    # Load raster file  
    with rasterio.open(rasterpath, driver='GTiff')  as src:
        
        # Clip data to the bounding box of the vector data to reduce its size
        # Its also put into a Np array
        # Code from @ahmadhanb at https://gis.stackexchange.com/questions/444062/clipping-raster-geotiff-with-a-vector-shapefile-in-python
        gsw_data, out_transform=mask(src, [bbox_extent], crop=True)
        
    # Remove the third dimension of the array (1, 4056, 3651 --> 4056, 3651)
    # Code from Matt Messersmith at https://stackoverflow.com/questions/37152031/numpy-remove-a-dimension-from-np-array
    gsw_data = gsw_data[0, :, :]
    
    # We use a threshold of 0 to select all water areas
    # You can also use 75 if the 'occurence' dataset from GSW is used
    gsw_binary = np.where(gsw_data <= threshold, 0, 1)
    
    # This entire codeblock below is taken from @Y. Forget at https://gis.stackexchange.com/questions/295362/polygonize-raster-file-according-to-band-values
    # It will take all the raster cells and create a shapefile from them
    # First retrieve all the shapes within the raster
    shapes = list(rasterio.features.shapes(gsw_binary.astype(np.int16), transform=out_transform))
    
    # Create a MultiPolygon geometry with shapely.
    # We make use of the `shape()` functions from shapely to translate between the GeoJSON-like 
    # dict format and the shapely geometry type.
    polygons = [shape(geom) for geom, value in shapes
                if value == 1]
    multipolygons = MultiPolygon(polygons)# Directly making polygons fails, so multipolygons are created first

    # Create a GDF out ouf the output
    gdf_water = gpd.GeoDataFrame({'id':[1],'geometry':[multipolygons]})
    gdf_water = gdf_water.explode(index_parts=True)
    
    # This retrieves the largest polygon found within the GDF which should correspond to the river
    # Code adapted from ahmedshahriar at https://stackoverflow.com/questions/72506224/selecting-the-row-with-the-maximum-value-in-a-column-in-geopandas
    river = gdf_water.iloc[[gdf_water['geometry'].area.idxmax()[1]]]
    
    # And save as .geojson for the next steps
    river.to_file("data/riverArea.geojson", driver="GeoJSON")
    
    print("Finished function getRiverPolygon, see output file as data/riverArea.geojson")
    
    # Return the river polygon for further processing
    return river

# This is essential if we want to run the script from bash
# The code is taken from the GSW Python script ("2-downloadGSWdata.py)
# Use the [1:] to prevent the script call being implemented as argument
if __name__ == "__main__":
    getRiverPolygon(sys.argv[1:])

