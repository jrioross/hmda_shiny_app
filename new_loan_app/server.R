library(shiny)
library(leaflet)
library(readr)
library(sf)
library(sp)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$mymap <- renderLeaflet({
      leaflet() %>% 
        addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(data = census_shp)
        
    })

})
