library(shiny)
source("lib.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

  database <- reactiveValues(components = list(),
                             n_components = 0,
                             config_dataset = readr::read_csv(file = "ebola.csv"),
                             sitrep_dataset = readr::read_csv(file = "ebola.csv"))

  observe({
    inFile <- input$uploadeddata_config
    if (!is.null(inFile$datapath)) {
      database[["config_dataset"]] <- readr::read_csv(inFile$datapath)
    }
  })

  observe({
    inFile <- input$uploadeddata_sitrep
    if (!is.null(inFile$datapath)) {
      database[["sitrep_dataset"]] <- readr::read_csv(inFile$datapath)
    }
  })

  config_dataset_cols <- reactive({
    colnames(database[["config_dataset"]])
  })

  observe({
    cols <- c("None", config_dataset_cols())
    updateSelectInput(session, "config_column_dateonset", choices = cols)
    updateSelectInput(session, "config_column_sex", choices = cols)
    updateSelectInput(session, "config_column_age", choices = cols)
  })

  new_id <- reactive({
    id <- database[["n_components"]] + 1
    database[["n_components"]] <- id
    database[["n_components"]]
  })

  components <- reactive({
    database[["components"]]
  })

  observeEvent(input$report_builder_add, {
    new_item <- if (input$report_builder_components == "Epi-Curve") {
      list(type = "epicurve", text = "Epi-Curve", id = new_id(),
           compute = function() {
             dates <- database[["sitrep_dataset"]][[input$config_column_dateonset]]
             epicurve(database[["sitrep_dataset"]],
                      input$config_column_dateonset,
                      time.period = "month",
                      start.at = min(as.Date(dates)),
                      stop.at = max(as.Date(dates)))
           })
    } else { # text
      list(type = "text", text = "Text", id = new_id(), compute = function() {
        ""
      })
    }
    database[["components"]] <- c(database[["components"]], list(new_item))
  })

  output$generateBtn <- downloadHandler(
    filename = function() {
      paste('sitrep-', Sys.Date(), '.docx', sep='')
    },
    content = function(con) {
      rmarkdown::render("reporttpl.Rmd", output_file = con, envir = environment())
    }
  )

  output$report_builder <- renderUI({
    do.call(tags$ul, lapply(components(), function(x) {
      tags$li(x$text)
    }))
  })

  observe({
    i <- 1
    for(x in components()) {
      if (x$type == "epicurve") {
        eval(substitute(
          output[[paste0("plot_epicurve_", x$id)]] <- renderPlot({
            x <- components()[[component_id]]
            x$compute()
          }), list(component_id = i)))

      }
      i <- i + 1
    }
  })

  output$preview <- renderUI({
    do.call(tags$ul, lapply(components(), function(x) {
      tags$li(if (x$type == "epicurve") {
        plotOutput(paste0("plot_epicurve_", x$id))
      } else {
        textAreaInput(paste0("report_text", x$id), "Add text:")
      })
    }))
  })

})

