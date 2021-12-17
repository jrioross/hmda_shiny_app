library(shiny)
library(fresh)
library(tidyverse)
library(shinyDataFilter)
library(DT)

shinyServer(function(input, output) {
    
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
    
    output$plot_1 <- renderPlot({
      filtered_data_1() %>%
        ggplot(aes(x = `Loan Amount`)) +
        geom_histogram()
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
