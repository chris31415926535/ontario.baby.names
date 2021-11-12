#' #' trends UI Function
#' #'
#' #' @description A shiny Module.
#' #'
#' #' @param id,input,output,session Internal parameters for {shiny}.
#' #'
#' #' @noRd
#' #'
#' #' @importFrom shiny NS tagList
#' mod_trends_ui <- function(id){
#'   ns <- NS(id)
#'   tagList(
#'     sidebarLayout(
#'       sidebarPanel(width = 4,#tags$style("max-width: 20px;"),
#'
#'                    # initialize quickly with null choices; add them in server module
#'                    selectizeInput(ns("time_names"),
#'                                   "Baby names:",
#'                                   choices = NULL,#baby_names_forselect,
#'                                   #sort(unique(baby_names$name)),
#'                                   #c("Chris", "David", "Olivier"),
#'                                   multiple = TRUE,
#'                                   selected = NULL
#'                    ),
#'
#'                    radioButtons(ns("time_gender"),
#'                                 "Genders:",
#'                                 choices = c("All", "Male", "Female"),
#'                                 selected = "All",
#'                                 inline = TRUE)
#'
#'       ),
#'       mainPanel(dygraphs::dygraphOutput(ns("time_plot")),
#'                 #plotOutput("time_plot"),
#'                 textOutput(ns("time_text")))
#'     )
#'   )
#' }
#'
#' #' trends Server Functions
#' #'
#' #' @noRd
#' mod_trends_server <- function(id){
#'   moduleServer( id, function(input, output, session){
#'     ns <- session$ns
#'
#'     gargoyle::init("render_timeplot")
#'
#'
#'     # https://shiny.rstudio.com/articles/selectize.html
#'     # update our inpt to use server-side processing
#'     updateSelectizeInput(session,
#'                          'time_names',
#'                          choices = baby_names_forselect,
#'                          # multiple = TRUE,
#'                          selected = NULL,
#'                          server = TRUE)
#'
#'     # update the selectable AND selected names based on changes to gender button
#'     observeEvent(input$time_gender, {
#'
#'       message("Observed radio button click")
#'
#'       if (input$time_gender == "All"){
#'         new_choices <- baby_names_forselect
#'         new_selected <- input$time_names
#'       }
#'       if (input$time_gender == "Male") {
#'         new_choices <- stringr::str_subset(baby_names_forselect, "\\(male")
#'         new_selected <- stringr::str_subset(input$time_names, "\\(male")
#'       }
#'       if (input$time_gender == "Female") {
#'         new_choices <- stringr::str_subset(baby_names_forselect, "female")
#'         new_selected <- stringr::str_subset(input$time_names, "female")
#'       }
#'
#'       updateSelectizeInput(session,
#'                            #ns("time_names"),
#'                            "time_names",
#'                            choices = new_choices,
#'                            selected = new_selected,
#'                            server = TRUE
#'       )
#'     })
#'
#'
#'     forplot_r <- list(names = "")#reactiveVal("")
#'
#'     observeEvent(input$time_names,
#'                  {
#'                    message("checking forplot_r")
#'
#'                    if (!identical(sort(input$time_names) , sort(forplot_r$names))) {#(input$time_names != forplot_rv()){
#'
#'                      message("updating forplot_r")
#'                      df <- baby_names %>%
#'                        dplyr::filter(select_label %in% input$time_names) %>%
#'                        add_missing_years() %>%
#'                        dplyr::select(-gender) %>%
#'                        tidyr::pivot_wider(id_cols = "year", names_from = select_label, values_from = freq, values_fill = 0) %>%
#'                        dplyr::mutate(year = lubridate::ymd(paste0(year,"-01-01")))
#'
#'                      forplot_r$names <<- input$time_names
#'                      forplot_r$data <<- (xts::xts(order.by = df[,1][[1]], x = df[,-1]))
#'
#'                      gargoyle::trigger("render_timeplot")
#'                    }
#'
#'                  })
#'
#'     forplot <- reactive({
#'       message("updating forplot")
#'       df <- baby_names %>%
#'         dplyr::filter(select_label %in% input$time_names) %>%
#'         dplyr::select(-gender) %>%
#'         tidyr::pivot_wider(id_cols = "year", names_from = name, values_from = freq, values_fill = 0) %>%
#'         dplyr::mutate(year = lubridate::ymd(paste0(year,"-01-01")))
#'
#'       forplot <- xts::xts(order.by = df[,1][[1]], x = df[,-1])
#'       forplot
#'     })
#'
#'
#'
#'     #    TESTING SHINIPSUM
#'     #     output$time_plot <- dygraphs::renderDygraph(shinipsum::random_dygraph() %>%
#'     #                                                   dygraphs::dyOptions(mobileDisableYTouch = TRUE,
#'     #                                                                       disableZoom = FALSE))
#'
#'     # USING DEPENDENCY ON forplot() REACTIVE
#'     # output$time_plot <- dygraphs::renderDygraph({
#'     #   # only render the plot if there are valid rows
#'     #   if (nrow(forplot()> 0)){
#'     #     dygraphs::dygraph(forplot(),
#'     #                       main = "Popularity of Ontario Baby Names, 1917-2019") %>%
#'     #       dygraphs::dyOptions(mobileDisableYTouch = TRUE,
#'     #                           disableZoom = FALSE)
#'     #   } else {
#'     #     NULL
#'     #   }
#'     # })
#'
#'
#'     ## USING forplot_r$data LIST VALUE OBSERVED
#'     # observeEvent(forplot_r$data, {
#'     #   message("updating plot")
#'     #   output$time_plot <- dygraphs::renderDygraph({
#'     #     # only render the plot if there are valid rows
#'     #
#'     #     if (nrow(forplot_r$data> 0)){
#'     #       dygraphs::dygraph(forplot_r$data,
#'     #                         main = "Popularity of Ontario Baby Names, 1917-2019") %>%
#'     #         dygraphs::dyOptions(mobileDisableYTouch = TRUE,
#'     #                             disableZoom = FALSE)
#'     #     } else {
#'     #       NULL
#'     #     }
#'     #   })
#'     #
#'     # })
#'
#'     # using gargoyle::trigger / watch
#'     output$time_plot <- dygraphs::renderDygraph({
#'       # only render the plot if there are valid rows
#'       gargoyle::watch("render_timeplot")
#'
#'       if (nrow(forplot_r$data> 0)){
#'         dygraphs::dygraph(forplot_r$data,
#'                           main = "Popularity of Ontario Baby Names, 1917-2019") %>%
#'           dygraphs::dyOptions(mobileDisableYTouch = TRUE,
#'                               disableZoom = FALSE)
#'       } else {
#'         NULL
#'       }
#'     })
#'
#'
#'     #output$time_text <- renderText(shinipsum::random_text(nwords = 100))
#'
#'     output$time_text <- renderText(unlist(head(input$time_names)))
#'   })
#' }
#'
#' ## To be copied in the UI
#' # mod_trends_ui("trends_1")
#'
#' ## To be copied in the server
#' # mod_trends_server("trends_1")
