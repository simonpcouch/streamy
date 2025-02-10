## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Resubmission

The initial submission of this package was rejected with three comments:

> It seems like you have too many spaces in your description field. Probably because linebreaks count as spaces too.

I've reformatted my DESCRIPTION to include the most minimal number of spaces while also staying under 80 characters per line.

> If there are references describing the methods in your package, please add these in the description field of your DESCRIPTION file...

This package doesn't implement any particular reference, instead providing the RStudio API with tools to interface with coroutines. Relevant software is mentioned by name with single quotes.

> When creating the examples please keep in mind that the structure would be desirable...

I've reformatted the examples to more closely match the requested format.
