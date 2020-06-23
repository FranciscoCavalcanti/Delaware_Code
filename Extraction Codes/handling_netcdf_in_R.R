
# From CRAN
install.packages("geobr")
install.packages("raster")
install.packages("sf")
install.packages("maptools")
install.packages("rgdal")
install.packages("ncdf4")
install.packages("rasterVis")

####################
# load library
####################
library(sf)
library(geobr)
library(maptools)
library(rgdal)
library(ncdf4)
library(raster)
library(rasterVis)

# set file path
amc_path <- "C:\\Users\\Francisco\\Dropbox\\data_sources\\Shapefiles\\AMC\\"
amc_name <- "AMCs0010.shp"
amc_file <- paste(amc_path, amc_name, sep="")
amc_file

# read amc shapefile
#amc_shp <- readShapeLines(amc_file)
#amc_shp <- readShapePoly(amc_file) # read shapefile
amc_shp = readOGR(amc_file)


# check stations shapefile
class(amc_shp)
summary(amc_shp)
crs(amc_shp)

# check the data
extent(amc_shp)
crs(amc_shp)

# plot map
plot(amc_shp)

# read potential natural vegetation data sage_veg30.nc:
# netcdf_file <- "C:\\Users\\Francisco\\Dropbox\\data_sources\\Climatologia\\Willmott and Matsuura\\Precipitation V 5.01\\precip.mon.total.v501.nc"
# netcdf <- raster(netcdf_file)
# netcdf

# source: https://stackoverflow.com/questions/50204653/how-to-extract-the-data-in-a-netcdf-file-based-on-a-shapefile-in-r

# set file path
netcdf_path <- "C:\\Users\\Francisco\\Dropbox\\data_sources\\Climatologia\\Willmott and Matsuura\\Precipitation V 5.01\\"
netcdf_name <- "precip.mon.total.v501.nc"
netcdf_file <- paste(netcdf_path, netcdf_name, sep="")
netcdf_file

# call netcdf file
netcdfdata = brick(netcdf_file) # read netcdf file

# check the data
extent(netcdfdata)
crs(netcdfdata)

# transform crs of maps
crs(netcdfdata)
crs(amc_shp)
shp = spTransform(amc_shp, crs(netcdfdata))
amc_shp = spTransform(amc_shp, crs(netcdfdata))

crs(shp)
extent(amc_shp)

# convert longitife [0 360] to [-180 180]
netcdfdata = rotate(netcdfdata)

# mask map
output<-mask(netcdfdata, amc_shp) # mask netcdf data using shp
output<-mask(amc_shp, netcdfdata) # mask netcdf data using shp
crs(output)
extent(output)

# convert in data
output_df = as.data.frame(output[[80]], xy=TRUE)
head(output_df)

writeRaster(output, "new.nc",
			overwrite=TRUE, 
			format="CDF", 
			varname="tmx", 
			varunit="degrees celcius", 
			longname="maximum temperature", 
			xname="lon", 
			yname="lat", 
			zunit="numeric") # save output in netcdf format (nw.nc)

pre1.df = as.data.frame(pre1.mask[[1]], xy=TRUE)



crs(amc_shp)
shp = spTransform(shp, crs(netcdfdata))
shp = spTransform(amc_shp, crs(netcdfdata))

shp = spTransform(netcdfdata, crs(amc_shp))

pre1.mask = mask(netcdfdata, shp)


mapTheme <- rasterTheme(region=rev(brewer.pal(8,"Greens")))

levelplot(netcdfdata, margin=F, par.settings=mapTheme,
          main="Potential Natural Vegetation")