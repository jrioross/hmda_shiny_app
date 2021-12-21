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

shinyServer(function(input, output) {
  
  ### VISUALIZE TAB ###
  
  # Render leaflet map
  output$mymap <- renderLeaflet({
    draw_base_map()
  })
  
  # Create scope reactive value
  rv <- reactiveValues(scope = "state")
  
  # Update scope based on zoom level 
  observeEvent(input$mymap_zoom, {
    rv$scope <- check_zoom(input$mymap_zoom)
  })
  
  # Filter census data based on scope
  my_sf <- reactive({
    census_data %>%
      filter(scope == rv$scope)
  })
  
  # Update choropleth based on scope
  observeEvent(rv$scope, {
    update_choropleth("mymap", my_sf())
  })
  
  # Update map legend based on scope
  observeEvent(my_sf(), {
    draw_map_legend("mymap", my_sf())
  })

  # HMDA data filter for visualize tab
  visualize_filter <- callModule(
    shiny_data_filter,
    "visualize_filter",
    data = hmda_data,
    verbose = FALSE)
  
  # Toggle filter panel based on filter button click
  observeEvent(input$filterButton, {
    toggle('filterPanel')
  })
  
  observeEvent(input$mymap_shape_click, { 
    showModal(modalDialog(
      plotOutput("plot"),
      title = input$mymap_shape_click[1],
      fade = F,
      easyClose = T,
      footer = NULL
    ))
  })
  
  output$plot <- renderPlot({
    census_data %>%
      filter(NAME == input$mymap_shape_click[1]) %>%
      select(NAME, white, black, `american indian`, asian, `pacific islander`, `other race`, `two or more races`) %>%
      pivot_longer(!NAME, names_to = "Race", values_to = "Population") %>%
      ggplot() + geom_col(aes(x = Race, y = Population))
  })
  
  ### COMPARE TAB ###
  
  # HMDA data filter 1 for compare tab
  compare_filter_1 <- callModule(
    shiny_data_filter,
    "compare_filter_1",
    data = hmda_data,
    verbose = FALSE)
  
  # HMDA data filter 2 for compare tab
  compare_filter_2 <- callModule(
    shiny_data_filter,
    "compare_filter_2",
    data = hmda_data,
    verbose = FALSE)
  
  observeEvent(input$go, {
    
    output$plot_amounts <- renderPlotly({
      isolate(
      p2 <- ggplot() +
        geom_boxplot(data = compare_filter_1(), aes(x = "Group 1", y = `Loan Amount`, color = "Group 1")) +
        geom_boxplot(data = compare_filter_2(), aes(x = "Group 2", y = `Loan Amount`, color = "Group 2")) +
        scale_y_log10()
      )
      ggplotly(p2)
    })
    
    output$plot_action <- renderPlotly({
      compare_filter_12 <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                                 compare_filter_2() %>% mutate(Group = "Group 2"))
      
      p3 <- ggplot() +
        geom_bar(data = compare_filter_12, aes(y = `Action Taken`, fill = `Group`), position = 'dodge') +
        scale_y_discrete(limits = rev)
      #geom_bar(data = compare_filter_2(), aes(x = "Group 2", fill = `Action Taken`), position = 'dodge')
      
      ggplotly(p3)
    })
    
    output$plot_4 <- renderPlotly({
      
      # compare_filter_12 <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
      #                            compare_filter_2() %>% mutate(Group = "Group 2"))
      
      #This first set of code creates a facet with one long legend
      # compare_filter_12_long <- compare_filter_12 %>%
      #                           pivot_longer(cols = c(`Derived Race`, `Derived Ethnicity`, `Derived Sex`, `Applicant Age`),
      #                                        names_to = "Demographic Type",
      #                                        values_to = "Demographic Value")
      
      
      # p4 <- ggplot() +
      #   geom_bar(data = compare_filter_12_long, aes(x = `Demographic Value`, fill = Group), position = 'dodge') +
      #   facet_wrap(~`Demographic Type`, ncol = 1)
      #
      # ggplotly(p4, height = 760)
      
      # Let's use patchwork to make four separate plots (with their own legends) that then get patched together
      compare_filter_12 <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                                 compare_filter_2() %>% mutate(Group = "Group 2"))
      
      ## Make each separate plot
      p4race <- ggplot() +
        geom_bar(data = compare_filter_12, aes(x = `Derived Race`, fill = `Group`), position = 'dodge')
      figr <- ggplotly(p4race)
      
      p4ethnicity <- ggplot() +
        geom_bar(data = compare_filter_12, aes(x = `Derived Ethnicity`, fill = `Group`), position = 'dodge') +
        scale_fill_discrete(breaks = "none")
      fige <- ggplotly(p4ethnicity, showlegend = FALSE)
      
      
      p4sex <- ggplot() +
        geom_bar(data = compare_filter_12, aes(x = `Derived Sex`, fill = `Group`), position = 'dodge') +
        scale_fill_discrete(breaks = "none")
      figs <- ggplotly(p4sex)
      
      
      p4age <- ggplot() +
        geom_bar(data = compare_filter_12, aes(x = `Applicant Age`, fill = `Group`), position = 'dodge') +
        scale_fill_discrete(breaks = "none")
      figa <- ggplotly(p4age)
      
      
      ## Patch them together vertically
      subplot(figr, fige, figs, figa, nrows = 4) %>% layout(height = 760)
    })
    
    output$plot_race <- renderPlotly({
      compare_filter_12 <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                                 compare_filter_2() %>% mutate(Group = "Group 2"))
      
      p4race <- ggplot() +
        geom_bar(data = compare_filter_12, aes(x = Race, fill = `Group`), position = 'dodge')
      figr <- ggplotly(p4race) %>% layout(legend = list(orientation = "h", xanchor = "right", yanchor = "top", x = 1, y = 1))
    })
    
    output$plot_ethnicity <- renderPlotly({
      compare_filter_12 <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                                 compare_filter_2() %>% mutate(Group = "Group 2"))
      
      p4ethnicity <- ggplot() +
        geom_bar(data = compare_filter_12, aes(x = Ethnicity, fill = `Group`), position = 'dodge') +
        theme(legend.position = "none")
      figr <- ggplotly(p4ethnicity)
    })
    
    output$plot_sex <- renderPlotly({
      compare_filter_12 <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                                 compare_filter_2() %>% mutate(Group = "Group 2"))
      
      p4sex <- ggplot() +
        geom_bar(data = compare_filter_12, aes(x = Sex, fill = `Group`), position = 'dodge') +
        theme(legend.position = "none")
      figr <- ggplotly(p4sex)
    })
    
    output$plot_age <- renderPlotly({
      compare_filter_12 <- rbind(compare_filter_1() %>% mutate(Group = "Group 1"),
                                 compare_filter_2() %>% mutate(Group = "Group 2"))
      
      p4age <- ggplot() +
        geom_bar(data = compare_filter_12, aes(x = `Applicant Age`, fill = `Group`), position = 'dodge') +
        theme(legend.position = "none")
      figr <- ggplotly(p4age)
    })
    
  })

  ### EXPORT TAB ###
  
  # HMDA data filter for export tab
  export_filter <- callModule(
    shiny_data_filter,
    "export_filter",
    data = hmda_data,
    verbose = FALSE)
  
  # Render datatable for export tab
  output$data_table <- renderDT(
    server = TRUE, {
    datatable(
      export_filter(),
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
  
  # Download handler for export tab
  output$download <- downloadHandler(
    filename = 'download.csv', 
    content = function(file) {
      write.csv(export_filter(), file, row.names = FALSE)
  })
})
