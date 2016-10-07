#' ghql query class
#'
#' @export
#' @param query (character) query string
#'
#' @return a \code{Query} class (R6 class)
#'
#' @section methods:
#' \strong{Methods}
#'   \describe{
#'     \item{\code{query(x)}}{
#'      define query in a character string
#'     }
#'     \item{\code{parse2json(query)}}{
#'      parse query string with libgraphqlparser and get back JSON
#'     }
#'   }
#'
#' @examples \dontrun{
#' # make a client
#' qry <- Query$new()
#'
#' ## define query
#' qry$query('myquery', 'query { }')
#' qry
#' qry$queries
#' qry$queries$myquery
#'
#' ## another
#' qry$query('query2', '{
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
#' qry
#' qry$queries
#' qry$queries$query2
#'
#' # fragments
#' ## by hand
#' qry$query('querywithfrag', '{
#'   ropensci: repositoryOwner(login:"ropensci") {
#'     repositories(first: 3) {
#'       edges {
#'         node {
#'           ...Watchers
#'         }
#'       }
#'     }
#'   }
#'   ropenscilabs: repositoryOwner(login:"ropenscilabs") {
#'     repositories(first: 3) {
#'       edges {
#'         node {
#'           ...Watchers
#'         }
#'       }
#'     }
#'   }
#' }
#'
#' fragment Watchers on Repository {
#'   watchers(first: 3) {
#'     edges {
#'       node {
#'         name
#'       }
#'     }
#'   }
#' }')
#' qry
#' qry$queries
#' qry$queries$querywithfrag
#'
#'
#' library("httr")
#' token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
#' cli <- GraphqlClient$new(
#'   url = "https://api.github.com/graphql",
#'   headers = add_headers(Authorization = paste0("Bearer ", token))
#' )
#' cli$exec(qry$queries$querywithfrag)
#'
#' ## use Fragment class fragments generator
#' ### define query without fragment, but referring to it
#' qry$query('queryfrag', '{
#'   ropensci: repositoryOwner(login:"ropensci") {
#'     repositories(first: 3) {
#'       edges {
#'         node {
#'           ...Watchers
#'         }
#'       }
#'     }
#'   }
#'   ropenscilabs: repositoryOwner(login:"ropenscilabs") {
#'     repositories(first: 3) {
#'       edges {
#'         node {
#'           ...Watchers
#'         }
#'       }
#'     }
#'   }
#' }')
#'
#' ### define a fragment, and use it later
#' frag <- Fragment$new()
#' frag$fragment('Watchers', '
#'   fragment on Repository {
#'     watchers(first: 3) {
#'       edges {
#'         node {
#'           name
#'        }
#'     }
#'   }
#' }')
#' frag$fragments
#' frag$fragments$Watchers
#'
#' ### add the fragment to the query 'queryfrag'
#' qry$add_fragment('queryfrag', frag$fragments$Watchers)
#' qry
#' qry$queries
#' qry$queries$queryfrag
#' }
Query <- R6::R6Class(
  "Query",
  portable = TRUE,
  cloneable = FALSE,
  public = list(
    queries = list(),

    print = function(...) {
      cat('<ghql: query>', sep = "\n")
      cat('  queries:\n')
      for (i in seq_along(self$queries)) {
        frock <- ""
        if (length(self$queries[[i]]$fragment)) {
          frock <- sprintf("[fragment: %s]", attr(self$queries[[i]]$fragment, "name"))
        }
        cat("   ", names(self$queries)[i], " ", frock, "\n")
      }
    },

    query = function(name, x) {
      self$queries <-
        c(
          self$queries,
          stats::setNames(
            list(structure(make_query(x), class = "query")),
            name
          )
        )
    },

    add_fragment = function(query_name, fragment) {
      # lookup query by name
      # if not found stop with message saying query name not found
      if (!query_name %in% names(self$queries)) {
        stop(query_name, " not in set of query names", call. = FALSE)
      }
      # if name found add fragment
      self$queries[[query_name]]$fragment <- fragment
    },

    parse2json = function(query) {
      graphql::graphql2json(query)
    }
  ),

  private = list(
    build_query = function() {
      "x"
    }
  )
)

make_query <- function(query = list(), fragment = list()) {
  list(
    query = query,
    fragment = fragment
  )
}

print.query <- function(x, ...) {
  frock <- ""
  if (length(x$fragment)) {
    frock <- sprintf("[fragment: %s]", attr(x$fragment, "name"))
  }
  cat(frock, "\n", gsub("^\n\\s+", "", x$query), "\n")
}
