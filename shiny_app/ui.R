library(shiny)
library(fresh)
library(tidyverse)
library(shinyDataFilter)
library(DT)

shinyUI(navbarPage(
  
  # Theme options
  use_theme(
    create_theme(
      theme = "default",
      bs_vars_navbar(
        default_bg = "#0A3254",
        default_link_color = "#0090B2",
        default_link_active_color = "#FFFFFF",
        default_link_hover_color = "#FFFFFF",
        height = "40px",
      ),
      bs_vars_font(
        family_sans_serif = "Lato",
        size_base = "16px",
      ),
      bs_vars_color(
        brand_primary = "#0090B2",
      )
    )
  ),
  
  # Additional CSS options
  tags$style(type = 'text/css', 
             '.page-footer {color: #999A9E}'
  ),
  
  # Title image
  title = img(src = "logo.svg", 
              style = 'margin-top: 0px', 
              height = "45px"),
  
  # Visualize tab
  tabPanel(h4("Visualize")),
  
  # Compare tab
  tabPanel(h4("Compare"),
           sidebarLayout(
             sidebarPanel(
               tabsetPanel(
                 tabPanel("Subset 1", shiny_data_filter_ui("data_filter_1")),
                 tabPanel("Subset 2", shiny_data_filter_ui("data_filter_2"))
               ),
               width = 3
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Demographics"),
                 tabPanel("Action Taken"),
                 tabPanel("Loan Amounts", plotOutput("plot_1")),
                 tabPanel("Denial Reasons"),
               ),
               width = 9
             )
           )
  ),
  
  # Export tab
  tabPanel(h4("Export"),
           sidebarLayout(
             sidebarPanel(
               shiny_data_filter_ui("data_filter_3"),
               div(class = 'text-center', downloadButton('download', 'Download')),
               width = 3
             ),
             mainPanel(
               wellPanel(DTOutput('data_table')),
               width = 9
             )
           )
  ),
  
  # About tab
  tabPanel(h4("About")),
  
  # Footer
  tags$footer(HTML("<!-- Footer -->
                   <footer class='page-footer indigo'>
                   <!-- Copyright -->
                   <div class='footer-copyright text-center py-3'>
                   © 2021 Hauser Jones & Sas, PLLC. All Rights Reserved.
                   </div>
                   <!-- Copyright -->
                   </footer>
                   <!-- Footer -->"))
))