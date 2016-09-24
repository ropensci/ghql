#' Query Github using GraphQL
#'
#' @keywords internal
#' @param query (character) a GraphQL query
#' @param ... Curl options passed to \code{\link[httr]{GET}}
#' @return a list or tibble if possible
#' @references \url{https://developer.github.com/early-access/graphql/}
#' @template query_egs
ql <- function(query, ...) {
  jsonlite::fromJSON(cont(
    gh_POST(gsub("\n", "", query), ...)
  ))
}
