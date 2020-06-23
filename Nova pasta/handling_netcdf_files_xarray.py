# -*- coding: utf-8 -*-
"""
Created on Sat May 16 17:17:27 2020

@author: Francisco

Source: https://towardsdatascience.com/handling-netcdf-files-using-xarray-for-absolute-beginners-111a8ab4463f

"""

import numpy as np
import matplotlib.pyplot as plt
import xarray as xr
import cartopy.crs as ccrs


# what is the actual folder directory?
Path.cwd()

# changing directory
os.chdir('C:\\Users\Francisco\\Dropbox\\data_sources\\Climatologia\\Willmott and Matsuura\\Precipitation V 5.01')
Path.cwd()


# Carregando netCDF
DS = xr.open_dataset('precip.mon.total.v501.nc')

open_dataset


# single file
dataDIR = '../data/ARM/twparmbeatmC1.c1.20050101.000000.cdf'
DS = xr.open_dataset(dataDIR)# OR multiple files
mfdataDIR = '../data/ARM/twparmbeatmC1.c1.*.000000.cdf'
DS = xr.open_mfdataset(mfdataDIR)

DS.var
DS.dims
DS.coords
DS.attrs

# Extract preciptation in z-coordinate (T_z)
# Select the altitude nearest to 500m above surface
# Drop NaN, convert to Celcius
da = DS.precip.sel(lon=1.75,method='nearest').dropna(dim='time') # or .ffill(dim='time')# Select data in 2000s
da = DS.precip.sel(lon=1.75,method='nearest')  # or .ffill(dim='time')# Select data in 2000s

da = da.sel(time=slice('2000-01-01', '2009-12-31'))
da_numpy = da.values


# Contract the DataArray by taking mean for each Year-Month
def mean_in_year_month(da):
    # Index of Year-Month starts at Jan 1991
    month_cnt_1991 = (da.time.dt.year.to_index() - 1991) * 12 + da.time.dt.month.to_index()
    # Assign newly defined Year-Month to coordinates, then group by it, then take the mean
    return da.assign_coords(year_month = month_cnt_1991).groupby('year_month').mean()


DS_new = xr.merge([da_1,da_2,da_3]).dropna(dim='year_month')