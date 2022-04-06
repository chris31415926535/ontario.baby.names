#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic

  # https://stackoverflow.com/questions/63739812/why-does-a-shiny-app-get-disconnected-when-not-used-for-a-while
  #Keep App alive
  keep_alive <- shiny::reactiveTimer(intervalMs = 10000,
                                     session = shiny::getDefaultReactiveDomain())

  shiny::observe({keep_alive()})


  r <- r6$new(ontario.baby.names::baby_names,
              ontario.baby.names::baby_names_forselect,
              ontario.baby.names::baby_names_top_all)

  # server logic for Trends panel
  mod_trends_r6_server("trends_r6", r)

  # server logic for top Names panel
  mod_top_names_server("top_names_1", r)

}
