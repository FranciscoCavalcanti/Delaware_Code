# -*- coding: utf-8 -*-
"""
@author: Francisco

Import shapefile of Brazilians AMC
"""

# library for geo data
import geopandas as gpd

# library for directory path
from pathlib import Path
import os

# what is the actual folder directory?
Path.cwd()

# changing directory
os.chdir('C:\\Users\\Francisco\\Dropbox\\data_sources\\Shapefiles\\AMC')
Path.cwd()

# what are the files in .shp format at the directory?
iten1 = Path(Path.cwd())
for textFilePathObj in iten1.glob('*.shp'):
    print(textFilePathObj) # Prints the Path object as a string.

# Reading AMC Shapefile
amc_data = gpd.read_file(r'AMCs0010.shp')

# investigating the data set
print(amc_data)
type(amc_data)
amc_data.head
amc_data.geometry.name

# plot the map
amc_data.plot()

# Keeping only relevant variables
amc_data.columns
# amc_data = amc_data[['amc0010', 'geometry']]
amc_data.columns

# calculating area
amc_data['area'] = amc_data.area
amc_data.columns

# # # # # # # # # # # # # # # 
# Changing projecting of map
# # # # # # # # # # # # # # # 

# to assign a CRS
amc_data.crs
current_crs = amc_data.crs

amc_data.crs = {'init' :'epsg:4326'}



amc_data.plot()
