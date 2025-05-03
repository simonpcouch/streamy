#' Stream generator results into a document
#'
#' @description
#' Given an asychronous generator that produces text, this function iteratively
#' polls that generator and inlines its results into the currently open RStudio
#' or Positron document. This is particularly useful for streaming results
#' from large language models.
#'
#' @param generator A [coro::generator()] function.
#' @param context Optional. An RStudio document context.
#' @param interface One of `"prefix"`, `"replace"`, or `"suffix"`, describing
#' how to the active selection will be interfaced with. Defaults to `"replace"`.
#'
#' @details
#' This function is generally not intended for interactive usage. See the
#' gander, chores, and ensure package, which this package powers.
#'
#' @returns
#' The streamed result, invisibly; called for its side effect, modifying the
#' context of the current selection with results from the generator.
#'
#' @examples
#' \dontrun{
#' if (rlang::is_installed("ellmer") &&
#'     !identical("ANTHROPIC_API_KEY", "") &&
#'     rstudioapi::isAvailable()
#'  ) {
#'   library(ellmer)
#'
#'   gen <- chat_claude()$stream("hey there!")
#'
#'   stream(gen, interface = "suffix")
#' }
#' }
#' @export
stream <- function(
  generator,
  context = active_document_context(),
  interface = c("prefix", "replace", "suffix")
) {
  check_generator(generator)
  check_context(context)
  interface <- parse_interface(interface)

  rlang::eval_bare(rlang::call2(
    paste0("rs_", interface, "_selection"),
    generator = generator,
    context = context,
    interface = interface
  ))
}

active_document_context <- function() {
  if (identical(Sys.getenv("RETURN_ON_DISPATCH"), "true")) {
    return(structure(list(), class = "document_context"))
  }

  rstudioapi::getActiveDocumentContext()
}

# replace selection with refactored code ---------------------------------------
rs_replace_selection <- function(generator, context, interface) {
  if (return_on_dispatch()) {
    return(NULL)
  }

  selection <- rstudioapi::primary_selection(context)

  # make the format of the "final position" consistent
  selection_portions <- standardize_selection(selection, context)
  selection <- selection_portions$selection
  selection_remainder <- selection_portions$remainder
  n_lines_orig <- max(
    selection$range$end[["row"]] - selection$range$start[["row"]],
    1
  )

  # fill selection with empty lines
  selection <- wipe_selection(selection, context)

  # start streaming
  stream_selection(
    generator = generator,
    selection = selection,
    context = context,
    n_lines_orig = n_lines_orig,
    remainder = selection_remainder,
    interface = interface
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
  # line are preserved (simonpcouch/chores#35)
  selection_text <- selection[["text"]]

  # Positron doesn't support line endings of Inf, so use a very large number
  selection$range$end[["column"]] <- 100000

  rstudioapi::setSelectionRanges(selection$range, id = context$id)
  full_text <- rstudioapi::primary_selection(
    rstudioapi::getSourceEditorContext(id = context$id)
  )$text
  remainder <- gsub(
    gsub("\n$", "", selection_text),
    "",
    full_text,
    fixed = TRUE
  )
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

return_on_dispatch <- function() {
  if (identical(Sys.getenv("RETURN_ON_DISPATCH"), "true")) {
    cli::cli_inform("Dispatched correctly.", class = "stream_dispatch")
    Sys.unsetenv("RETURN_ON_DISPATCH")
    return(TRUE)
  }

  FALSE
}

# prefix selection with new code -----------------------------------------------
rs_prefix_selection <- function(generator, context, interface) {
  if (return_on_dispatch()) {
    return(NULL)
  }

  selection <- rstudioapi::primary_selection(context)

  # add one blank line before the selection
  # the selection may be empty (i.e. just a cursor), so make sure
  # to append the newline before the whole current line(s)
  whole_lines <- selection$range
  whole_lines$start[["column"]] <- 1
  whole_lines$end[["column"]] <- 100000

  rstudioapi::modifyRange(
    whole_lines,
    paste0(
      c("", extract_range(whole_lines, context$contents)),
      collapse = "\n"
    ),
    context$id
  )

  # make the "current selection" that blank line
  first_line <- whole_lines
  first_line$end[["row"]] <- selection$range$start[["row"]]
  selection$range <- first_line
  rstudioapi::setCursorPosition(selection$range$start)

  # start streaming into it--will be interactively appended to if need be
  stream_selection(
    generator = generator,
    selection = selection,
    context = context,
    n_lines_orig = 1,
    interface = interface
  )
}

extract_range <- function(range, contents) {
  start_line <- range$start[1]
  end_line <- range$end[1]
  start_col <- range$start[2]
  end_col <- range$end[2]

  if (start_line == end_line) {
    substr(contents[start_line], start_col, end_col)
  } else {
    lines <- contents[start_line:end_line]
    lines[1] <- substr(lines[1], start_col, nchar(lines[1]))
    lines[length(lines)] <- substr(lines[length(lines)], 1, end_col)
    lines
  }
}

# suffix selection with new code -----------------------------------------------
rs_suffix_selection <- function(generator, context, interface) {
  if (return_on_dispatch()) {
    return(NULL)
  }

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
    n_lines_orig = 1,
    interface = interface
  )
}

# meat and potatoes -
stream_selection <- function(
  generator,
  selection,
  context,
  n_lines_orig,
  remainder = "",
  interface
) {
  res <- character(0)
  tryCatch(
    if (is_positron()) {
      res <- chat_selection_impl(
        generator = generator,
        selection = selection,
        context = context,
        remainder = remainder,
        interface = interface
      )
    } else {
      res <- stream_selection_impl(
        generator = generator,
        selection = selection,
        context = context,
        n_lines_orig = n_lines_orig,
        remainder = remainder,
        interface = interface
      )
    },
    error = function(e) {
      rstudioapi::showDialog(
        "Error",
        paste("The assistant ran into an issue: ", e$message)
      )
    }
  )

  res
}

stream_selection_impl <- function(
  generator,
  selection,
  context,
  n_lines_orig,
  remainder,
  interface
) {
  selection_text <- selection[["text"]]
  output_lines <- character(0)

  coro::loop(
    for (chunk in generator) {
      if (identical(chunk, "")) {
        next
      }

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
      selection$range$end[["row"]] <- selection$range$start[["row"]] +
        n_lines_res
    }
  )

  # remove triple backticks when in .R files (#7)
  if (in_dot_r_file(context)) {
    output_lines <- unbacktick(output_lines)
  }

  # once the generator is finished, modify the range with the
  # unpadded version to remove unneeded newlines
  res <-
    rstudioapi::modifyRange(
      selection$range,
      sub("\n$", "", paste0(output_lines, remainder)),
      context$id
    )

  # reindent the code
  rstudioapi::setSelectionRanges(selection$range, id = context$id)
  rstudioapi::executeCommand("reindent")

  # keep the code selected if it was replaced for easier iteration (#1)
  if (!identical(interface, "replace")) {
    rstudioapi::setCursorPosition(selection$range$start)
  }

  res
}

# in Positron, calls to `rstudioapi::modifyRange()` shims are entangled,
# so just chat rather than stream (simonpcouch/chores#68)
chat_selection_impl <- function(
  generator,
  selection,
  context,
  remainder = "",
  interface
) {
  rlang::local_options(cli.progress_show_after = 0)
  selection_text <- selection[["text"]]

  cli::cli_progress_bar(
    total = NA,
    format = "{cli::pb_spin} Generating... {cli::col_grey(paste0('[', {cli::pb_elapsed}, ']'))}",
    clear = FALSE,
    format_done = "{cli::col_green(cli::symbol$tick)} Generating... {cli::col_grey(paste0('[', {cli::pb_elapsed}, ']'))}"
  )
  cli::cli_progress_update()

  output_lines <- character(0)
  coro::loop(
    for (chunk in generator) {
      output_lines <- c(output_lines, chunk)
      cli::cli_progress_update()

      Sys.sleep(0.025)
    }
  )

  cli::cli_progress_done()

  # remove triple backticks when in .R files (#7)
  if (in_dot_r_file(context)) {
    output_lines <- unbacktick(output_lines)
  }

  res <-
    rstudioapi::modifyRange(
      selection$range,
      paste0(c(sub("\\n$", "", output_lines), remainder), collapse = ""),
      context$id
    )

  # keep the code selected if it was replaced for easier iteration (#1)
  if (!identical(interface, "replace")) {
    rstudioapi::setCursorPosition(selection$range$start)
  }

  res
}
