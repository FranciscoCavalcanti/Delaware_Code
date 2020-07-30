#################################################################################
#
# The purpose is to extract monthly data of temperature for every Brazilians AMC
#
# There are two important datasets:
# 
# 1) Shapefile data of AMC for Brazil
# 2) NetCDF data of temperature from Willmott, C. J. and K. Matsuura (2001)
#
# The outcome is .csv files by month and AMC temperature
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

data_shp_dir    <-'C:/Users/Francisco/Dropbox/data_sources/Shapefiles/AMC'
data_ncdf_dir   <-'C:/Users/Francisco/Dropbox/data_sources/Climatologia/Willmott and Matsuura/Temperature V 5.01'

home_dir    <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand'
out_dir     <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand/output'
in_dir      <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand/input'
tmp_dir     <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand/tmp'
code_dir    <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand/code'

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
shapefile<-st_read('AMCs0010.shp')
crs(shapefile)

# convert crs
shapefile <- st_transform(shapefile, crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

# check AMC shapefile
class(shapefile)
summary(shapefile)
variable.names(shapefile)
summary(shapefile[variable.names("munic")])
summary(shapefile[variable.names("amc0010")])
summary(shapefile[variable.names("CD_GEOCODM")])

# additional check in the shapefile
str(shapefile)
extent(shapefile)
crs(shapefile)

# plot map in R
#plot(shapefile)

# Extracting data from Satelite

# the data format: netcdf
setwd(data_ncdf_dir)
list_files<-list.files(pattern=".nc")
print(list_files)
length(list_files)

# call netcdf file
temp_file1<- "air.mon.mean.v501.nc"
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

# number of layers
names(temp_file2)
nl <- nlayers(temp_file2)

#################################################
# Loop over time period (layers) to extract temperature
#################################################

# begin of loop
for (i in 1:nl){

# Extract the raster file of layers
r <- raster(temp_file2, layer = i)

# Extract relevant information from shapefile
temp_shp<- shapefile[c("amc0010","munic", "geometry")]
crs(temp_shp)

# Transform crs of temporary shapefile
crs(temp_shp)
temp_shp <- st_transform(temp_shp, crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

# Ensure command extract is from raster package
extract <- raster::extract

# Extract the mean value of cells within AMC polygon
# Alternative: look to "mask" function ?mask
masked_file<-extract(r, 
                    temp_shp, 
                    fun = mean,
                    na.rm=TRUE, 
                    df=F, 
                    small=T, 
                    sp=T,  
                    weights=TRUE, 
                    normalizedweights=TRUE)

# Generate variable depicting the date
# Extract the information about the time
date <- r@z[[1]]
date
date <- as.Date(date, )

# Compile the codes for AMC and time variable in one dataframe
df <- data.frame(date, masked_file)

# rename last variable that represents the extracted values
colnames(df)[4] <- "monthly_temperature"

# save data as .csv
setwd(in_dir)

write.csv(df, 
         paste0(in_dir, "/amc_temperature_csv/", date , "_amc_temperature.csv"), 
         row.names = TRUE,
         ) # overwrites

# print
print(i)
print(date)
# end of loop
}

# show a sample of map
#library(tmap)
#tm_shape(temp_shp)+tm_fill('layer', palette = "Blues", title = "Temperature")

