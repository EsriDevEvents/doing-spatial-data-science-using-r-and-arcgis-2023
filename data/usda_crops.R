tool_exec <- function(in_params, out_params) {
  
  # Check and load required packages
  packages <- c("arcgisbinding", "rnassqs", "dplyr", "tidyr", "socviz") 
  
  installed_packages <- packages %in% rownames(installed.packages())
  if (any(installed_packages == FALSE)) {
    install.packages(packages[!installed_packages], repos = "https://CRAN.R-project.org")
  }
  invisible(lapply(packages, library, character.only = TRUE))
  
  arc.check_product()
  
  api_key <- Sys.getenv("NASS_API_KEY")
  nassqs_auth(key = api_key)
  
  # Get parameters
  crop = in_params[[1]] # "CARROTS"
  year_start = in_params[[2]] # 2012
  year_end = in_params[[3]] # 2017
  normalized = in_params[[4]] # T
  out_fc = out_params[[1]] # "C:/Data/Scratch/test.gdb"
  # T : Mean Acres Harvested Per 1000 County Acres (normalized)
  # F : Mean Acres Harvested (not normalized by county size)
  
  # Set request parameters
  params <- list(
    commodity_desc = crop,
    domaincat_desc = "NOT SPECIFIED",
    agg_level_desc = "county",
    #state_alpha = "MO",
    year = year_start:year_end
  )
  
  # Count records that will be returned by query (api won't provide > 50K)
  rec.count <- nassqs_record_count(params)
  rec.count$count
  
  if (rec.count$count == 0) {
    paste0("No records returned. Try another crop.")
    return()
  }
  
  # Query API for crop acreage
  if (rec.count$count < 49999) {
    dat1 <- nassqs_acres(params) %>%
      # filter out withheld data (see first link in References)
      # may want to modify how this is handled since withheld data != 0
      mutate(Value = na_if(as.character(Value), "                 (Z)")) %>%
      mutate(Value = na_if(as.character(Value), "                 (D)")) %>%
      # trim whitespace
      mutate(Value = as.numeric(gsub(",", "", Value)))  %>%
      # create county level fips code
      mutate(id = paste(state_fips_code, county_code, sep = "")) 
  } else {
    # glue together multiple years if dataset is too big
    data_list <- lapply(year_start:year_end, function(yr) {
      params[['year']] <- yr
      tryCatch(
        nassqs_acres(params),
        error = function(e)
          NULL
      )
    })
    # same munging as above, but with rbind
    # again, may want to modify how this is handled since withheld data != 0
    dat1 <- bind_rows(data_list) %>%
      mutate(Value = na_if(as.character(Value), "                 (Z)")) %>%
      mutate(Value = na_if(as.character(Value), "                 (D)")) %>%
      mutate(Value = as.numeric(gsub(",", "", Value)))  %>%
      mutate(id = paste(state_fips_code, county_code, sep = ""))
  }
  
  # Average across years
  dat2 <- dat1 %>%
    group_by(id) %>%
    summarize(Value = mean(Value, na.rm = TRUE)) %>%
    mutate(Value = replace_na(Value, 0))
    
  # get unit_layer shape info
  counties_meta <- arc.open("https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/USA_Counties_Generalized_Boundaries/FeatureServer/0")
  shape_info <- list(type="Polygon",WKID=arc.shapeinfo(counties_meta)$WKID)
  
  # join unit layer with unit_totest table
  counties_dat <- arc.select(counties_meta)
  counties_sf <- arc.data2sf(counties_dat)
  counties_merge <- merge(counties_sf, dat2, by.x='FIPS', by.y='id', all.x=T)
  
  # Normalize, if desired
  if (!normalized) {
    print('Not normalizing...')
  } else {
    counties_merge <- counties_merge %>%
      mutate(Value = (Value/SQMI)*100) # unit is selected crop acres per 100 sq mi
  }
  
  counties_merge$Shape__Area <- NULL
  counties_merge$Shape__Length <- NULL
  counties_merge$Value[is.na(counties_merge$Value)] <- 0
  
  # return feature class to the current map view
  arc.write(path = out_fc, data = counties_merge, 
            shape_info=shape_info, overwrite = T)
  
  return(out_params)
}


