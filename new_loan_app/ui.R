library(shiny)
library(leaflet)


shinyUI(fluidPage(
  fluidRow(
    column(width = 8,
           leafletOutput("mymap"), height = "100%"),
    column(width = 4,
           fluidRow(),
           fluidRow(
             radioButtons("geographic_area", "Select map level:", choices = c("County", "Census Tract")),
             selectInput("choro_variable", "Select Choropleth Filter:",
                         choices = c(variable.names(loan_data))))
    )
  )
  
))