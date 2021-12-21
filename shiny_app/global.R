library(tidyverse)
library(shiny)
library(fresh)
library(shinyjs)
library(leaflet)
library(leaflet.extras)
library(sf)
library(DT)
library(shinyDataFilter)
library(plotly)
library(patchwork)
library(leafpop)
library(shinycssloaders)

# Read in census data
census_data <- as.tibble(readRDS("data/census_data.rds"))

# Read in HMDA data
hmda_data <- readRDS("data/hmda_data_filtered.rds")

# Include column of each lender's annual amount lent for the given activity year
hmda_data <- hmda_data %>%
  inner_join(hmda_data %>% 
               group_by(`Institution Name`, Year) %>% 
               summarize(`Annual Money Lent` = sum(`Loan Amount`))
  )

# Initialize leaflet map function
draw_base_map <- function() {
  leaflet(
    options = leafletOptions(minZoom = 5, maxZoom = 14)
  ) %>%
    addProviderTiles("CartoDB.Positron") %>%
    setView(lng = -120.7401, lat = 47.7511, zoom = 6) %>%
    addResetMapButton() %>%
    addEasyButton(
      easyButton(icon = htmltools::HTML("<i class='fas fa-filter'></i>"),
                 title = "Filter",
                 onClick = JS("function(btn, map) {
                              Shiny.onInputChange('filterButton', '1');
                              Shiny.onInputChange('filterButton', '2');
                              }")
      )
    )
}

pal <- colorNumeric(palette = "viridis", domain = NULL)

# Update choropleth function
update_choropleth <- function(mymap, census_data) {
  
  census_data$label <- 
    paste0("<b>", census_data$NAME, "</b><br>",
           "Population: ", census_data$population) %>%
    lapply(htmltools::HTML)
  
  leafletProxy(mymap, data = census_data) %>% 
    clearShapes() %>%
    addPolygons(
      data = census_data$geometry,
      layerId = census_data$NAME,
      group = "name",
      stroke = TRUE,
      weight = 1,
      opacity = 1,
      color = "white",
      fillOpacity = 0.6,
      fillColor = pal(census_data$population),
      label = census_data$label,
      # popup = popupGraph(census_data$plots),
      highlight = highlightOptions(
        weight = 3,
        fillOpacity = 0.8,
        color = "#666",
        bringToFront = FALSE)
    )
}

# Draw map legend function
draw_map_legend <- function(mymap, census_data) {
  leafletProxy(mymap, data = census_data) %>%
    clearControls() %>%
    addLegend(
      "bottomleft",
      pal = pal, 
      values = ~ population,
      title = ~ "Population",
      opacity = 1
    )
}

# Check zoom level
check_zoom <- function(zoom) {
  case_when(
    zoom <= 6 ~ "state",
    zoom <= 7 ~ "county",
    TRUE ~ "tract"
  )
}
