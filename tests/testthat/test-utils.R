test_that("check_generator works", {
  mock_gen <- structure(list(), class = "coro_generator_instance")

  expect_snapshot(check_generator(1), error = TRUE)
  expect_snapshot(check_generator(NULL), error = TRUE)
  expect_snapshot(check_generator(list()), error = TRUE)
  expect_invisible(expect_identical(check_generator(mock_gen), mock_gen))
})

test_that("check_context works", {
  mock_ctx <- structure(list(), class = "document_context")

  expect_snapshot(check_context(1), error = TRUE)
  expect_snapshot(check_context(NULL), error = TRUE)
  expect_snapshot(check_context(list()), error = TRUE)
  expect_invisible(expect_identical(check_context(mock_ctx), mock_ctx))
})

test_that("parse_interface works", {
  expect_equal(parse_interface("replace"), "replace")
  expect_equal(parse_interface("prefix"), "prefix")
  expect_equal(parse_interface("suffix"), "suffix")
  expect_equal(parse_interface(supported_interfaces), "replace")

  expect_snapshot(parse_interface("unknown"), error = TRUE)
  expect_snapshot(parse_interface(c("replace", "prefix")), error = TRUE)
  expect_snapshot(parse_interface(1), error = TRUE)
  expect_snapshot(parse_interface(NULL), error = TRUE)
})
