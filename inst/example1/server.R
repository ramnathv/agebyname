library(shiny)
shinyServer(function(input, output, session){
  output$namePlot <- renderPlot({
    plot_name(input$name, state_ = input$state)
  })
})