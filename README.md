## Geoscripting project repository.

### Title:
Detecting oxbow lakes in Indonesia and monitoring their changes

### Team name and members: Porco_Rosso

- Joost van Dalen
- Wessel van Leesten
- Isaura Menezes de Oliveira Guido
- Nikolas Theofanous
- Isabeau Verbrugge

### Challenge number (or "own"):
- own

### Description, how to run/reproduce:
- A Google Earth Engine script has been used to detect and mannually download water in a predefined area. The data is downloaded for multiple dates.
- A zipped file with these geojsons has been uploaded to teams. It is located in Groupwork - files - oxbow gang - scripts.
- This zipped file must be uploaded in a data directory in the folder the main.sh is run from.
- Open a terminal in the directory where the main.sh file is located and run ./main.sh in a line.
 
### Structure:
- The main directory contains this README file, a license file, data and output directories (created after cloning), a script directory and the main bash file.
- The data directory will contain all data, while the output directory is where the output created in scripts is stored.
- The scripts folder contains all scripts that are called in the bash file to generate output. The scripts are numbered to easily keep track of the order.
- The scripts folder also contains a sub directory R. In this sub directory R scripts containing functions are saved. These are functions that are called in another R script and not in the main.sh file. Their names start with the number of the file in which they are called and -sup- is added to the name to indicate that it is a supplementary function file.
    