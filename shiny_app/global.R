library(tidyverse)
library(shiny)
library(fresh)
library(shinyjs)
library(leaflet)
library(leaflet.extras)
library(sf)
library(DT)
library(shinyDataFilter)

census_data <- readRDS("data/census_data.rds")

hmda_data <- readRDS("data/hmda_data_filtered.rds") 

# Include column of each lender's annual amount lent for the given activity year
hmda_data <- hmda_data %>%
  inner_join(hmda_data %>% 
               group_by(`Institution Name`, Year) %>% 
               summarize(`Annual Money Lent` = sum(`Loan Amount`))
             )

draw_base_map <- function() {
  leaflet(
    options = leafletOptions(minZoom = 6, maxZoom = 14)
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

update_shapes <- function(mymap, my_data) {
  leafletProxy(mymap, data = my_data) %>% 
    clearShapes() %>%
    addPolygons(
      data = my_data$geometry,
      stroke = TRUE,
      weight = 1,
      opacity = 1,
      color = "white",
      fillOpacity = 0.6,
      fillColor = pal(my_data$population),
      # label = ~ lapply(tooltip, HTML),
      highlight = highlightOptions(
        weight = 3,
        fillOpacity = 0.8,
        color = "#666",
        bringToFront = FALSE)
    )
}

draw_map_legend <- function(mymap, df) {
  leafletProxy(mymap, data = df) %>%
    clearControls() %>%
    addLegend(
      "bottomleft",
      pal = pal, 
      values = ~ population,
      title = ~ "Population",
      opacity = 1
    )
}

check_zoom <- function(zoom) {
  case_when(
    zoom <= 7 ~ "county",
    TRUE ~ "tract"
  )
}
