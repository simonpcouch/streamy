
<!-- README.md is generated from README.Rmd. Please edit that file -->

# streamy

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/streamy)](https://CRAN.R-project.org/package=streamy)
[![R-CMD-check](https://github.com/simonpcouch/streamy/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simonpcouch/streamy/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/simonpcouch/streamy/graph/badge.svg)](https://app.codecov.io/gh/simonpcouch/streamy)
<!-- badges: end -->

Given a coro generator instance, streamy inlines text into a document
selection in RStudio and Positron. This is particularly helpful for
streaming LLM responses into documents.

This package powers [gander](https://github.com/simonpcouch/gander),
[pal](https://github.com/simonpcouch/pal), and
[ensure](https://github.com/simonpcouch/ensure).

## Installation

You can install the development version of streamy like so:

``` r
pak::pak("simonpcouch/streamy")
```
