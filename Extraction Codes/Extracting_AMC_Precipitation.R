#################################################################################
#
# The purpose is to extract monthly data of rainfall for every Brazilians AMC
#
# There are two important datasets:
# 
# 1) Shapefile data of AMC for Brazil
# 2) NetCDF data of precipitation from Willmott, C. J. and K. Matsuura (2001)
#
# The outcome is .csv files by month and AMC rainfall
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
# Folder Path
####################

home_dir   <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand'
data_shp_dir  <-'C:/Users/Francisco/Dropbox/data_sources/Shapefiles/AMC_Ehrl'
data_ncdf_dir   <-'C:/Users/Francisco/Dropbox/data_sources/Climatologia/Willmott and Matsuura/Precipitation V 5.01'
out_dir   <- 'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand/output'
in_dir  <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand/input'
tmp_dir   <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand/tmp'
code_dir  <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand/code'

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
# load library
####################
library(tidyverse)
library(ncdf4)
library(raster)
library(sf)
library(tmap)
library(stringr)
library(tidyverse)

# I will create a panel data of Brazilians AMC, month by month. 
# First, I will get the structure of the data from the shapefile. 

# read shapefile
setwd(data_shp_dir)
shapefile<-st_read('amc_1980_2010.shp')
crs(shapefile)

# convert crs
shapefile <- st_transform(shapefile, crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

# check AMC shapefile
class(shapefile)
summary(shapefile)
variable.names(shapefile)
summary(shapefile[variable.names("GEOCODIG_M")])
summary(shapefile[variable.names("amc_1980_2")])
summary(shapefile[variable.names("UF")])

# additional check in the shapefile
str(shapefile)
extent(shapefile)
crs(shapefile)

# plot map in R
# plot(shapefile)

# Extracting data from Satelite

# the data format: netcdf
setwd(data_ncdf_dir)
list_files<-list.files(pattern=".nc")
print(list_files)
length(list_files)

# call netcdf file
temp_file1<- "precip.mon.total.v501.nc"
temp_file1 = brick(temp_file1) # read netcdf file

# check the data
extent(temp_file1)
crs(temp_file1)

# convert longitife [0 360] to [-180 180]
# this a common issue in statelite data
temp_file2 = rotate(temp_file1)

# check the data
extent(temp_file2)
crs(temp_file2)

# Ensure command extract is from raster package
extract <- raster::extract

# Extract the mean value of cells within AMC polygon
# Alternative: look to "mask" function ?mask
masked_file<-extract(temp_file2, 
                     shapefile, 
                     fun = mean,
                     na.rm=TRUE, 
                     df=F, 
                     small=T, 
                     sp=T,  
                     weights=TRUE, 
                     normalizedweights=TRUE)

#################################################
# Loop 
#################################################

nl <- masked_file@data %>% 
  length()

# begin of loop
for (i in 20:nl){
  
  
  # extract only relevant variables
  munic <- masked_file$GEOCODIG_M
  amc_1980 <- masked_file$amc_1980_2
  monthly_rainfall <- masked_file[i]
  date <- masked_file[i] %>% 
    names() %>% 
    str_sub(start = 2, end = 11)
  
  # Compile the codes for AMC and time variable in one dataframe
  df <- data.frame(munic, amc_1980, monthly_rainfall, date)

  # rename variables
  colnames(df)[3] <- "monthly_rainfall"
  
  # save data as .csv
  setwd(in_dir)
  
  write.csv(df, 
            paste0(in_dir, "/amc_rainfall_csv/", date , "_amc_rainfall.csv"), 
            row.names = TRUE,
  ) # overwrites
  
  # print
  print(i)
  print(date)
  # end of loop
}
