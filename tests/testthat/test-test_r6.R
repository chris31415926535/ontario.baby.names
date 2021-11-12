test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})


test_that("R6 class works", {
  # initialize new R6 object
  r <- r6$new(baby_names, baby_names_forselect)

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
