#' @title GraphqlClient
#' @description R6 class for constructing GraphQL queries
#' @export
#' @return a `GraphqlClient` class (R6 class)
#' @examples
#' x <- GraphqlClient$new()
#' x
#' 
#' \dontrun{
#' # make a client
#' token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
#' cli <- GraphqlClient$new(
#'   url = "https://api.github.com/graphql",
#'   headers = list(Authorization = paste0("Bearer ", token))
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
#'   headers = list(Authorization = paste0("Bearer ", token))
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
#' ## ping - hopefully you get TRUE
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
    #' @field url (character) list of fragments
    url = NULL,
    #' @field headers list of named headers
    headers = NULL,
    #' @field schema holds schema
    schema = NULL,
    #' @field result holds result from http request
    result = NULL,
    #' @field fragments (list) list of fragments
    fragments = list(),

    #' @description Create a new `GraphqlClient` object
    #' @param url (character) URL for the GraphQL schema
    #' @param headers Any acceptable headers, a named list. See examples
    #' @return A new `GraphqlClient` object
    initialize = function(url, headers) {
      if (!missing(url)) self$url <- url
      if (!missing(headers)) self$headers <- headers
    },

    #' @description print method for the `GraphqlClient` class
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      cat('<ghql client>', sep = "\n")
      cat(paste0('  url: ', self$url), sep = "\n")
    },

    #' @description ping the GraphQL server
    #' @param ... curl options passed on to [crul::verb-HEAD]
    #' @return `TRUE` if successful response, `FALSE` otherwise
    ping = function(...) {
      res <- gh_HEAD(self$url, self$headers, ...)
      res$success()
    },

    #' @description load schema, from URL or local file
    #' @param schema_url (character) url for a schema file
    #' @param schema_file (character) path to a schema file
    #' @param ... curl options passed on to [crul::verb-GET]
    #' @return nothing, loads schema into `$schema` slot
    load_schema = function(schema_url = NULL, schema_file = NULL, ...) {
      if (!is.null(schema_url) || is.null(schema_file)) {
        self$schema <- parze(
          cont(
            gh_GET(if (is.null(schema_url)) self$url else schema_url,
                   self$headers, ...)
          )
        )
      } else {
        self$schema <- parze(schema_file)
      }
    },

    #' @description dump schema to a local file
    #' @param file (character) path to a file
    #' @return nothing, writes schema to `file`
    dump_schema = function(file) {
      schema <- self$schema2json()
      if (schema == "{}") {
        stop("schema is empty, see 'load_schema' first", call. = FALSE)
      } else {
        writeLines(schema, file)
      }
    },

    #' @description convert schema to JSON
    #' @param ... options passed on to [jsonlite::toJSON()]
    #' @return json
    schema2json = function(...) {
      jsonlite::toJSON(self$schema, ...)
    },

    #' @description load schema, from URL or local file
    #' @param name (character) fragment name
    #' @param x (character) the fragment
    #' @return nothing returned; sets fragments internally
    fragment = function(name, x) {
      self$fragments <-
        c(
          self$fragments,
          stats::setNames(list(structure(x, class = "fragment")), name)
        )
    },

    #' @description execute the query
    #' @param query (character) a query, of class `query` or `fragment`
    #' @param variables (list) named list with query variables values
    #' @param encoding (character) encoding to use to parse the response. passed
    #' on to [crul::HttpResponse] `$parse()` method. default: "UTF-8"
    #' @param ... curl options passed on to [crul::verb-POST]
    #' @return character string of response, if successful
    exec = function(query, variables, encoding = "UTF-8", ...) {
      parsed_query <- gsub("\n", "", private$handle_query(query))
      body <- list(query = parsed_query)
      if (private$has_variables(body$query)) {
        if (missing(variables))
          stop(sprintf("query has variables and not one passsed"), call. = FALSE)
        else
          private$verify_variables(body$query, variables)
          body$variables = variables  
      }
      cont(
        gh_POST(
          self$url,
          body,
          self$headers, ...),
        encoding = encoding
      )
    },

    #' @description not used right now
    #' @param query (character) a query, of class `query` or `fragment`
    prep_query = function(query) {
      private$handle_query(query)
    }
  ),

  private = list(
    # @field .var_regex variable regexp 
    .var_regex = '\\$([[:alnum:]]+)',

    # @description rewrite query if there is fragments, leave equal otherwise
    # @param x (character) a query, of class `query` or `fragment`
    # @return a graphql query language character vector
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
    },
    
    # @description check if query has variables
    # @param query (character) a graphql query language character vector
    has_variables = function(query){
      grepl(private$.var_regex, query)
    },
    
    # @description check if query variables are given on `variables`
    # @param query (character) a graphql query language character vector
    # @param variables (list) variables named list
    verify_variables = function(query, variables) {
      vars <- sub("\\$", "",
        unique(
          regmatches(
            query, 
            gregexpr(
              private$.var_regex, query
            )
          )[[1]]
        )
      )
      for (v in vars) {
        if (is.null(variables[[v]]))
          stop(sprintf("variable `%s` is null or not found in variables", v), call. = FALSE)
      }
    }
  )
)
