library(shiny)
library(agebyname)
library(dplyr)
top_names = bnames %>%
  group_by(name) %>%
  summarize(n = sum(n)) %>%
  top_n(100)

shinyUI(fluidPage(
  titlePanel("Age from Names"),
  sidebarLayout( 
    sidebarPanel(
      selectInput("name",
        "Choose Name",
        top_names$name
      ),
      selectInput("state",
        "Choose State",
        c('US', state.abb),
      )
    ),
    mainPanel(
      plotOutput("namePlot")
    )
  )
))