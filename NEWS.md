# ghql 0.1.3

* New maintainer: Christopher Smolen. Mark Padgham remains an author (#40).
* `exec()` now stops with a clear message when `variables` has unnamed elements (or `NA` names), instead of sending them under an empty name that servers ignore. To pass several values to one variable, combine them with `c()`, for example `list(id = c(1, 2))` (#36).
* The vignette now shows that mutations work with `Query$query()` and `exec()` (#20).

# ghql 0.1.2

* New maintainer: Mark Padgham. Scott Chamberlain remains an author.
* `GraphqlClient$exec()` gains a `response_headers` argument that adds the response headers as an attribute of the result (#32).
* Variables may be `NULL`, and variable names may contain underscores (#31).
* Clearer error messages for HTTP 400 and 500 responses (#28).
* Comments in queries are kept, because `exec()` no longer removes line breaks (#25).
* Documentation and URL updates.

# ghql 0.1.0

* Released to CRAN.
