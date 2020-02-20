#' @title Fragment
#' @description ghql fragment class
#' @export
#' @return a `Fragment` class (R6 class)
#' @examples
#' # make a fragment class
#' frag <- Fragment$new()
#'
#' # define a fragment
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
#'
#' # define another fragment
#' frag$fragment('Stargazers', '
#'   fragment on Repository {
#'     stargazers(first: 3) {
#'       edges {
#'         node {
#'           name
#'        }
#'     }
#'   }
#' }')
#' frag
#' frag$fragments
#' frag$fragments$Watchers
#' frag$fragments$Stargazers
Fragment <- R6::R6Class(
  "Fragment",
  portable = TRUE,
  cloneable = FALSE,
  public = list(
    #' @field fragments (list) list of fragments
    fragments = list(),

    #' @description print method for the `Fragment` class
    #' @param x self
    #' @param ... ignored
    print = function(x, ...) {
      cat('<ghql: fragment>', sep = "\n")
      cat('  fragments:\n')
      for (i in seq_along(self$fragments)) {
        cat("   ", names(self$fragments)[i], "\n")
      }
    },

    #' @description create a fragment by name
    #' @param name (character) fragment name
    #' @param x (character) the fragment
    #' @return nothing returned; sets fragments internally
    fragment = function(name, x) {
      self$fragments <-
        c(
          self$fragments,
          stats::setNames(list(structure(x, class = "fragment", name = name)),
            name)
        )
    }
  )
)

#' @export
print.fragment <- function(x, ...) cat(gsub("^\n\\s+", "", x), "\n")
