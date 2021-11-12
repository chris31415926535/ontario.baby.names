r6 <- R6::R6Class("baby_trends",
                  public = list(
                    baby_names = NULL,
                    selected = NULL,
                    xts_forplot = NULL,
                    select_label = NULL,

                    initialize = function(baby_names, baby_names_forselect){
                      self$baby_names <- baby_names
                      self$select_label <- baby_names_forselect
                      self$selected <- NULL
                      # create xts with years 1917-2019 and col of zeros with no name
                      self$xts_forplot <- private$empty_xts
                    },

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


                      # only do anything if there's a change
                      # if (!setequal(self$selected, new_selection)){
                      #
                      # }

                    }
                    ,

                    plot_dygraph = function(){
                      if (nrow(self$xts_forplot > 0)){
                        dygraphs::dygraph(self$xts_forplot,
                                          main = "Popularity of Ontario Baby Names, 1917-2019") %>%
                          dygraphs::dyOptions(mobileDisableYTouch = TRUE,
                                              disableZoom = FALSE)
                      } else {
                        NULL
                      }

                    }

                  )
                  ,

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

