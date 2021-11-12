#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic

  r <- r6$new(baby_names, baby_names_forselect)

  # server logic for Trends panel
  mod_trends_server("trends_1")

  mod_trends_r6_server("trends_r6", r)

  output$top_plot <- plotly::renderPlotly({
#
#     #https://stackoverflow.com/questions/4559229/drawing-pyramid-plot-using-r-and-ggplot2
#     boy_data <- dplyr::filter(top_years, gender == "male")
#     girl_data <- dplyr::filter(top_years, gender == "female")
#
#     forplot <- ggplot2::ggplot() +
#       ggplot2::geom_linerange(data = boy_data,
#                               mapping = ggplot2::aes(x=year, colour = gender, ymin = 0, ymax = freq),
#                               size = 5) +
#       ggplot2::geom_linerange(data = girl_data,
#                               mapping = ggplot2::aes(x=year, colour = gender, ymin = 0, ymax = -freq),
#                               size = 5) +
#       ggplot2::coord_flip() +
#       ggplot2::theme_minimal() +
#       ggplot2::scale_y_continuous(labels = abs) +
#       ggplot2::labs(title = "Top Boy and Girl Names by Year",
#                     y= NULL, x = NULL,
#                     colour = "Gender")# +
#     #viridis::scale_colour_viridis(discrete = TRUE, labels = c("Girl", "Boy"))
#
#     plotly::ggplotly(forplot)
  })


  output$year_plot <- plotly::renderPlotly(shinipsum::random_ggplotly(type = "bar"))
}
