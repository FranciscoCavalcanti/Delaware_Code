# -*- coding: utf-8 -*-
"""
Created on Sat May  2 11:29:11 2020

@author: Francisco

Import GIS data to Python
"""

"""
Recomended references:
https://geographicdata.science/book/notebooks/03_spatial_data_processing.html    
"""
#################
# PREAMBLE
#################


# library for numbers and calculation
import numpy as np

# library for geo data
import pandas as pd
import geopandas as gpd

# library for creating visualizations 
import matplotlib.pyplot as plt

# library for directory path
from pathlib import Path
import os

# library for database on .nc format
from netCDF4 import Dataset

#################
# Call the data
################

# what is the actual folder directory?
Path.cwd()

# changing directory
os.chdir('C:\\Users\Francisco\\Dropbox\\data_sources\\Climatologia\\Willmott and Matsuura\\Precipitation V 5.01')
Path.cwd()

# set a directory path

# what are the files in .nc format at the directory?
iten1 = Path(Path.cwd())
for textFilePathObj in iten1.glob('*.nc'):
    print(textFilePathObj) # Prints the Path object as a string.

# importing data
data = Dataset(r'precip.mon.total.v501.nc', 'r')

#################
# Study the data
################

# investigating the data set
print(data)
type(data)

# displaying the names of variables
print(data.variables.keys)
print(data.variables)

# Acessing the varialbes
lat = data.variables['lat']
print(lat)

lon = data.variables['lon']
print(lon.long_name)

time = data.variables['time']
print(time)

precip = data.variables['precip']
print(precip)

########################
# Manipulating the data
########################

# Acessing the data from the variables
time_data = data.variables['time'][:]
print(time_data)

lon_data = data.variables['lon'][:]
print(lon_data)

lat_data = data.variables['lat'][:]
print(lat_data)

precip_data = data.variables['precip'][:]
print(precip_data)

"""
 Rotacionar nossas variáveis de interesse 
 para que possam ficar compatíveis com nosso dado vetorial. 
 Vamos utilizar a seguinte função:
"""

def rotImg(Img):
    """Rotaciona a imagem IMg do wrf para o padrao Norte  superior"""
    Rep = np.rot90(T,2)
    Rep = np.flip(Rep,1)
    return Rep

"""
Aplicando
"""

time_data = rotImg(time_data)
lon_data = rotImg(lon_data)
lat_data = rotImg(lat_data)
precip_data = rotImg(precip_data)



# manipulation string variables
data.variables['time'].units
data.variables['time'].units[12:21]
data.variables['time'].units[16:21]
data.variables['time'].units[12:16]



# Save the file as ESRI Shapefile
data_shp.to_file(filename = 'test.shp', drive = 'ESRI Shapefile')


# Transforming in GeoDataFrame
type(data) # netCDF4._netCDF4.Dataset
data_gdf = gpd.GeoDataFrame(data, geometry = gpd.points_from_xy(data['lon_data'], data['lat_data']) )

help(gpd.GeoDataFrame)


# Storing in lat and lon of AMC, into variables
lat_amc = 12.4124
lon_amc = 22.444




# Squared difference of lat and lon
## !ERROR HERE!
"""
sq_diff_lat = (lat - lat_amc)**2
sq_diff_lon = (lon - lon_amc)**2
"""

# Identifying the index of the minimum value of lat and lon
"""
min_index_lat = sq_diff_lat.argmin()
min_index_lon = sq_diff_lon.argmin()
"""

#####################################
# Creating an empty pandas dataframe
####################################

# taking the starting date of the analysis
starting_date = data.variables['time'].units[12:21]

# taking the ending date of the analysis
ending_date = '2017' + data.variables['time'].units[16:21]

# collecting all dates
data_range = pd.date_range(start = starting_date, end = ending_date )

# dataframe 
df = pd.DataFrame(0, columns = ['Precipitation'], index= data_range)

# what is in the observation 1?
df.iloc[0]

# what is in the observation 3?
df.iloc[2]


data.variables['time']
data.variables['time'].size
dt = np.arange(0, data.variables['time'].size)

for top in dt:
    df.iloc[top] = precip[top, min_index_lat, min_index_lon ]

# Save in csv
df.to_csv('precipitation.csv')
    
    
cities = gpd.read_file('C:\Users\Francisco\Dropbox\data_sources\Climatologia\Willmott and Matsuura\Terrestrial Precipitation (V 5.01)/precip_2017.tar.gz', driver='GeoJSON')

# plot shapefile
cities.plot(cmap = 'jet', column = 'var', figsize = (10,10) )


# save the geodataframe to a .shp (Shapefile)
cities.to_file('C:\Users\Francisco\Dropbox\data_sources\Climatologia\test.shp')

df = pd.read_csv("../Terrestrial Precipitation 1900-2017 Gridded Monthly Time Series (V 5.01)/precip.2007")
