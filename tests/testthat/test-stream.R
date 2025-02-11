test_that("stream works with replace interface", {
  gen <- test_generator()

  expect_message(
    .res <- stream(gen, interface = "replace"),
    class = "stream_dispatch"
  )
  expect_null(.res)
})

test_that("stream works with prefix interface", {
  gen <- test_generator()

  expect_message(
    .res <- stream(gen, interface = "prefix"),
    class = "stream_dispatch"
  )
  expect_null(.res)
})

test_that("stream works with suffix interface", {
  gen <- test_generator()

  expect_message(
    .res <- stream(gen, interface = "suffix"),
    class = "stream_dispatch"
  )
  expect_null(.res)
})

test_that("active_document_context returns a document context", {
  withr::local_envvar(RETURN_ON_DISPATCH = "true")
  res <- active_document_context()
  expect_s3_class(res, "document_context")
})

test_that("rs_* functions respect rstudioapi availability", {
  withr::local_envvar(RETURN_ON_DISPATCH = "true")
  expect_message(
    rs_replace_selection(
      test_generator(),
      structure(list(), class = "document_context"),
      "replace"
    ),
    class = "stream_dispatch"
  )

  withr::local_envvar(RETURN_ON_DISPATCH = "true")
  expect_message(
    rs_replace_selection(
      test_generator(),
      structure(list(), class = "document_context"),
      "prefix"
    ),
    class = "stream_dispatch"
  )

  withr::local_envvar(RETURN_ON_DISPATCH = "true")
  expect_message(
    rs_replace_selection(
      test_generator(),
      structure(list(), class = "document_context"),
      "suffix"
    ),
    class = "stream_dispatch"
  )
})

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

test_that("stream_selection errors informatively on streaming error", {
  mock_gen <- structure(list(), class = "coro_generator_instance")
  mock_ctx <- structure(list(), class = "document_context")
  mock_sel <- list(text = "", range = list(start = c(1, 1), end = c(1, 1)))

  testthat::local_mocked_bindings(
    stream_selection_impl = function(...) stop("test error"),
  )
  testthat::local_mocked_bindings(
    showDialog = function(title, message) {
      cli::cli_abort(message, call = NULL)
    },
    .package = "rstudioapi"
  )

  expect_snapshot(
    stream_selection(
      generator = mock_gen,
      selection = mock_sel,
      context = mock_ctx,
      n_lines_orig = 1,
      remainder = "",
      interface = "replace"
    ),
    error = TRUE
  )
})
