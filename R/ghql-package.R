#' @title ghql
#'
#' @description General purpose GraphQL client
#'
#' @importFrom crul HttpClient
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom R6 R6Class
#' @importFrom graphql graphql2json
#' @name ghql-package
#' @aliases ghql
#' @docType package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @keywords package
#'
#' @section ghql API:
#' The main interface in this package is [GraphqlClient], which produces
#' a client (R6 class) with various methods for interacting with a
#' GraphQL server. [GraphqlClient] also accepts various input parameters
#' to set a base URL, and any headers required, which is usually the required
#' set of things needed to connect to a GraphQL service.
#'
#' [Query] is an interface to creating GraphQL queries,
#' which works together with [GraphqlClient]
#'
#' [Fragment] is an interface to creating GraphQL fragments,
#' which works together with [GraphqlClient]
NULL
