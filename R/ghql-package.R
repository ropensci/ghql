#' @title ghql
#'
#' @description General purpose GraphQL client
#'
#' @name ghql-package
#' @aliases ghql
#' @docType package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @keywords package
#'
#' @section ghql API:
#' The main interface in this package is \code{\link{GraphqlClient}}, which produces
#' a client (R6 class) with various methods for interacting with a
#' GraphQL server. \code{\link{GraphqlClient}} also accepts various input parameters
#' to set a base URL, and any headers required, which is usually the required
#' set of things needed to connect to a GraphQL service.
#'
#' \code{\link{Query}} is an interface to creating GraphQL queries,
#' which works together with \code{\link{GraphqlClient}}
#'
#' \code{\link{Fragment}} is an interface to creating GraphQL fragments,
#' which works together with \code{\link{GraphqlClient}}
NULL
