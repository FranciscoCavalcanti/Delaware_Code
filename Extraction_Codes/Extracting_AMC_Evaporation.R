#################################################################################
#
# The purpose is to extract monthly data of evapotranspiration for every Brazilians AMC
#
# There are two important datasets:
# 
# 1) Shapefile data of AMC for Brazil
# 2) NetCDF data of precipitation from Willmott, C. J. and K. Matsuura (2001)
#
# The outcome is .csv files by month and AMC evapotranspiration
#
#################################################################################

#################################################################################
#
# Useful links which I used as reference:
#
# SOURCE: https://github.com/jimenarp/nasa-satellite/blob/c8e753ed27609602a3fa195d3584618dd4563de1/compile-nc4.R
# SOURCE: https://stackoverflow.com/questions/42982599/netcdf-to-raster-brick-unable-to-find-inherited-method-for-function-brick-for
#
#################################################################################

####################
# install packages
####################

install.packages("ncdf4", "raster", "sf", "tmap")
install.packages("tmap")
install.packages("tidyverse")

# installing packages
packages_vector <- c('ggplot2','tidyverse', 'dplyr')
geopackages<-c('raster','ncdf4', 'sf')
lapply(packages_vector, require, character.only = TRUE) # the "lapply" function means "apply this function to the elements of this list or more restricted data 
lapply(geopackages, require, character.only = TRUE) 

####################
# Folder Path
####################

user <- Sys.info()[["user"]]
message(sprintf("Current User: %s\n"))
if (user == "Francisco" ){
  ROOT <- 'C:/Users/Francisco/Dropbox'
} else if (user == "f.cavalcanti"){
  ROOT <- 'C:/Users/Francisco/Dropbox'  
} else {
  stop("Invalid user")
}

home_dir  <-file.path(ROOT, "political_alignment_and_droughts", "build", "7_delaware")
in_dir  <-file.path(ROOT, "political_alignment_and_droughts", "build", "7_delaware", "input")
out_dir  <-file.path(ROOT, "political_alignment_and_droughts", "build", "7_delaware", "output")
tmp_dir  <-file.path(ROOT, "political_alignment_and_droughts", "build", "7_delaware", "tmp")
code_dir  <-file.path(ROOT, "political_alignment_and_droughts", "build", "7_delaware", "code")
data_shp_dir  <-file.path(ROOT, "data_sources", "Shapefiles", "AMC_Ehrl")
data_ncdf_dir  <-file.path(ROOT, "data_sources", "Climatologia", "Willmott_and_Matsuura", "Water_Budget_V401")

####################
# load library
####################
library(tidyverse)
library(ncdf4)
library(raster)
library(sf)
library(tmap)
library(stringr)
library(tidyverse)

# read shapefile
setwd(data_shp_dir)
shapefile<-st_read('amc_2000_2010.shp')
crs(shapefile)

# convert crs
shapefile <- st_transform(shapefile, 
                          crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

###############################
# Extracting data from Satelite
###############################

# Unzip
setwd(data_ncdf_dir)
file1 <- list.files(pattern=".tar")
untar(file1)

# List the files in the folder
old_file_name <- list.files(data_ncdf_dir, 
                         pattern = "E150[.]",
                         full.names = TRUE)

# New file names
new_file_name <- paste0("E150_", 
                        1899 + 1:length(old_file_name), 
                        ".csv", sep = "")

file.rename(old_file_name, new_file_name)

#################################################
# Loop over years
#################################################

# begin of loop
for (yr in 1969:2017){

  # list each csv file year by year
  setwd(data_ncdf_dir)
  iten1 <- paste0(yr, ".csv",sep = "")
  list_file<-list.files(pattern=iten1)
  iten1
  
  # read csv file
  Xdata <- read.csv2(list_file, sep = "", header = FALSE)
  
  # rename variables
  myColNames <- c("lon",
                  "lat",
                  "_01",
                  "_02",
                  "_03",
                  "_04",
                  "_05",
                  "_06",
                  "_07",
                  "_08",
                  "_09",
                  "_10",
                  "_11",
                  "_12")
  
  names(Xdata) <- myColNames
  
  # study the file
  # str(Xdata)
  # names(Xdata)
  # head(Xdata$lon)
  # head(Xdata$lat)
  
  # covert csv file to raster
  # reference:
  # https://stackoverflow.com/questions/19627344/how-to-create-a-raster-from-a-data-frame-in-r
  
  dfr <- rasterFromXYZ(Xdata,crs = crs(shapefile))
  
  #plot(dfr)
  #dfr@data@values[[3]]
  #dfr@data@names[[3]]
  
  #dfr <- dfr@data@nlayers
  
  # Ensure command extract is from raster package
  extract <- raster::extract
  
  # Extract the mean value of cells within AMC polygon
  # Alternative: look to "mask" function ?mask
  masked_file<-extract(dfr, 
                       shapefile, 
                       fun = mean,
                       na.rm=TRUE, 
                       df=F, 
                       small=T, 
                       sp=T,  
                       weights=TRUE, 
                       normalizedweights=TRUE)
  
  #################################################
  # Loop over months
  #################################################

  # Jan starts at 27 
  names(masked_file@data[27])
  # December at 38
  names(masked_file@data[38])
  
  # begin of loop over months
  for (i in 27:38){
  
    # extract only relevant variables
    munic <- masked_file$GEOCODIG_M
    amc_2000 <- masked_file$amc_2000_2
    monthly_evapotranspiration <- masked_file[i]
    month <- masked_file[i] %>% 
      names() 
  
    # Compile the codes for AMC and time variable in one dataframe
    df <- data.frame(munic, amc_2000, monthly_evapotranspiration, yr, month)
      
    # rename variables
    colnames(df)[3] <- "monthly_evapotranspiration"
      
    # save data as .csv
    setwd(in_dir)
    write.csv(df, 
              paste0(in_dir, "/amc_evapotranspiration_csv/", yr , month, "_amc_evapotranspiration.csv"), 
              row.names = TRUE,
              ) # overwrites
  
    # print
    print(i)
    print(month)
    print(yr)
    # end of loop
  }
}

# remove all
setwd(data_ncdf_dir)

#Check its existence
if (file.exists(new_file_name)) 
  #Delete file if it exists
  file.remove(new_file_name)