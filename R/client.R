#' ghql client
#'
#' @export
#' @param url (character) URL for the GraphQL schema
#' @param headers Any acceptable \pkg{httr} header, constructed typically
#' via \code{\link[httr]{add_headers}}. See examples
#'
#' @return a \code{GraphqlClient} class (R6 class)
#'
#' @section methods:
#' \strong{Methods}
#'   \describe{
#'     \item{\code{ping()}}{
#'      ping the GraphQL server, return HTTP status code
#'     }
#'     \item{\code{load_schema()}}{
#'      manually load schema, from URL or local file
#'     }
#'     \item{\code{schema2json()}}{
#'      convert schema to JSON
#'     }
#'     \item{\code{query()}}{
#'      define query in a character string
#'     }
#'     \item{\code{parse_2json()}}{
#'      parse query string with libgraphqlparser and get back JSON
#'     }
#'   }
#'
#' @examples \dontrun{
#' # make a client
#' # cli <- graphql(url = "https://api.github.com/graphql")
#'
#' library("httr")
#' token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
#' cli <- graphql(
#'   url = "https://api.github.com/graphql",
#'   headers = add_headers(Authorization = paste0("Bearer ", token))
#' )
#'
#' # variables
#' cli$url
#' cli$schema
#' cli$schema$data
#' cli$schema$data$`__schema`
#' cli$schema$data$`__schema`$queryType
#' cli$schema$data$`__schema`$mutationType
#' cli$schema$data$`__schema`$subscriptionType
#' head(cli$schema$data$`__schema`$types)
#' cli$schema$data$`__schema`$directives
#'
#' # methods
#' ## ping - hopefully you get a 200
#' cli$ping()
#'
#' ## dump schema
#' cli$schema2json()
#'
#' ## define query
#' cli$query('query { }')
#' cli$query_string
#' ### execute the query
#' cli$exec()
#'
#' ## another
#' cli$query('{
#'   viewer {
#'     repositories(last: 10, isFork: false, privacy: PUBLIC) {
#'       edges {
#'         node {
#'           isPrivate
#'           id
#'           name
#'         }
#'       }
#'     }
#'   }
#' }')
#' cli$query_string
#' ### execute the query
#' cli$exec()
#' ### parse query string to JSON (with libgraphqlparser)
#' (json <- cli$parse_2json())
#' jsonlite::fromJSON(json)
#' }
graphql <- function(url, headers) {
  GraphqlClient$new(url = url, headers = headers)
}

#' @importFrom R6 R6Class
GraphqlClient <- R6::R6Class(
  "GraphqlClient",
  portable = TRUE,
  cloneable = FALSE,
  public = list(
    url = NULL,
    headers = NULL,
    schema = NULL,
    query_string = NULL,
    result = NULL,

    initialize = function(url, headers) {
      if (!missing(url)) self$url <- url
      if (!missing(headers)) self$headers <- headers
      self$schema <- self$load_schema(self$url)
    },

    print = function(...) {
      cat('<ghql client>', sep = "\n")
      cat(paste0('  url: ', self$url), sep = "\n")
    },

    ping = function(...) {
      res <- gh_HEAD(self$url, self$headers, ...)
      res$status_code
    },

    load_schema = function(x, ...) {
      parze(cont(gh_GET(x, self$headers, ...)))
    },

    schema2json = function(...) {
      jsonlite::toJSON(self$schema, ...)
    },

    query = function(x) {
      self$query_string <- gsub("\n", "", x)
    },

    exec = function(...) {
      self$result <- jsonlite::fromJSON(cont(
        gh_POST(self$query_string, self$headers, ...)
      ))
      return(self$result)
    },

    parse_2json = function() {
      graphql::graphql2json(string = self$query_string)
    }
  )
)
