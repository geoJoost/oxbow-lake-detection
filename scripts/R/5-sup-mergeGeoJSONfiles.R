# Geoscripting 2023
# Oxbow Gang:
  # Isabeau Verbrugge
  # Joost van Dalen
  # Nikolas Theofanous
  # Wessel van Leesten
  # Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

# This script takes the following steps:
# 1. Open the files containing the oxbow lakes
# 2. Combine all oxbow lakes into one data frame
# 3. Create a proper date column into the combined data frame
#    a. A function is created that retrieves a string like 20180815
#    b. Split the string into different time units
#    c. Remove not useful variables from the data frame
#    d. Convert multipart polygons to singlepart
#    e. Dissolve polygons into each other to create one large polygon per oxbow lake
#    f. Remove unneeded variables to make the final result more readable
#    g. Save the output file as geojson

mergeGeoJSONfiles <- function(input_folder, output_file){
  output_path <- paste0("output/", output_file, ".geojson")
  
  # Read all geojson files from the input folder
  files <- list.files(path = input_folder, pattern = ".geojson$", full.names = TRUE)
  data <- lapply(files, st_read)
  
  # Combine all geojson files into one data frame
  data_combined <- do.call(rbind, data)
  
  # Rename id.x to id variable
  names(data_combined)[names(data_combined) == "id.x"] = "id"
  
  # The following steps are to create a proper date column for indexing (for print) and to add text in the printed map
  # The code is not the most readable and in hindsight could probably be used with datetime as in Pandas
  # End results will be two columns with data like: '2015' and '2015-07-31'
  str_func <- function(str){
    # Retrieve string like 20150731
    date <- unlist(strsplit(as.character(str), split = "[_T]+"))[5]
    
    return(date)
  }
  
  data_combined$date <- apply(X = data_combined[,"id"], MARGIN=1, FUN = function(y) str_func(y))
  
  # Split datetime into different time-units
  data_combined$year <- substr(as.character(data_combined$date), 1, 4) # Returns 2015. Keep this for future indexing
  
  # Delete unnecessary variables
  delete_list <- c('label','level_0.x', 'level_1.x', 'level_0.y','level_1.y', 'id.y', 'date', 'month', 'day')
  data_combined <- data_combined[,!(names(data_combined) %in% delete_list)]
  
  # Even though they are single-part already, they are as MultiPolygon type, this needs to be changed for future dissolve
  data_combined <- st_cast(data_combined, "POLYGON")
  
  # Dissolve polygons into eachother to create one large polygon per oxbow lake
  # Unfortunately, we are disregarding the fact that images can be spread over multiple months
  # These are still included in the animation but otherwise we can not query the user for the desired image
  data_by_year <- aggregate(data_combined, by = list(data_combined$year), FUN = mean, dissolve=FALSE)
  
  # Take year column for final output
  data_by_year$year <- data_by_year$Group.1
  
  # Remove unneeded columns to make the final result more readable
  # Also remove quantitative columns as results are not reliable anymore
  data_by_year <- data_by_year[,!(names(data_by_year) %in% c('Group.1', 'id', 'count', 'area', 'perimeter', 'circIndex'))]
  
  #dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  
  # Save the output file as geojson
  st_write(data_by_year, output_path, delete_dsn=TRUE)
}
