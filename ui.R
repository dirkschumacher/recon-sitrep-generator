library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Sitrep generator"),

  # Sidebar with a slider input for number of bins
  mainPanel(
    tabsetPanel(
      tabPanel("Configuration",
               fileInput("uploadeddata_config", label = "Upload dataset"),
               hr(),
               fluidRow(
                 column(width = 6,
                    h3("Column mapping"),
                    selectInput("config_column_dateonset", "Date of onset", choices = "None"),
                    selectInput("config_column_sex", "Sex", choices = "None"),
                    selectInput("config_column_age", "Age", choices = "None")
                ),
                column(width = 6,
                    h3("Build the report"),
                    uiOutput("report_builder"),
                    selectInput("report_builder_components", "Component", choices = c("Epi-Curve", "Text")),
                    actionButton("report_builder_add", "Add component")
                ))
               ),

      tabPanel("Sitrep",
               fileInput("uploadeddata_sitrep", label = "Upload dataset"),
               hr(),
               uiOutput("preview"),
               hr(),
               downloadButton("generateBtn", "Generate Sitrep")
      )
    )
  )
))
