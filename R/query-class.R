#' @title Query
#' @description ghql query class
#' @export
#' @return a `Query` class (R6 class)
#' @examples
#' # make a client
#' qry <- Query$new()
#'
#' ## define query
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
#' \dontrun{
#' token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
#' con <- GraphqlClient$new(
#'   url = "https://api.github.com/graphql",
#'   headers = list(Authorization = paste0("Bearer ", token))
#' )
#' jsonlite::fromJSON(con$exec(qry$queries$querywithfrag))
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
    #' @field queries (list) list of queries
    queries = list(),

    #' @description print method for the `Query` class
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
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

    #' @description define query in a character string
    #' @param name (character) name of the query
    #' @param x (character) the query
    #' @return nothing returned; sets query with `name` internally
    #' @note we run an internal method `check_query()` that runs the public
    #' method `parse2json()` - if the query doesn't pass the libgraphqlparser
    #' parser, we return the error message
    query = function(name, x) {
      private$check_query(x)
      self$queries <-
        c(
          self$queries,
          stats::setNames(
            list(structure(private$make_query(x), class = "query")),
            name
          )
        )
    },

    #' @description add a fragment to a query
    #' @param query_name (character) the query name to add the fragment to
    #' @param fragment (character) the fragment itself
    #' @return nothing returned; sets the fragment with the query
    add_fragment = function(query_name, fragment) {
      # lookup query by name
      # if not found stop with message saying query name not found
      if (!query_name %in% names(self$queries)) {
        stop(query_name, " not in set of query names", call. = FALSE)
      }
      # if name found add fragment
      self$queries[[query_name]]$fragment <- fragment
    },

    #' @description parse query string with libgraphqlparser and get back JSON
    #' @param query (character) a query to parse
    #' @param parse_schema (logical) enable schema definition parsing?
    #' default: `FAlSE`
    #' @return adf
    parse2json = function(query, parse_schema = FALSE) {
      graphql::graphql2json(query, parse_schema)
    }
  ),

  private = list(
    make_query = function(query = list(), fragment = list()) {
      list(
        query = query,
        fragment = fragment
      )
    },

    check_query = function(query) {
      z <- tryCatch(self$parse2json(query), error = function(e) e)
      if (inherits(z, "error")) stop(z$message, call.=FALSE)
    }
  )
)

#' @export
print.query <- function(x, ...) {
  frock <- ""
  if (length(x$fragment)) {
    frock <- sprintf("[fragment: %s]", attr(x$fragment, "name"))
  }
  cat(frock, "\n", gsub("^\n\\s+", "", x$query), "\n")
}
