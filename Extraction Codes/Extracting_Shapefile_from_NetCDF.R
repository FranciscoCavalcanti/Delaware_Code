# SOURCE: https://github.com/jimenarp/nasa-satellite/blob/c8e753ed27609602a3fa195d3584618dd4563de1/compile-nc4.R
# SOURCE: https://stackoverflow.com/questions/42982599/netcdf-to-raster-brick-unable-to-find-inherited-method-for-function-brick-for

####################
# Folder Path
####################

home_dir   <-'C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand'
data_shp_dir  <-'C:/Users/Francisco/Dropbox/data_sources/Shapefiles/AMC'
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

# installing packages
packages_vector <- c('ggplot2','tidyverse', 'dplyr')
geopackages<-c('raster','ncdf4', 'sf')
lapply(packages_vector, require, character.only = TRUE) # the "lapply" function means "apply this function to the elements of this list or more restricted data 
lapply(geopackages, require, character.only = TRUE) 

####################
# load library
####################
library(ncdf4)
library(raster)
library(sf)
library(tmap)
library(stringr)

# I will create a panel data of Brazilians AMC, month by month. 
# First, I will get the structure of the data from the shapefile. 

# read shapefile
setwd(data_shp_dir)
shapefile<-st_read('AMCs0010.shp')
crs(shapefile)

# check AMC shapefile
class(shapefile)
summary(shapefile)
variable.names(shapefile)
summary(shapefile[variable.names("munic")])
summary(shapefile[variable.names("amc0010")])
summary(shapefile[variable.names("CD_GEOCODM")])

# additional check for shapefile data
str(shapefile)
extent(shapefile)
crs(shapefile)

# plot map in R
#plot(shapefile)

# Now, read data on rainfall

# the data format is netcdf
setwd(data_ncdf_dir)
list_files<-list.files(pattern=".nc")
print(list_files)

# each column will be named after the date (month-year) of the array
length(list_files)
temp_file<-list_files[3] # "precip.mon.total.v501.nc"
temp_file<- "precip.mon.total.v501.nc"

temp_file <- nc_open(temp_file)

# check the data
str(tem_file)
class(temp_file)
summary(temp_file)
variable.names(temp_file)
crs(temp_file)
temp_file$dim
temp_file$dim$lat
temp_file$dim$lon
temp_file$dim$time
temp_file$var
temp_file$var$precip$prec
temp_file$var$precip$size
temp_file$ndims
temp_file$nvars
temp_file$format


# array for longitude
lon<-ncvar_get(temp_file, "lon")
lon 
# flip longitude in order to match maps 
#lon <- lon - 180
#lon

# array for latiture
lat<-ncvar_get(temp_file, "lat")
lat

# array for time
time<-ncvar_get(temp_file, "time")
length(time)
time

# raster for precipitation

# extracting the variable precipitation
iten1 <- temp_file$var[["precip"]]   # or, iten1  <- temp_file$var$precip

# extrating information
size <- iten1$varsize
ndims   <- iten1$ndims

# extrating data from time dimension
nt      <- size[ndims]  # Remember timelike dim is always the LAST dimension!

#################################################
# Loop over time period to extract precipitation
#################################################

# begin of loop
for (i in 1:nt){
# generate a sequence of three "1"
# the idea is run the code over the begin the latitude and longitude dimensions
# and then edit only the time dimention
start <- rep(1,ndims) # begin with start=(1,1,...,1)
start[ndims] <- i # change to start=(1,1,...,i) to read    timestep i 
count <- size	# begin w/count=(nx,ny,nz,...,nt), reads entire var
count[ndims] <- 1	# change to count=(nx,ny,nz,...,1) to read 1 tstep
# getting whole data of precipitation at a fixed point of the time dimention
tmp.array <- ncvar_get( temp_file, iten1, start=start, count=count )
# getting missing data at a fixed point of the time dimention
#iten2 <- iten1$missval
#fillvalue <- ncvar_get( temp_file, iten1, iten2 , start=start, count=count)
# substuting missing values in the temporary data
#tmp.array[tmp.array == fillvalue] <- NA
# transforming in raster
file_raster <- raster(t(tmp.array), 
                      xmn=min(lon), 
                      xmx=max(lon), 
                      ymn=min(lat), 
                      ymx=max(lat), 
                      crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
# convert longitude [0 360] to [-180 180]
# NEED TO CHECK THIS COMMAND
file_raster <- flip(file_raster, direction='x')
# check the data
#str(file_raster)
#file_raster$layer
#file_raster %>% summary()
#file_raster %>% filter(!is.na())
#file_raster %>% length()

# keep only relevant informations
output<- shapefile[c("amc0010","munic", "geometry")] # dataframe with region and district in rows. 
crs(output)
# transform crs of maps
crs(file_raster)
crs(shapefile)
crs(output)
shapefile <- st_transform(shapefile, crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
output <- st_transform(output, crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
# Ensure extract from raster package
extract <- raster::extract
# And then extract the raster file information to shapefile using the code:
final_file<-extract(file_raster, 
                    shapefile, 
                    fun = mean,
                    na.rm=TRUE, 
                    df=F, 
                    small=T, 
                    sp=T,  
                    weights=TRUE, 
                    normalizedweights=TRUE)
# select variables to merge with the original shapefile
myvars <- c("munic", "amc0010", "layer")
to_merge <- final_file@data[myvars]
#names(to_merge)[names(to_merge) == "layer"] <- name_temp
# merge the data base by AMCs codes
output<-merge(output, to_merge, by=c('munic','amc0010'))
# generate variable depicting the date
# format date variable
# Convert character data to POSIXlt date and time
# "hours since 1900-1-1 0:0:0"
timeDatelt<- as.POSIXlt(time*3600, origin='1900-1-1 0:0:0')  
date <- as.Date(timeDatelt, )
date[i]
# compile date, codes of AMC, and layer in one dataset
yr <- c(date[i])
df <- data.frame(yr, output)
# save data as .csv
setwd(out_dir)
st_write(df, 
         paste0(out_dir, "/", yr, "_amc_rainfall.csv"), 
         row.names = TRUE,
         delete_dsn=TRUE) # overwrites
# print
print(i)
print(date[i])
# end of loop
}

# show a sample of map
#library(tmap)
#tm_shape(output)+tm_fill('layer', palette = "Blues", title = "Rainfall")

