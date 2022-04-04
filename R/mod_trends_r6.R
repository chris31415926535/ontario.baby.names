#' trends UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_trends_r6_ui <- function(id, r){
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(width = 4,

                   # initialize quickly with null choices; add them in server module
                   selectizeInput(ns("time_names"),
                                  "Baby names:",
                                  choices = NULL,
                                  multiple = TRUE,
                                  selected = NULL
                   ),

                   radioButtons(ns("time_gender"),
                                "Genders:",
                                choices = c("All", "Male", "Female"),
                                selected = "All",
                                inline = TRUE)

      ),

      mainPanel(id = "main_time_plot", dygraphs::dygraphOutput(ns("time_plot")))

    )
  )
}

#' trends Server Functions
#'
#' @noRd
mod_trends_r6_server <- function(id, r){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # set up our trigger for re-rendering the plot
    gargoyle::init("render_timeplot")


    # https://shiny.rstudio.com/articles/selectize.html
    # update our inpt to use server-side processing
    updateSelectizeInput(session,
                         'time_names',
                         choices = ontario.baby.names::baby_names_forselect,
                         selected = NULL,
                         server = TRUE)

    # update the selectable AND selected names based on changes to gender button
    observeEvent(input$time_gender, {

      message("Observed radio button click")

      if (input$time_gender == "All"){
        new_choices <- ontario.baby.names::baby_names_forselect
        new_selected <- input$time_names
      }
      if (input$time_gender == "Male") {
        new_choices <- stringr::str_subset(ontario.baby.names::baby_names_forselect, "\\(male")
        new_selected <- stringr::str_subset(input$time_names, "\\(male")
      }
      if (input$time_gender == "Female") {
        new_choices <- stringr::str_subset(ontario.baby.names::baby_names_forselect, "female")
        new_selected <- stringr::str_subset(input$time_names, "female")
      }

      # update our UI input no matter what, the choices have changed
      updateSelectizeInput(session,
                           #ns("time_names"),
                           "time_names",
                           choices = new_choices,
                           selected = new_selected,
                           server = TRUE
      )

      # update our r6 selected and trigger plot if the selected values must change
      if (!setequal(new_selected, r$selected)){
        r$update_selection(new_selected)

        gargoyle::trigger("render_timeplot")

      }
    })

    # observe to see when selected names change
    observeEvent(input$time_names,
                 {
                   message("checking r selected values")

                   # if the selection has changed (should be the case)
                   if (!setequal(input$time_names , r$selected)) {

                     message("updating r selected values")
                     r$update_selection(input$time_names)

                     message ("triggering plot render")
                     gargoyle::trigger("render_timeplot")
                   }

                 },
                 ignoreNULL  = FALSE)


    # render the plot only as required using gargoyle::trigger / watch
    output$time_plot <- dygraphs::renderDygraph({

      gargoyle::watch("render_timeplot")

      r$plot_dygraph()
    })

  })
}

## To be copied in the UI
# mod_trends_ui("trends_1")

## To be copied in the server
# mod_trends_server("trends_1")
