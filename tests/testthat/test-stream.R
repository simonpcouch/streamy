test_that("extract_range works", {
  # extracts single line
  contents <- c("line1", "line2", "line3")
  range <- list(start = c(2, 1), end = c(2, 5))
  expect_equal(extract_range(range, contents), "line2")

  # extracts part of single line
  range <- list(start = c(2, 2), end = c(2, 4))
  expect_equal(extract_range(range, contents), "ine")

  # extracts multiple lines
  range <- list(start = c(1, 3), end = c(3, 2))
  expect_equal(extract_range(range, contents), c("ne1", "line2", "li"))
})
