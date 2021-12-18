library(tidyverse)
library(shiny)
library(fresh)
library(shinyjs)
library(leaflet)
library(leaflet.extras)
library(sf)
library(DT)
library(shinyDataFilter)

shinyServer(function(input, output) {
  
  observeEvent(input$filterButton, {
    toggle('filterPanel')
  })
  
  output$mymap <- renderLeaflet({
    draw_base_map()
  })
  
  rv <- reactiveValues(scope = "county")

  observeEvent(input$mymap_zoom, {
    rv$scope <- check_zoom(input$mymap_zoom)
  })

  my_sf <- reactive({
    census_data %>%
      filter(scope == rv$scope)
  })

  observeEvent(rv$scope, {
    update_shapes("mymap", my_sf())
  })

  observeEvent(my_sf(), {
    draw_map_legend("mymap", my_sf())
  })
  
  filtered_data_1 <- callModule(
    shiny_data_filter,
    "data_filter_1",
    data = hmda_data,
    verbose = FALSE)
  
  filtered_data_2 <- callModule(
    shiny_data_filter,
    "data_filter_2",
    data = hmda_data,
    verbose = FALSE)

  filtered_data_3 <- callModule(
    shiny_data_filter,
    "data_filter_3",
    data = hmda_data,
    verbose = FALSE)
  
  filtered_data_4 <- callModule(
    shiny_data_filter,
    "data_filter_4",
    data = hmda_data,
    verbose = FALSE)
  
  output$plot_1 <- renderPlot({
    filtered_data_1() %>%
      ggplot(aes(x = `Loan Amount`)) +
      geom_histogram()
  })
  
  output$plot_2 <- renderPlot({
    ggplot() +
      geom_boxplot(data = filtered_data_1(), aes(x = "Group 1", y = `Loan Amount`, color = "Group 1")) +
      geom_boxplot(data = filtered_data_2(), aes(x = "Group 2", y = `Loan Amount`, color = "Group 2")) +
      scale_y_log10()
  })

  output$data_table <- renderDT(
    server = TRUE, {
    datatable(
      filtered_data_3(),
      style = 'bootstrap',
      rownames = FALSE,
      selection = "none",
      extensions = c("Buttons"),
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        autoWidth = TRUE,
        scrollX = TRUE,
        dom = 'lrtip',
        buttons = list(
          list(
            extend = 'collection',
            buttons = c('columnsToggle'),
            text = 'Columns'
          )
        )
      )
    )
  })
  
  output$download <- downloadHandler(
    filename = 'download.csv', 
    content = function(file) {
      write.csv(filtered_data_3(), file, row.names = FALSE)
  })
})
