# -*- coding: utf-8 -*-
"""
Created on Mon Apr 27 14:52:17 202d0

@author: Francisco

Download de Mapas do Brasil

Source: https://github.com/ipeaGIT/geobr

"""

"""
For windows users

I run in the Anacond Prompt:

conda install -c conda-forge import patoolib


"""

# library for webscrapping
import requests

# library for numbers and calculation
import numpy as np

# library for directory path
from pathlib import Path
import os



# website where the data is stored
url = 'ftp://ftp.cdc.noaa.gov/Datasets/udel.airt.precip/air.mon.mean.v501.nc'

# what is the actual folder directory?
Path.cwd()

# changing directory
os.chdir('C:\\Users\Francisco\\Dropbox\\data_sources\\Climatologia\\Willmott and Matsuura\\Precipitation V 5.01')
Path.cwd()


r = requests.get(url, 
                 allow_redirects = True )

open(str(year)'.nc', 'wb').write(r.content)


username = 'francisco.lima.cavalcanti@gmail.com'
password = 'yyyy'

"""
# loop over years
years = np.arange(1990, 2018)
print(years)

for year in years:
    url = 'ftp://ftp.cdc.noaa.gov/Datasets/udel.airt.precip/air.mon.mean.v501'+str(year)'.nc'
    r = requests.get(url, auth = (usarname, password), allow_redirects = True )
    open(str(year)'.nc', 'wb').write(r.content)
"""
    

"""
# open zipfiles
for zipfiles in os.listdir(r'C:\Users\Francisco\Dropbox\data_sources\Climatologia\Willmott and Matsuura\Precipitation V 5.01'):
    print(zipfiles)
    if zipfiles[-3, ] == '.gz':
        patoolib.extract_arquive(zipfiles, oudir = r:'C:\Users\Francisco\Dropbox')
"""

"""
# put the .nc in the final name of the arquive
for extracted_files in os.listdir(r'C:\Users\Francisco\Dropbox\data_sources\Climatologia\Terrestrial Precipitation - 1900-2010 Gridded Monthly Time Series\Terrestrial Precipitation 1900-2017 Gridded Monthly Time Series (V 5.01)'):
    # change the directory
    os.chdir(r'C:\Users\Francisco\Dropbox\data_sources\Climatologia\Terrestrial Precipitation - 1900-2010 Gridded Monthly Time Series\Terrestrial Precipitation 1900-2017 Gridded Monthly Time Series (V 5.01)')
    os.rename(extracted_files, extracted_files+'.nc')
"""
"""
# Python, reading the data as a geopandas object
from geobr import read_municipality

# Read specific municipality at a given year
mun = read_municipality(code_muni=1200179, year=2017)

# Read all municipalities of given state at a given year
mun = read_municipality(code_muni=33, year=2010) # or
mun = read_municipality(code_muni="RJ", year=2010)

# Read all municipalities in the country at a given year
mun = read_municipality(code_muni="all", year=2018)
"""