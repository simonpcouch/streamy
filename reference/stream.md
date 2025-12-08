# Stream generator results into a document

Given an asychronous generator that produces text, this function
iteratively polls that generator and inlines its results into the
currently open RStudio or Positron document. This is particularly useful
for streaming results from large language models.

## Usage

``` r
stream(
  generator,
  context = active_document_context(),
  interface = c("prefix", "replace", "suffix")
)
```

## Arguments

- generator:

  A
  [`coro::generator()`](https://coro.r-lib.org/reference/generator.html)
  function.

- context:

  Optional. An RStudio document context.

- interface:

  One of `"prefix"`, `"replace"`, or `"suffix"`, describing how to the
  active selection will be interfaced with. Defaults to `"replace"`.

## Value

The streamed result, invisibly; called for its side effect, modifying
the context of the current selection with results from the generator.

## Details

This function is generally not intended for interactive usage. See the
gander, chores, and ensure package, which this package powers.

## Examples

``` r
if (FALSE) { # \dontrun{
if (rlang::is_installed("ellmer") &&
    !identical("ANTHROPIC_API_KEY", "") &&
    rstudioapi::isAvailable()
 ) {
  library(ellmer)

  gen <- chat_claude()$stream("hey there!")

  stream(gen, interface = "suffix")
}
} # }
```
