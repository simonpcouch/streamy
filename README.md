
<!-- README.md is generated from README.Rmd. Please edit that file -->

# streamy <a href="https://simonpcouch.github.io/streamy/"><img src="man/figures/logo.png" align="right" height="250" alt="streamy website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/streamy)](https://CRAN.R-project.org/package=streamy)
[![R-CMD-check](https://github.com/simonpcouch/streamy/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simonpcouch/streamy/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Given a coro generator instance, streamy inlines text into a document
selection in RStudio and Positron. This is particularly helpful for
streaming LLM responses into documents.

This package powers [gander](https://github.com/simonpcouch/gander),
[chores](https://github.com/simonpcouch/chores), and
[ensure](https://github.com/simonpcouch/ensure).

## Installation

You can install streamy with the following R code:

``` r
install.packages("streamy")
```

Install the development version of streamy like so:

``` r
pak::pak("simonpcouch/streamy")
```
