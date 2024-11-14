library(shiny)
library(shinyWidgets)
library(data.table)
library(bslib)
library(dplyr)
library(arrow)

lapply(fs::dir_ls("R/", glob = "*.R"), source)

ui <- navbarPage(
  "Interactivity with Base R",
  tabPanel("Intro"),
  navbarMenu(
    "The Basics",
    nav_panel(
      "Basic Plots",
      basics_UI("basic")
    ),
    tabPanel("Box Select"),
    tabPanel("Range Select")
  ),
  navbarMenu(
    "In Action",
    tabPanel("Scatter plots"),
    tabPanel(
      title = "Time-series Analysis",
      ts_UI("ts")
    ),
    tabPanel("Faceted plots")
  ),
  navbarMenu(
    "Scale Up",
    tabPanel(
      "Shiny modules",
      tabsetPanel(
        type = "tabs",
        tabPanel("What are modules?"),
        tabPanel("PCA"),
        tabPanel("Time-series")
      )
    ),
    tabPanel("Performance")
  )
)

server <- function(input, output, session) {
  basics_server("basic")
  ts_server("ts")
}

shinyApp(ui = ui, server = server)
