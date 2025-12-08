# Changelog

## streamy (development version)

## streamy 0.2.0

CRAN release: 2025-05-21

- The package now has a hex sticker
  ([\#6](https://github.com/simonpcouch/streamy/issues/6)—thanks
  Hadley)!

- [`stream()`](https://simonpcouch.github.io/streamy/reference/stream.md)
  will now remove triple backticks from the generator’s reponse when
  streaming into a .R file
  ([\#7](https://github.com/simonpcouch/streamy/issues/7),
  simonpcouch/gander#5).

- Addresses an issue where, in Positron,
  [`stream()`](https://simonpcouch.github.io/streamy/reference/stream.md)
  might overwrite lines following a selection.

- [`stream()`](https://simonpcouch.github.io/streamy/reference/stream.md)
  will now display a progress bar when there is otherwise no visual
  indication to the user that the generator is running
  ([\#3](https://github.com/simonpcouch/streamy/issues/3)).

## streamy 0.1.0

CRAN release: 2025-02-11

- Initial CRAN submission.
