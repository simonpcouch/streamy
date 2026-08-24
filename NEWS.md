# streamy (development version)

* `stream()` accepts ellmer content streams and writes only text content into
  the document, leaving reasoning and tool content out of the result
  (simonpcouch/gander#69).

# streamy 0.2.1

* Fixed a bug in Positron where multi-line writes would have some newlines removed (simonpcouch/chores#96).

# streamy 0.2.0

* The package now has a hex sticker (#6—thanks Hadley)!

* `stream()` will now remove triple backticks from the generator's reponse
  when streaming into a .R file (#7, simonpcouch/gander#5). 

* Addresses an issue where, in Positron, `stream()` might overwrite lines
  following a selection. 
  
* `stream()` will now display a progress bar when there is otherwise no
  visual indication to the user that the generator is running (#3).

# streamy 0.1.0

* Initial CRAN submission.
