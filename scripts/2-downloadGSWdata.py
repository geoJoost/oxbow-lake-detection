# Code sourced from: https://global-surface-water.appspot.com/download
# Research paper:
# Jean-Francois Pekel, Andrew Cottam, Noel Gorelick, Alan S. Belward, High-resolution mapping of global surface water and its long-term changes. Nature 540, 418-422 (2016). (doi:10.1038/nature20584) 
# Only changes made are in the selecting of longitude-latitude + some print statements

# Code downloads one data tile (0W to 140E and 0S to 10N) that includes our study area from The Global Surface Water data

import urllib.request, sys, getopt, os
def main(argv):
   print("\n#### Script 2 ####\n")
   print("Starting on the download of the data from the Global Surface Water Explorer")
    
   DESTINATION_FOLDER = argv[0]
   if (DESTINATION_FOLDER[-1:]!="/"):
      DESTINATION_FOLDER = DESTINATION_FOLDER + "/"
   if not os.path.exists(DESTINATION_FOLDER):
      print("Creating folder " + DESTINATION_FOLDER)
      os.makedirs(DESTINATION_FOLDER)
   DATASET_NAME = argv[1]
   longs = [str(w) + "W" for w in range(0,0,-10)] # We do not include data west of prime meridian
   longs.extend([str(e) + "E" for e in range(130,140,10)]) # And only want this select area
   lats = [str(s) + "S" for s in range(0,0,-10)]
   lats.extend([str(n) + "N" for n in range(0,10,10)]) # Nothing north of the equator
   fileCount = len(longs)*len(lats)
   counter = 1
   for lng in longs:
      for lat in lats:
        filename = DATASET_NAME+ "_" + str(lng) + "_" + str(lat) + "v1_4_2021.tif"
        if os.path.exists(DESTINATION_FOLDER + filename):
           print(DESTINATION_FOLDER + filename + " already exists - skipping")
        else:
           url = "http://storage.googleapis.com/global-surface-water/downloads2021/" + DATASET_NAME + "/" + filename
           code = urllib.request.urlopen(url).getcode()
           if (code != 404):
              print("Downloading " + url + " (" + str(counter) + "/" + str(fileCount) + ")")
              urllib.request.urlretrieve(url, DESTINATION_FOLDER + filename)
           else:
              print(url + " not found")
        counter += 1
        
        print("Finished exporting data from the Global Surface Water Explorer to:", DESTINATION_FOLDER, filename, "\n")
if __name__ == "__main__":
   main(sys.argv[1:])
