#' trends UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_trends_ui <- function(id){
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(width = 4,#tags$style("max-width: 20px;"),

                   selectizeInput(ns("time_names"),
                                  "Baby names:",
                                  c("Chris", "David", "Olivier"),
                                  multiple = TRUE,
                                  selected = NULL
                   ),
                   radioButtons(ns("time_gender"),
                                "Genders:",
                                choices = c("All", "Male", "Female"),
                                selected = "All",
                                inline = TRUE)

      ),
      mainPanel(dygraphs::dygraphOutput(ns("time_plot")),
                #plotOutput("time_plot"),
                textOutput(ns("time_text")))
    )
  )
}

#' trends Server Functions
#'
#' @noRd
mod_trends_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    output$time_plot <- dygraphs::renderDygraph(shinipsum::random_dygraph() %>%
                                                  dygraphs::dyOptions(mobileDisableYTouch = TRUE,
                                                                      disableZoom = FALSE))

    output$time_text <- renderText(shinipsum::random_text(nwords = 100))
  })
}

## To be copied in the UI
# mod_trends_ui("trends_1")

## To be copied in the server
# mod_trends_server("trends_1")
