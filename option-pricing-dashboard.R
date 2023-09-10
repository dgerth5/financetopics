library(shiny)

ui <- fluidPage(
  
  titlePanel("Option Pricing with GBM Simulation"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("s0", label = "Initial stock price (s0):", value = 100, min = 0),
      numericInput("u", label = "Mean return (u):", value = 0.05, min = 0, step = 0.01),
      numericInput("o", label = "Volatility (o):", value = 0.2, min = 0, step = 0.01),
      numericInput("t", label = "Time to maturity (t):", value = 1, min = 0, step = 0.01),
      numericInput("r", label = "Risk-free rate (r):", value = 0.03, min = 0, step = 0.01),
      numericInput("steps", label = "Number of steps:", value = 100, min = 1),
      numericInput("sims", label = "Number of simulations:", value = 1000, min = 1),
      actionButton("go", "Calculate")
    ),
    
    mainPanel(
      fluidRow(
        column(6,
               h3("European Option Price"),
               tableOutput("option_prices_eu")
        ),
        column(6,
               h3("Asian Option Price"),
               tableOutput("option_prices_as")
        )
      )
    )
  )
)

server <- function(input, output) {
  
  gbm <- function(s0, u, o, t, steps, sims){
    
    paths <- matrix(0, nrow = steps, ncol = sims)
    paths[1,] <- s0
    dt <- t / steps
    
    for (i in 2:steps){
      paths[i,] <- paths[i-1,]*exp((u - o^2/2)*dt + o*rnorm(sims)*sqrt(dt))
    }
    
    return(paths)
    
  }
  
  euro_option_prices <- function(paths, r, t, K){
    
    c <- numeric(length(K))
    p <- numeric(length(K))
    
    for (i in 1:length(K)){
      
      c[i] <- round(mean(pmax(paths[nrow(paths),] - K[i], 0)) / exp(r*t),2)
      p[i] <- round(mean(pmax(K[i] - paths[nrow(paths),], 0)) / exp(r*t),2)
      
    }
    
    df <- data.frame(Strike = K, Call_Price = c, Put_Price = p)
    return(df)
    
  }
  
  asian_option_prices <- function(paths, r, t, K){
    
    c <- numeric(length(K))
    p <- numeric(length(K))
    
    for (i in 1:length(K)){
      
      c[i] <- round(mean(pmax(colMeans(paths) - K[i], 0)) / exp(r*t),2)
      p[i] <- round(mean(pmax(K[i] - colMeans(paths), 0)) / exp(r*t),2)
      
    }
    
    df <- data.frame(Strike = K, Call_Price = c, Put_Price = p)
    return(df)
    
  }
  
  observeEvent(input$go, {
    
    s0 <- input$s0
    u <- input$u
    o <- input$o
    t <- input$t
    r <- input$r
    steps <- input$steps
    sims <- input$sims
    
    K <- seq(round(s0,0) - 5, round(s0,0) + 5, by = 0.5)
    
    paths <- gbm(s0, u, o, t, steps, sims)
    prices_eu <- euro_option_prices(paths, r, t, K)
    prices_as <- asian_option_prices(paths, r, t, K)
    
    output$option_prices_eu <- renderTable({
      prices_eu
    })
    
    output$option_prices_as <- renderTable({
      prices_as
    })
    
  })
  
}

shinyApp(ui = ui, server = server)
