# Installing essential packages
# You only need to install the packages once.
install.packages("sf")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("viridis")
install.packages("tidyr")
install.packages("lubridate")


# Loading R bridge
library(arcgisbinding)
# Initialize connection to ArcGIS
arc.check_product()
# ?arc.portal_connect()
library(dplyr)
library(sf)
library(ggplot2)
library(viridis)
library(tidyr)
library(lubridate)



# Access data in a local gdb.
# Note: R doesn't like backward slash, so you need to edit the path a bit before 
data.path <- 'C:/R_BridgeSeminar_2023/Project/R_ArcGIS_Bridge_PreCon_2023.gdb/state_Buffer'
# Define the metadata
data.metadata <- arc.open(data.path)
data.metadata
# Read data and project the data on the fly
data.arc.format <- arc.select(data.metadata,sr = 3857)
# Convert data to a sf object
data.sf.format <- arc.data2sf(data.arc.format)
# Visualize the data
ggplot() + geom_sf(data = data.sf.format,fill = 'orange',color = 'orange')
# Add a new column to the dataframe
data.sf.format$newField <- "Hello the world"
# Write the data to the file geodatabase
arc.write('C:/R_BridgeSeminar_2023/Project/R_ArcGIS_Bridge_PreCon_2023.gdb/new_state_buffer',data.sf.format,overwrite = T)


# Remote data
# Access Unemployment data on Living Atlas 
# Data info: https://www.arcgis.com/home/item.html?id=993b8c64a67a4c6faa44a91846547786
data.url <- 'https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/BLS_Monthly_Unemployment_Current_14_Months/FeatureServer/2'
# Access the meta data
data.open <- arc.open(data.url)
data.open
# Load dataset to an arc.data object
# You can specify the fields, add query and project data on the fly
data <- arc.select(data.open, where_clause = "State = 'California'",sr = 3857)
# Convert to sf
data.sf <- arc.data2sf(data)
# See basic data info
head(data.sf)
str(data.sf)
dim(data.sf)
# st_crs(data.sf)
colnames(data.sf)

## Plot GGPlot
p <- ggplot() +
  geom_sf(data = data.sf, aes(fill = PctUnemployed_CurrentMonth)) + 
  scale_fill_viridis() +
  labs(title = "% unemployment in CA") + 
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank())

p


# Simple data engineering and visualization
basic.info <- c("OBJECTID","COUNTYNS","GEOID","NAME","fips")
data.singleCounty <- data.sf %>% 
  filter(NAME == 'San Bernardino County') %>% 
  select(all_of(basic.info),starts_with("PctUnemployed")) %>% 
  rename("2022/12" = 6,
         "2022/11" = 7,
         "2022/10" = 8,
         "2022/9" = 9,
         "2022/8" =10,
         "2022/7" = 11,
         "2022/6" = 12,
         "2022/5" = 13,
         "2022/4" = 14,
         "2022/3" = 15,
         "2022/2" = 16,
         "2022/1" = 17,
         "2021/12" = 18,
         "2021/11" = 19) %>% 
  gather(TimeSting, UnemploymentRate, 6:19) %>% 
  mutate(time = ym(TimeSting))

ggplot(data = data.singleCounty, aes(time,UnemploymentRate))+geom_line()



