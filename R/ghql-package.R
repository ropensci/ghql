#' @title ghql
#'
#' @description General purpose GraphQL client
#'
#' @name ghql-package
#' @import lazyeval
#' @aliases ghql
#' @docType package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @keywords package
#'
#' @section ghql API:
#' The main interface in this package is \code{\link{graphql}}, which produces
#' a client (R6 class) with various methods for interacting with a
#' GraphQL server. \code{\link{graphql}} also accepts various input parameters
#' to set a base URL, and any headers required, which is usually the required
#' set of things needed to connect to a GraphQL service.
#'
#' See \code{\link{graphql}} for more info.
NULL
