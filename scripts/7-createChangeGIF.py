"""
# Geoscripting 2023
# Oxbow Gang:
              # Isabeau Verbrugge
              # Joost van Dalen
              # Nikolas Theofanous
              # Wessel van Leesten
              # Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia


1. This file lists all geojsons with oxbow lakes that are created in script 4
2. It also loads the river polygon from script 3
3. It then loops over the geojsons
    a. It creates a plot of the river
    b. To that plot normal lakes and oxbow lakes are added
    c. Title and north arrow and date are added to the plot
    d. It is saved as a png
4. All pngs are loaded and sorted
5. They are put together and saved as a moving gif

"""

# Import required libraries
import geopandas as gpd
from matplotlib import pyplot as plt
from PIL import Image
import glob
import re
import os

# Print a message so user in Bash knows how far they are
print("\n#### Script 7 ####\n")

# Create a new directory to save the png files
png_dir = 'output/oxbow_lakes_png'
if not os.path.exists(png_dir):
    os.mkdir(png_dir)

# Read the file that contains the river polygon
river = gpd.read_file("data/riverArea.geojson")

# Set the boundary box of the study area
bbox = [138.2858054484003674, -3.5682801082388473, 139.2891321754671594, -2.5547098609382686]

# List all geojson files in the correct directory
# Code line from pyhtonprogramming at https://pythonprogramming.altervista.org/png-to-git-to-tell-a-story-with-python-and-pil/
oxbow_geojsons = glob.glob("output/oxbow_lakes/*.geojson")

# The following block of code has been adapted based on code by
# Ben Dexter Cooley at https://towardsdatascience.com/how-to-make-a-gif-map-using-python-geopandas-and-matplotlib-cd8827cefbc8

for file in oxbow_geojsons:
    # Code line from Krunal at https://appdividend.com/2022/05/30/how-to-split-string-with-multiple-delimiters-in-python/
    # get only the date from the name
    year = re.split("s_|.geo", file)[1]
    
    # Read the data from the filepath
    data = gpd.read_file(file)
    
    # Load the data for the normal lakes
    lake_file = "output/lakes/4-CircularLakes_" + year + ".geojson"
    lakes = gpd.read_file(lake_file)
    
    # Plot the river polygon in a new figure
    oxbows = river.plot(figsize=(10,10), color="#00B4D8")
    
    # Plot the normal lakes in the same figure
    lakes.plot(ax=oxbows, color='#023E8A')
    
    # Plot the oxbow lakes in the same figure
    data.plot(ax=oxbows, color='#FF0054')
    
    # Set x and y limits following the study area bbox
    oxbows.set_xlim(bbox[0], bbox[2])
    oxbows.set_ylim(bbox[1], bbox[3])
    
    # Code from https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.annotate.html
    # Add a title to the top of the plot 
    oxbows.annotate("Evolution of oxbow lakes 2015-2023",
                xy=(0.2, .97), xycoords='figure fraction',
                horizontalalignment='left', verticalalignment='top',
                fontsize=25)
    oxbows.annotate("in Western New Guinea",
                xy=(0.37, .93), xycoords='figure fraction',
                horizontalalignment='left', verticalalignment='top',
                fontsize=20)
    
    # Code from steven at https://stackoverflow.com/questions/58088841/how-to-add-a-north-arrow-on-a-geopandas-map
    # Add a north arrow
    x, y, arrow_length = 0.95, 0.95, 0.06
    oxbows.annotate('N', xy=(x, y), xytext=(x, y-arrow_length),
            arrowprops=dict(facecolor='black', width=5, headwidth=15),
            ha='center', va='center', fontsize=20, xycoords=oxbows.transAxes)
    
    
    # Add the date to the bottom left corner
    oxbows.annotate(year,
            xy=(0.07, .07), xycoords='figure fraction',
            horizontalalignment='left', verticalalignment='top',
            fontsize=20)
    
    # Construct an output name based on the year
    output_name = 'output/oxbow_lakes_png/' + year + ".png"
    
    # Save the plot as a png with the output name
    plt.savefig(output_name)
    
# The following code has been adapted from pythonprogramming at:
    # https://pythonprogramming.altervista.org/png-to-git-to-tell-a-story-with-python-and-pil/

 
# Create a list to store the frames for the gif
frames = []

# List all images in the oxbow_lakes_png folder
imgs = glob.glob("output/oxbow_lakes_png/*.png")

# Sort the images by name (and thus date)
imgs.sort()

# Loop over the images
for i in imgs:
    # Load them
    new_frame = Image.open(i)
    
    # Append every image to the list of frames
    frames.append(new_frame)
 
# Save into a GIF file that loops forever
frames[0].save('output/7-timeseriesOfOxbowLakes.gif', format='GIF',
               append_images=frames[1:],
               save_all=True,
               duration=600, loop=0)

print("png has been saved in the output folder")
