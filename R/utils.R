check_generator <- function(generator, call = caller_env()) {
  if (!inherits(generator, "coro_generator_instance")) {
    cli::cli_abort(
      "{.arg generator} must be the output of {.fn coro::generator(fn)},
       not {.obj_type_friendly {generator}}.",
      call = call
    )
  }

  invisible(generator)
}

check_context <- function(context, call = caller_env()) {
  if (!inherits(context, "document_context")) {
    cli::cli_abort(
      "{.arg context} must be document context from {.pkg rstudioapi},
       not {.obj_type_friendly {context}}.",
      call = call
    )
  }

  invisible(context)
}

parse_interface <- function(interface, call = caller_env()) {
  if (isTRUE(identical(interface, supported_interfaces))) {
    interface <- "replace"
  }

  if (
    isTRUE(
      length(interface) != 1 ||
        !interface %in% supported_interfaces
    )
  ) {
    cli::cli_abort(
      "{.arg interface} should be one of {.or {.val {supported_interfaces}}},
       not {.obj_type_friendly {interface}}.",
      call = call
    )
  }

  interface
}

supported_interfaces <- c("replace", "prefix", "suffix")

is_positron <- function() {
  Sys.getenv("POSITRON") == "1"
}

in_dot_r_file <- function(context) {
  identical(tolower(tools::file_ext(context$path)), "r")
}

unbacktick <- function(x) {
  x <- gsub("\n```", "", x)
  x <- gsub("```\n", "", x)
  x <- gsub("```", "", x)
  x
}
