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
