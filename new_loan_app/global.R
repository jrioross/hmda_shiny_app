library(readr)
library(sf)
library(sp)

loan_data <- read_csv("../data/state_WA.csv")
census_data <- read_csv("../data/census_WA_county_data.csv")
census_shp <- read_sf("../data/tl_2021_us_county.shp")
census_shp <- census_shp %>% 
  filter(STATEFP == "53")


