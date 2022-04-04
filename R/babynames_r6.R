# we're going to use an instance called 'r' for the logic
# set global value of 'r' to NULL for devtools::check()
r <- NULL

# R6 class for managing business logic for baby names app.
r6 <- R6::R6Class("baby_trends",
                  public = list(

                    # public variables for trends
                    baby_names = NULL,
                    selected = NULL,
                    xts_forplot = NULL,
                    select_label = NULL,

                    # public variables for yearly top
                    top_names_all = NULL,
                    top_names = NULL,
                    top_year = NULL,
                    top_gender = NULL,
                    top_num = NULL,


                    initialize = function(baby_names, baby_names_forselect, baby_names_top_all){

                      # initialize for Trends
                      self$baby_names <- baby_names
                      self$select_label <- baby_names_forselect
                      self$selected <- NULL
                      # create xts with years 1917-2019 and col of zeros with no name
                      self$xts_forplot <- private$empty_xts

                      # initialize for top names
                      self$top_names_all <- baby_names_top_all
                      self$top_year <- "1917-2019"
                      self$top_gender <- "All"
                      self$top_num <- 10
                      #self$update_top_names(self$top_year, self$top_num, self$top_gender)



                    },

                    # PUBLIC METHODS FOR TRENDS

                    # update the selection
                    update_selection = function(new_selection){
                      self$selected <- new_selection

                      # if we have selected anything, update the xts
                      # otherwise return the empty xts
                      if (length(self$selected) > 0 ){ # & self$selected[[1]] != ""
                        df <- self$baby_names %>%
                          dplyr::filter(select_label %in% self$selected) %>%
                          private$add_missing_years() %>%
                          dplyr::select(-gender) %>%
                          tidyr::pivot_wider(id_cols = "year", names_from = select_label, values_from = freq, values_fill = 0) %>%
                          dplyr::mutate(year = lubridate::ymd(paste0(year,"-01-01")))


                        self$xts_forplot <- (xts::xts(order.by = df[,1][[1]], x = df[,-1]))
                      } else {
                        self$xts_forplot <- private$empty_xts
                      }


                    }
                    ,

                    plot_dygraph = function(){
                      if (nrow(self$xts_forplot > 0)){
                        dygraphs::dygraph(self$xts_forplot,
                                          main = "Baby Name Popularity, 1917-2019") %>%
                          dygraphs::dyOptions(mobileDisableYTouch = TRUE,
                                              disableZoom = FALSE,
                                              axisLabelWidth = 35)
                      } else {
                        NULL
                      }

                    },

                    # PUBLIC METHODS FOR TOP NAMES

                    update_top_names = function(year_new, num_new, gender_new){

                      gender_new <- tolower(gender_new)
                      num_new <- as.numeric(num_new)

                     # message ("inside r6 trying to update top names")
                     # message(year_new)
                     # message(num_new)
                     # message(gender_new)

                      yearly_names <- self$top_names_all %>%
                        dplyr::ungroup()

                      # if we are looking overall, create summary table
                      if (year_new == "1917-2019") {

                        yearly_names <- self$top_names_all %>%
                          dplyr::group_by(name, gender) %>%
                          dplyr::summarise(freq = sum(freq), .groups = "drop") %>%
                          dplyr::arrange(dplyr::desc(freq)) %>%
                          dplyr::mutate(year = "1917-2019")
                      }


                      if (gender_new == "all"){
                        self$top_names <- yearly_names %>%
                          dplyr::filter(year %in% year_new) %>% #, gender == gender_new) %>%
                          dplyr::arrange(dplyr::desc(freq)) %>%
                          dplyr::slice_head(n = num_new)

                      }

                      if (gender_new != "all"){
                        self$top_names <- yearly_names %>%
                          dplyr::filter(year %in% year_new, gender == gender_new) %>%
                          dplyr::slice_head(n = num_new)

                      }

                      self$top_year <- year_new
                      self$top_gender <- gender_new
                      self$top_num <- num_new
                     # message("inside r6 finished updating top names")
                    },


                    plot_top_names = function() {

                      gender_lab <- ifelse(self$top_gender == "all", "all-gender", tolower(self$top_gender))

                      forplot <- self$top_names %>%
                        dplyr::mutate(name = factor(name, levels = rev(name))) %>%
                        ggplot2::ggplot() +
                        ggplot2::geom_col(ggplot2::aes(x=name, y=freq, fill = gender)) +
                        ggplot2::coord_flip() +
                        ggplot2::theme_minimal() +
                        ggplot2::theme(legend.position = "none") +
                        ggplot2::labs(title = sprintf("Top %d %s baby names, %s", self$top_num, gender_lab, self$top_year),
                                      x = NULL, y = NULL, fill = "Gender") +
                        ggplot2::scale_fill_manual(breaks = c("male", "female"),
                                                   values = c("#F0CEFF", "#99EDC3"))

                      plotly::ggplotly(forplot) %>%
                        plotly::config(displayModeBar = F) %>%
                        plotly::layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))

                    }
                  ),

                  private = list(
                    # add missing rows for plotting years with 0 frequency
                    add_missing_years = function(df) {

                      for (name in unique(df$select_label)){
                        df <- df %>%
                          dplyr::bind_rows(
                            dplyr::tibble(year = setdiff(1917:2019, df$year),
                                          select_label = name,
                                          freq = 0
                            ))
                      }

                      dplyr::arrange(df, year) %>%
                        return()
                    },

                    # empty xts for printing empty plot
                    empty_xts = xts::xts(order.by = lubridate::ymd(paste0(1917:2019, "-01-01")),
                                         x = rep(0, times = length(1917:2019))) %>%
                      setNames("")
                  )

)

