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
  
  output$plot_1 <- renderPlotly({
    filtered_data_1() %>%
      ggplot(aes(x = `Loan Amount`)) +
      geom_histogram()
  })
  
  output$plot_2 <- renderPlotly({
    p2 <- ggplot() +
      geom_boxplot(data = filtered_data_1(), aes(x = "Group 1", y = `Loan Amount`, color = "Group 1")) +
      geom_boxplot(data = filtered_data_2(), aes(x = "Group 2", y = `Loan Amount`, color = "Group 2")) +
      scale_y_log10()
    
    ggplotly(p2)
  })
  
  output$plot_3 <- renderPlotly({
    filtered_data_12 <- rbind(filtered_data_1() %>% mutate(Group = "Group 1"),
                             filtered_data_2() %>% mutate(Group = "Group 2"))
    
    p3 <- ggplot() +
      geom_bar(data = filtered_data_12, aes(y = `Action Taken`, fill = `Group`), position = 'dodge') +
      scale_y_discrete(limits = rev)
      #geom_bar(data = filtered_data_2(), aes(x = "Group 2", fill = `Action Taken`), position = 'dodge')
    
    ggplotly(p3)
  })
  
  output$plot_4 <- renderPlotly({
    filtered_data_1_long <- filtered_data_1() %>%
                              pivot_longer(cols = c(`Derived Race`, `Derived Ethnicity`, `Derived Sex`, `Applicant Age`), 
                                           names_to = "Demographic Type",
                                           values_to = "Demographic Value")
    
    filtered_data_2_long <- filtered_data_2() %>%
                              pivot_longer(cols = c(`Derived Race`, `Derived Ethnicity`, `Derived Sex`, `Applicant Age`), 
                                           names_to = "Demographic Type",
                                           values_to = "Demographic Value")
    
    p4 <- ggplot() +
      geom_bar(data = filtered_data_1_long, aes(x = "Group 1", fill = `Demographic Value`), position = 'fill') +
      geom_bar(data = filtered_data_2_long, aes(x = "Group 2", fill = `Demographic Value`), position = 'fill') +
      facet_wrap(~`Demographic Type`, ncol = 1)
    
    ggplotly(p4, height = 800)
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
