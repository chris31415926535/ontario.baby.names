#' top_names UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_top_names_ui <- function(id, r){
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        width = 4,

        shiny::selectInput(ns("top_year"),
                           "Select Year:",
                           # choices = c("(Overall)", 2019:1917),
                           # selected = "(Overall)",
                           choices = stats::setNames(c("1917-2019", 2019:1917), c("(Overall)", 2019:1917)),
                           selected = "(Overall)",
                           multiple = FALSE,
                           selectize = FALSE),

        shiny::selectInput(ns("top_num_names"),
                           "Number of Names:",
                           choices = c(25,10,5),
                           selected = 10,
                           multiple = FALSE,
                           selectize = FALSE),

        radioButtons(ns("top_gender"),
                     "Genders:",
                     choices = c("All", "Male", "Female"),
                     selected = "All",
                     inline = TRUE)

      ),

      mainPanel(plotly::plotlyOutput(ns("top_plot")),
                shiny::tableOutput(ns("test_df"))
      )
    )


  )
}

#' top_names Server Functions
#'
#' @noRd
mod_top_names_server <- function(id, r){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # initialize trigger for redrawing plot
    gargoyle::init("render_top_plot")

    output$top_plot <- plotly::renderPlotly({
      gargoyle::watch("render_top_plot")
      r$plot_top_names()
    }
    #shinipsum::random_ggplotly() %>%
    # plotly::config(displayModeBar = F)
    )

    # testing
    output$test_df <- shiny::renderTable( {
      gargoyle::watch("render_top_plot")

      r$top_names
    } )


    observeEvent(c(input$top_year,
                   input$top_num_names,
                   input$top_gender),
                 {
                   message ("updating top names")
                   message(input$top_year)
                   message(input$top_num_names)
                   message(input$top_gender)

                   r$update_top_names(year_new = input$top_year,
                                      num_new = input$top_num_names,
                                      gender_new = input$top_gender)

                   gargoyle::trigger("render_top_plot")
                 })
  })




}

## To be copied in the UI
# mod_top_names_ui("top_names_1")

## To be copied in the server
# mod_top_names_server("top_names_1")
