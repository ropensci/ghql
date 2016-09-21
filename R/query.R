#' Query Github using GraphQL
#'
#' @export
#' @param query (character) a GraphQL query
#' @param ... Curl options passed to \code{\link[httr]{GET}}
#' @return a list or tibble if possible
#' @references \url{https://developer.github.com/early-access/graphql/}
#' @template query_egs
#' @examples \dontrun{
#' ql('{"query": "query { }"}', config=verbose())
#' ql('query { }', config=verbose())
#'
#' ql('{"query": "query { viewer { login }}"}', config=verbose())
#' ql('query { viewer { login }}', config=verbose())
#'
#' qry <- '{"query": "query { search(type: ISSUE, query: "Octocat", first: 30) { edges { node { ... on Issue { title }}}}}"}'
#' ql(qry, config=verbose())
#'
#' qry <- '{"query": "query { search(type: ISSUE, query: "Octocat", first: 30) { edges { node }}}"}'
#' ql(qry, config=verbose())
#' }
ql <- function(query, ...) {
  jsonlite::fromJSON(cont(
    gh_GET(gsub("\n", "", query), ...)
  ))
}
