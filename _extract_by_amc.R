# packages
library(raster) # raster
library(sf) # vetor
library(tidyverse) # varios pacotes
library(cptcity) # paleta de cores
library(patchwork) # combina graficos



# import data -------------------------------------------------------------

# directory
data_ncdf_dir   <-'C:/Users/Francisco/Dropbox/data_sources/Climatologia/Willmott and Matsuura/Temperature V 5.01'
setwd(data_ncdf_dir)
getwd()

# worldclim
# import
var <- dir(pattern = "air.mon.mean.v501.nc") %>% 
  raster::stack()
var

# map
plot(var$X1900.01.01.00.00.00)
extent(var)

# convert longitife [0 360] to [-180 180]
# this a common issue in statelite data
var = rotate(var)
extent(var)

# map
var$X1900.01.01.00.00.00

var$X1900.01.01.00.00.00 %>% # selecionei a X1900.01.01.00.00.00
  raster::rasterToPoints() %>% # converti para pontos (lon, lat, val)
  head() # retorno 6 linhas

var$X1900.01.01.00.00.00 %>% 
  raster::rasterToPoints() %>% 
  tibble::as_tibble()

map_raster_X1900.01.01.00.00.00 <- var$X1900.01.01.00.00.00 %>% 
  raster::rasterToPoints() %>% 
  tibble::as_tibble() %>% 
  ggplot() + 
  aes(x = x, y = y, fill = X1900.01.01.00.00.00) +
  geom_raster() +
  scale_fill_viridis_c() +
  coord_sf() +
  theme_minimal() +
  labs(x = "longitude", y = "latitude", fill = "X1900") +
  theme(legend.position = c(.8, .2))
map_raster_X1900.01.01.00.00.00

# atlantic forest
data_shp_dir  <-'C:/Users/Francisco/Dropbox/data_sources/Shapefiles/AMC/AMCs 1985-06'
setwd(data_shp_dir)
af <- sf::st_read("AMCs 1985-06.shp")
af
extent(af)

map_af <- ggplot() + 
  geom_sf(data = af) +
  coord_sf() +
  theme_minimal() +
  labs(x = "longitude", y = "latitude")
map_af

# extract values from raster to points ------------------------------------
# extract values
da_vector_bio <- raster::extract(var, af)
da_vector_bio
head(da_vector_bio)

# extract values and bind cols
da_vector_bio <- raster::extract(var, af) %>% 
  tibble::as_tibble() %>% 
  dplyr::bind_cols(af, .)
da_vector_bio

# map bio01
map_bio01 <- ggplot() + 
  geom_sf(data = af) +
  geom_sf(data = da_vector_bio, aes(fill = X1900.01.01.00.00.00), shape = 21, size = 4, alpha = .5) +
  scale_fill_gradientn(colors = cptcity::cpt(pal = cptcity::find_cpt("temperature")[2], n = 30)) +
  coord_sf() +
  theme_minimal() +
  labs(x = "longitude", y = "latitude", size = "Número de espécies") +
  theme(legend.position = c(.8, .2))
map_bio01

# map bio12
map_bio12 <- ggplot() + 
  geom_sf(data = af) +
  geom_sf(data = da_vector_bio, aes(fill = bio12), shape = 21, size = 4, alpha = .5) +
  scale_fill_gradientn(colors = cptcity::cpt(pal = cptcity::find_cpt("precipitation")[2], n = 30)) +
  coord_sf() +
  theme_minimal() +
  labs(x = "longitude", y = "latitude", size = "Número de espécies") +
  theme(legend.position = c(.8, .2))
map_bio12

# statistics --------------------------------------------------------------
# histogram bio01
hist_bio01 <- da_vector_bio %>% 
  ggplot() +
  aes(x = bio01) +
  geom_histogram(color = "white", bins = 15, fill = cptcity::cpt(pal = cptcity::find_cpt("temperature")[2], n = 15)) +
  theme_minimal() +
  labs(x = "BIO01", y = "Frequência Absoluta")
hist_bio01

# histogram bio12
hist_bio12 <- da_vector_bio %>% 
  ggplot() +
  aes(x = bio12) +
  geom_histogram(color = "white", bins = 30, fill = cptcity::cpt(pal = cptcity::find_cpt("precipitation")[2], n = 30)) +
  theme_minimal() +
  labs(x = "BIO12", y = "Frequência Absoluta")
hist_bio12

# combine - patchwork
map_bio01 + hist_bio01
map_bio12 + hist_bio12

(map_bio01 / hist_bio01) | (map_bio12 / hist_bio12)
(map_bio01 | hist_bio01) / (map_bio12 | hist_bio12)

# histograms with facet ---------------------------------------------------
# wide to long
da_vector_bio_long <- da_vector_bio %>% 
  sf::st_drop_geometry() %>% 
  dplyr::select(ID, contains("bio0"), contains("bio1")) %>% 
  tidyr::pivot_longer(cols = -ID, names_to = "bios", values_to = "values")
da_vector_bio_long

# histogram
hist_facet <- da_vector_bio_long %>% 
  ggplot() +
  aes(x = values) +
  geom_histogram(color = "white", bins = 30, 
                 fill = c(rep(cptcity::cpt(pal = cptcity::find_cpt("temperature")[2], n = 30), 11),
                          rep(cptcity::cpt(pal = cptcity::find_cpt("precipitation")[2], n = 30), 8))) +
  facet_wrap(vars(bios), scales = "free") +
  theme_bw() +
  labs(x = "Valores", y = "Frequência Absoluta")
hist_facet

# end ---------------------------------------------------------------------
