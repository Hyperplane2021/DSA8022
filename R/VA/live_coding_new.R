library(gapminder)
library(tidyverse)
library(shiny)
library(shinythemes)
library(DT)

ui <- navbarPage(
  theme = shinytheme("paper"),
  # shinythemes::themeSelector(),
  title = "Dashboard",
  # About tab
  tabPanel(
    title = "About",
    
    h1("Hello world"),
    
    p("some text ", a(href="http://www.google.com", "Google"))
  ),
  
  # Gapminder Analysis tab
  tabPanel(
    title = "Gapminder Analysis",
    
    checkboxInput("sidebar", "Show Sidebar", value = FALSE),
    
    
    sidebarLayout(
      
      conditionalPanel(condition = "input.sidebar",
      sidebarPanel(
        # sidebar panel
        
        conditionalPanel("input.tabPane == 'Plot'",
          
          selectInput("x", "X-Axis:",
                      choices = c(
                        "Year" = "year",
                        "Life Expectancy" = "lifeExp",
                        "Population Size" = "pop",
                        "GDP per Capita" = "gdpPercap"
                      ),
                      selected = "gdpPercap"),
          
          selectInput("y", "Y-Axis:",
                      choices = c(
                        "Year" = "year",
                        "Life Expectancy" = "lifeExp",
                        "Population Size" = "pop",
                        "GDP per Capita" = "gdpPercap"
                      ),
                      selected = "lifeExp"),
          textInput("title", "Title", "GDP vs Life Expectancy"),
          numericInput("size", "Point Size", 1, 1),
          checkboxInput("fit", "Add line of the best fit", value = FALSE),
          checkboxInput("linear", "linear (or LOESS)", value = TRUE),
          radioButtons("colour", "Point Colour", 
                       choices = c("blue", "red", "green", "black")),
          
        ),
        selectInput("continents", "Continents",
                    # choices = factor(gapminder$continent),  # alternatively, un-ordered
                    choices = levels(gapminder$continent), # alternatively, ordered
                    multiple = TRUE,
                    selected = "Europe"),
        sliderInput("years", "Years", 
                    min = min(gapminder$year), 
                    max = max(gapminder$year), 
                    value = c(1977, 2002), sep="")
        
      )),
      
      mainPanel(
        # main panel
        # plotOutput("plot"),
        textOutput(outputId = "plotPaneText"),
        tabsetPanel(id = "tabPane",
          tabPanel("Plot", 
                   plotOutput("plot")),
          
          tabPanel("Data", 
                   dataTableOutput("table")),
          
          tabPanel("Summary", 
                   verbatimTextOutput("summary"))
        )
      )
      
    )
  )
)
  
server <- function(input, output) {
  
  filtered_data <- reactive({   # filtered_data is a new reactive expression which will respond to reactive values
    f_data <- gapminder %>%
        filter(
        continent %in% input$continents,
        year >= input$years[1],
        year <= input$years[2]
      )
    f_data

    ## Alternatively    
    # gapminder %>%
    #   filter(
    #     continent %in% input$continents,
    #     year >= input$years[1],
    #     year <= input$years[2]
    #   )

  })
  
  output$plotPane <- renderText({
    print(input$tabPane)
    print("Hello")
    input$tabPane
  })
  
  output$plotPaneText <- renderText({
    print(input$tabPane)
    print("Hello")
    input$tabPane
  })
  
  output$plot <- renderPlot({
    # If you want, you can create variables to store input values    
    # x_title <- input$x
    # y_title <- input$y
    # year_slider <- input$years
    
    data <- filtered_data() # reactive expression must be called as a function
    
    p <- ggplot(data, aes_string(x = input$x, y = input$y)) +
      geom_point(size = input$size, colour = input$colour) + 
      labs(
        title = input$title
      ) 
    
    if(input$fit){
      if(input$linear){
        p <- p + geom_smooth(method = "lm")
      } else {
        p <- p + geom_smooth(method = "loess")
      }
    }
    
    p
  })
  
  # Please note: 
  # The renderDataTable function only provides the server-side version of DataTables (using R to process the data object on the server side). There is a separate package DT (https://github.com/rstudio/DT) that allows you to create both server-side and client-side DataTables, and supports additional DataTables features. 
  # The R package DT provides an R interface to the JavaScript library DataTables.
  
  output$table <- DT::renderDataTable({
  # output$table <- renderDataTable({
    data <- filtered_data()
    data
    
    # You can also simply call the reactive expression
    # filtered_data()
  })
  
  output$summary <- renderPrint({
    data <- filtered_data()
    glimpse(data)
  })
}

shinyApp(ui = ui, server = server)