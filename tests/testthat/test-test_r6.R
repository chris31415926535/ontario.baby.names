

testthat::test_that("R6 class works for Trends panel", {
  # initialize new R6 object
  r <- r6$new(baby_names, baby_names_forselect, baby_names_top_all)

  # data is initialized as expected
  testthat::expect_s3_class(r$baby_names, "tbl")
  testthat::expect_equal(r$baby_names, baby_names)
  testthat::expect_type(r$select_label, "character")
  testthat::expect_equal(r$select_label, baby_names_forselect)
  testthat::expect_s3_class(r$xts_forplot, "xts")

  # plot function initially returns dygraphs object
  testthat::expect_s3_class(r$plot_dygraph(), "dygraphs")

  # test that updating selection works
  r$update_selection("CHRIS (male)")
  testthat::expect_equal(r$selected, "CHRIS (male)")
  testthat::expect_s3_class(r$plot_dygraph(), "dygraphs")

})

testthat::test_that("R6 class works for Top Names panel", {
  # initialize new R6 object
  r <- r6$new(baby_names, baby_names_forselect, baby_names_top_all)

  # data is initialized as expected
  testthat::expect_equal(r$top_names_all, baby_names_top_all)

  # test updating selection to specific year
  r$update_top_names(year_new = 2010, gender_new = "male", num_new = 10)
  testthat::expect_equal(r$top_names,
                         baby_names_top_all %>%
                           dplyr::filter(year == 2010, gender == "male") %>%
                           dplyr::arrange(dplyr::desc(freq)) %>%
                           dplyr::slice_head(n = 10))

  # test doing overall summary
  r$update_top_names(year_new = "1917-2019", gender_new = "female", num_new = 5)
  testthat::expect_equal(r$top_names,
                         baby_names_top_all %>%
                           dplyr::group_by(name, gender) %>%
                           dplyr::summarise(freq = sum(freq), .groups = "drop") %>%
                           dplyr::arrange(dplyr::desc(freq)) %>%
                           dplyr::mutate(year = "1917-2019") %>%
                           dplyr::filter(gender == "female") %>%
                           dplyr::arrange(dplyr::desc(freq)) %>%
                           dplyr::slice_head(n = 5))

  # test that all-gender summary works
  r$update_top_names(year_new = "1921", gender_new = "All", num_new = 5)

  r$plot_top_names()

})
