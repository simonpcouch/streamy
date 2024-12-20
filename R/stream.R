#' Stream generator results into a document
#'
#' @param generator A coro generator function.
#' @param context Optional. An RStudio document context.
#' @param interface One of `"prefix"`, `"replace"`, or `"suffix"`. Defaults to
#' `"replace"`.
#'
#' @returns
#' Nothing; called for its side effect, modifying the context of the current
#' selection with results from the generator.
#'
#' @export
stream <- function(generator,
                   context = rstudioapi::getActiveDocumentContext(),
                   interface = c("prefix", "replace", "suffix")) {
  check_generator(generator)
  check_context(context)
  interface <- parse_interface(interface)

  rlang::eval_bare(rlang::call2(
    paste0("rs_", interface, "_selection"),
    generator = generator,
    context = context
  ))
}

# replace selection with refactored code ---------------------------------------
rs_replace_selection <- function(generator, context) {
  selection <- rstudioapi::primary_selection(context)

  # make the format of the "final position" consistent
  selection_portions <- standardize_selection(selection, context)
  selection <- selection_portions$selection
  selection_remainder <- selection_portions$remainder
  n_lines_orig <- max(selection$range$end[["row"]] - selection$range$start[["row"]], 1)

  # fill selection with empty lines
  selection <- wipe_selection(selection, context)

  # start streaming
  stream_selection(
    generator = generator,
    selection = selection,
    context = context,
    n_lines_orig = n_lines_orig,
    remainder = selection_remainder
  )
}

standardize_selection <- function(selection, context) {
  # if the first entry on a newline, make it the last entry on the line previous
  if (selection$range$end[["column"]] == 1L) {
    selection$range$end[["row"]] <- selection$range$end[["row"]] - 1
    # also requires change to column -- see below
  }

  # ensure that models can fill in characters beyond the current selection's
  # while also ensuring that characters after the selection in the final
  # line are preserved (simonpcouch/pal#35)
  selection_text <- selection[["text"]]

  # Positron doesn't support line endings of Inf, so use a very large number
  selection$range$end[["column"]] <- 100000

  rstudioapi::setSelectionRanges(selection$range, id = context$id)
  full_text <- rstudioapi::primary_selection(
    rstudioapi::getSourceEditorContext(id = context$id)
  )$text
  remainder <- gsub(gsub("\n$", "", selection_text), "", full_text, fixed = TRUE)
  remainder <- gsub("\n", "", remainder, fixed = TRUE)

  list(selection = selection, remainder = remainder)
}

# fill selection with empty lines
wipe_selection <- function(selection, context) {
  n_lines_orig <- selection$range$end[["row"]] - selection$range$start[["row"]]
  empty_lines <- paste0(rep("\n", n_lines_orig), collapse = "")
  rstudioapi::modifyRange(selection$range, empty_lines, context$id)
  rstudioapi::setCursorPosition(selection$range$start, context$id)
  selection
}

# prefix selection with new code -----------------------------------------------
rs_prefix_selection <- function(generator, context) {
  selection <- rstudioapi::primary_selection(context)

  # add one blank line before the selection
  rstudioapi::modifyRange(
    selection$range,
    paste0("\n", selection[["text"]]),
    context$id
  )

  # make the "current selection" that blank line
  first_line <- selection$range
  first_line$start[["column"]] <- 1
  first_line$end[["row"]] <- selection$range$start[["row"]]
  first_line$end[["column"]] <- 100000
  selection$range <- first_line
  rstudioapi::setCursorPosition(selection$range$start)

  # start streaming into it--will be interactively appended to if need be
  stream_selection(
    generator = generator,
    selection = selection,
    context = context,
    n_lines_orig = 1
  )
}

# suffix selection with new code -----------------------------------------------
rs_suffix_selection <- function(generator, context) {
  selection <- rstudioapi::primary_selection(context)

  # add one blank line after the selection
  rstudioapi::modifyRange(
    selection$range,
    paste0(selection[["text"]], "\n"),
    context$id
  )

  # make the "current selection" that blank line
  last_line <- selection$range
  last_line$start[["row"]] <- selection$range$end[["row"]] + 1
  last_line$end[["row"]] <- selection$range$end[["row"]] + 1
  last_line$start[["column"]] <- 1
  last_line$end[["column"]] <- 100000
  selection$range <- last_line
  rstudioapi::setCursorPosition(selection$range$start)

  # start streaming into it--will be interactively appended to if need be
  stream_selection(
    generator = generator,
    selection = selection,
    context = context,
    n_lines_orig = 1
  )
}

# meat and potatoes -
stream_selection <- function(generator, selection, context, n_lines_orig, remainder = "") {
  tryCatch(
    stream_selection_impl(
      generator = generator,
      selection = selection,
      context = context,
      n_lines_orig = n_lines_orig,
      remainder = remainder
    ),
    error = function(e) {
      rstudioapi::showDialog("Error", paste("The assistant ran into an issue: ", e$message))
    }
  )
}

stream_selection_impl <- function(generator, selection, context, n_lines_orig, remainder) {
  selection_text <- selection[["text"]]
  output_lines <- character(0)

  coro::loop(for (chunk in generator) {
    if (identical(chunk, "")) {next}

    output_lines <- paste(output_lines, chunk, sep = "")
    output_lines_no_trailing_newline <- gsub("\n+$", "", output_lines)
    n_lines <- nchar(gsub("[^\n]+", "", output_lines_no_trailing_newline)) + 1

    # add trailing newlines so that the output at least extends to the n_lines
    # of the original selection (for visual effect only)
    output_padded <- paste0(
      output_lines_no_trailing_newline,
      paste0(rep("\n", max(n_lines_orig - n_lines, 0)), collapse = "")
    )

    rstudioapi::modifyRange(
      selection$range,
      output_padded,
      context$id
    )

    # there may be more lines in the output than there are in the range
    n_selection <- selection$range$end[[1]] - selection$range$start[[1]]
    n_lines_res <- nchar(gsub("[^\n]+", "", output_padded))
    selection$range$end[["row"]] <- selection$range$start[["row"]] + n_lines_res
  })

  # once the generator is finished, modify the range with the
  # unpadded version to remove unneeded newlines
  rstudioapi::modifyRange(
    selection$range,
    sub("\n$", "", paste0(output_lines, remainder)),
    context$id
  )

  # reindent the code
  rstudioapi::setSelectionRanges(selection$range, id = context$id)
  rstudioapi::executeCommand("reindent")

  rstudioapi::setCursorPosition(selection$range$start)
}
