#' ghql fragment class
#'
#' @export
#' @return a \code{Fragment} class (R6 class)
#' @section methods:
#' \strong{Methods}
#'   \describe{
#'     \item{\code{fragment(name, x)}}{
#'      create a fragment by name
#'     }
#'   }
#' @format NULL
#' @usage NULL
#' @examples \dontrun{
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
#' }
Fragment <- R6::R6Class(
  "Fragment",
  portable = TRUE,
  cloneable = FALSE,
  public = list(
    fragments = list(),

    print = function(...) {
      cat('<ghql: fragment>', sep = "\n")
      cat('  fragments:\n')
      for (i in seq_along(self$fragments)) {
        cat("   ", names(self$fragments)[i], "\n")
      }
    },

    fragment = function(name, x) {
      self$fragments <-
        c(
          self$fragments,
          stats::setNames(list(structure(x, class = "fragment", name = name)), name)
        )
    }
  )
)

#' @export
print.fragment <- function(x, ...) cat(gsub("^\n\\s+", "", x), "\n")
