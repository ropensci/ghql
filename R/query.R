#' Query Github using GraphQL
#'
#' @export
#' @param query (character) a GraphQL query
#' @param ... Curl options passed to \code{\link[httr]{GET}}
#' @return a list or tibble if possible
#' @references \url{https://developer.github.com/early-access/graphql/}
#' @examples \dontrun{
#' jsonlite::fromJSON(ql('{"query": "query { }"}', config=verbose()))
#'
#' x <- ql('{"query": "query { viewer { login }}"}', config=verbose())
#' jsonlite::fromJSON(x)
#'
#' x <- ql('{"query": "query { viewer { login }}"}', config=verbose())
#' jsonlite::fromJSON(x)
#'
#' qry <- '{"query": "query { search(type: ISSUE, query: "Octocat", first: 30) { edges { node { ... on Issue { title }}}}}"}'
#' ql(qry, config=verbose())
#'
#' qry <- '{"query": "query { search(type: ISSUE, query: "Octocat", first: 30) { edges { node }}}"}'
#' ql(qry, config=verbose())
#'
#' ql('{"query": "query {
#'   search(type: ISSUE, query: "Octocat", first: 30) {
#'     edges {
#'       node {
#'         ... on Issue {
#'           title
#'         }
#'       }
#'     }
#'   }
#' }"}')
#' }
ql <- function(query, ...) {
  jsonlite::fromJSON(cont(
    gh_GET(gsub("\n", "", query), ...)
  ))
}
