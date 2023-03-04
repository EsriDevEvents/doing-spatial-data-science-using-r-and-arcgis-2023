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

install.packages("reticulate")
library(reticulate)
# Configure the python to use
reticulate::use_python('C:/ArcGIS/bin/Python/envs/arcgispro-py3/python.exe', required = T)

# import arcpy
ARCPY <- import('arcpy')

# read remote feature service
ca.unemployment <- 'https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/BLS_Monthly_Unemployment_Current_14_Months/FeatureServer/2'
# Run a Geoprocessing tool
ARCPY$stats$OptimizedHotSpotAnalysis(ca.unemployment,'C:/R_BridgeSeminar_2023/Project/R_ArcGIS_Bridge_PreCon_2023.gdb/FHS01',
                                     "Unemployed_CurrentMonth","COUNT_INCIDENTS_WITHIN_FISHNET_POLYGONS",
                                     NULL,NULL,NULL,NULL,"100 MilesInt")


