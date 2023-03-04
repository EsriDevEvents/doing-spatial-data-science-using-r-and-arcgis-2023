library(arcgisbinding)
library(raster)
library(rgdal)
library(RColorBrewer)

arc.check_product()

# Read image service from Living Atlas: Sentinel2 Land Cover
raster.url <- 'https://env1.arcgis.com/arcgis/rest/services/Sentinel2_10m_LandCover/ImageServer'
raster.open <- arc.open(raster.url)

bounding.box <- c(-108.413086,25.760320,-92.944336,38.754083) # EPSG:4326 (WGS84), central US

arc_raster <- arc.raster(raster.open, nrow = 500, ncol = 500, 
                         resample_type="NearestNeighbor", 
                         extent=bounding.box)
arc_raster
r_raster <- as.raster(arc_raster)
r_raster <- as.factor(r_raster) ## These are categorical classes from land use

# Read vector data: US states
data.url <- 'https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/USA_Census_States/FeatureServer/0'
data.open <- arc.open(data.url)
data <- arc.select(data.open)
data.sp <- arc.data2sp(data)

# Select color palette for land cover
my.palette <- brewer.pal(n = 11, name = "Set3")

# Plot raster and vector data
plot(r_raster, 
     breaks = c(1,2,4,5,7,8,9,10,11),
     ext=bounding.box, col = my.palette) 
plot(data.sp, add=TRUE)

