#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic

    fluidPage(
      # custom CSS: set max width, padding, center in the middle of the screen
      tags$head(tags$style(type="text/css",
                           HTML('.container-fluid {  max-width: 1000px; padding:25px; margin-left: auto; margin-right: auto; }

                           .well { background-color: #F0F8FF;}

                           * { font-family: "Montserrat"; }

                           .nav>li>a { padding: 10px 7px; }

                           h1 {display: inline;}
                           h2 {display: inline;}

                           /* .div {display: inline-block;}*/
                           #subtitle {display: inline-block;}

                           div#main_time_plot.col-sm-8: {padding-left: 0px;}
                           '))),
      fluidRow(
        div(h1("Baby Names: "),
            div(id = "subtitle", h2(em("Ontario, 1917-2019"))))
      ),
      fluidRow(
        tabsetPanel(
          tabPanel("Trends",
                   mod_trends_r6_ui("trends_r6", r)),

          tabPanel("Top Names",
                   mod_top_names_ui("top_names_1", r)),



          tabPanel("About",

                   h3("About the Data"),
                   p(shinipsum::random_text(nwords = 100)),

                   h3("About the Dashboard"),
                   p(shinipsum::random_text(nwords = 100)),

                   h3("About Belanger Analytics"),
                   p(shinipsum::random_text(nwords = 100)),

                   p("Testing emojis \U0001f605  \U0001f3f3\u200D\u26A7   \uD83C\uDFF3\u200D\u26A7")
          )
        )
      )

    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){

  add_resource_path(
    'www', app_sys('app/www')
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'ontario.baby.names'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}

