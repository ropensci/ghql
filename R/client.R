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
#'     \item{\code{ping(...)}}{
#'      ping the GraphQL server, return HTTP status code
#'     }
#'     \item{\code{load_schema(schema_url, schema_file)}}{
#'      load schema, from URL or local file
#'     }
#'     \item{\code{dump_schema(file)}}{
#'      dump schema to a local file
#'     }
#'     \item{\code{schema2json(...)}}{
#'      convert schema to JSON
#'     }
#'   }
#'
#' @examples \dontrun{
#' # make a client
#' # cli <- GraphqlClient$new(url = "https://api.github.com/graphql")
#'
#' library("httr")
#' token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
#' cli <- GraphqlClient$new(
#'   url = "https://api.github.com/graphql",
#'   headers = add_headers(Authorization = paste0("Bearer ", token))
#' )
#'
#' # if the GraphQL server has a schema, you can load it
#' cli$load_schema()
#'
#' # dump schema to local file
#' f <- tempfile(fileext = ".json")
#' cli$dump_schema(file = f)
#' readLines(f)
#' jsonlite::fromJSON(readLines(f))
#'
#' # after dumping to file, you can later read schema from file for faster loading
#' rm(cli)
#' cli <- GraphqlClient$new(
#'   url = "https://api.github.com/graphql",
#'   headers = add_headers(Authorization = paste0("Bearer ", token))
#' )
#' cli$load_schema(schema_file = f)
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
#'
#' # methods
#' ## ping - hopefully you get a 200
#' cli$ping()
#'
#' ## dump schema
#' cli$schema2json()
#'
#'
#' ## define query
#' ### creat a query class first
#' qry <- Query$new()
#' ## another
#' qry$query('repos', '{
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
#' qry$queries$repos
#' ### execute the query
#' cli$exec(qry$queries$repos)
#'
#'
#' # query with a fragment
#' ### define query without fragment, but referring to it
#' qry <- Query$new()
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
#' ### define a fragment
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
#' qry$queries$queryfrag
#'
#' ### execute query: we'll hook together the query and your fragment internally
#' cli$exec(qry$queries$queryfrag)
#' }
GraphqlClient <- R6::R6Class(
  "GraphqlClient",
  portable = TRUE,
  cloneable = FALSE,
  public = list(
    url = NULL,
    headers = NULL,
    schema = NULL,
    result = NULL,
    fragments = list(),

    initialize = function(url, headers) {
      if (!missing(url)) self$url <- url
      if (!missing(headers)) self$headers <- headers
    },

    print = function(...) {
      cat('<ghql client>', sep = "\n")
      cat(paste0('  url: ', self$url), sep = "\n")
    },

    ping = function(...) {
      res <- gh_HEAD(self$url, self$headers, ...)
      res$status_code
    },

    load_schema = function(schema_url = NULL, schema_file = NULL, ...) {
      if (!is.null(schema_url) || is.null(schema_file)) {
        self$schema <- parze(
          cont(
            gh_GET(if (is.null(schema_url)) self$url else x, self$headers, ...)
          )
        )
      } else {
        self$schema <- parze(schema_file)
      }
    },

    dump_schema = function(file) {
      schema <- self$schema2json()
      if (schema == "{}") {
        stop("schema is empty, see 'load_schema' first", call. = FALSE)
      } else {
        writeLines(schema, file)
      }
    },

    schema2json = function(...) {
      jsonlite::toJSON(self$schema, ...)
    },

    fragment = function(name, x) {
      self$fragments <-
        c(
          self$fragments,
          stats::setNames(list(structure(x, class = "fragment")), name)
        )
    },

    exec = function(query, ...) {
      jsonlite::fromJSON(cont(
        gh_POST(
          self$url,
          gsub("\n", "", private$handle_query(query)),
          self$headers, ...)
      ))
    },

    prep_query = function(query) {
      private$handle_query(query)
    }
  ),

  private = list(
    handle_query = function(x) {
      if (!length(x$fragment)) {
        x$query
      } else {
        fname <- attr(x$fragment, "name")
        if (!grepl(paste0("...", fname), x$query)) {
          stop(sprintf("fragment '%s' not found in query", fname),
               call. = FALSE)
        }
        frag <- sub("fragment on",
                    sprintf("fragment %s on", fname), unclass(x$fragment))
        paste(x$query, frag)
      }
    }
  )
)
