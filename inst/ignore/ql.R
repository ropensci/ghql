#' Execute a GraphQL query
#'
#' @keywords itnernal
#' @param x \code{json} object or character string with json data.
#' @param ... character specification of jq query. Each element in code{...}
#'   will be combined with " | ", which is convenient for long queries.
ql <- function(x, ...) {
  UseMethod("ql", x)
}

#' @export
ql.ql <- function(x, ...) {
  pipe_autoexec(toggle = FALSE)
  make_query(x)
}

#' @export
ql.character <- function(x, ..., flags = jq_flags()) {
  query <- query_from_dots(...)
  structure(jqr(x, query, flags),
            class = c("jqson", "character"))
}

#' @export
ql.default <- function(x, ...) {
  stop(sprintf("ql method not implemented for ", class(x)), call. = FALSE)
}

#' @export
print.ql <- function(x, ...) {
  cat(jsonlite::prettify(combine(x)))
}

#' Helper function for createing a jq query string from ellipses.
#' @noRd
query_from_dots <- function(...) {
  dots <- list(...)
  if (!all(vapply(dots, is.character, logical(1))))
    stop("jq query specification must be character.", call. = FALSE)

  paste(unlist(dots), collapse = " | ")
}

make_query <- function(x) {
  paste0(pop(x), collapse = " | ")
}
