#' Github GraphQL DSL
#'
#' @keywords internal
#' @param x (character) xxx
#' @param ... Curl options passed to \code{\link[httr]{GET}}
#' \itemize{
#'  \item avatarURL (String) - A URL pointing to the user's public avatar.
#'  \item bio (String) - The user's public profile bio.
#'  \item company (String) - The user's public profile company.
#'  \item createdAt (DateTime) - When this user signed up.
#'  \item databaseId (Int) - Identifies the primary key from the database.
#'  \item email (String) - The user's public profile email.
#'  \item isBountyHunter (Boolean) - Whether or not this user is a participant in the GitHub Security Bug Bounty.
#'  \item isDeveloperProgramMember (Boolean) - Whether or not this user is a GitHub Developer Program member.
#'  \item isEmployee (Boolean) - Whether or not this user is a GitHub employee.
#'  \item isSiteAdmin (Boolean) - Whether or not this user is a site administrator.
#'  \item isViewer (Boolean) - Whether or not this user is the viewing user.
#'  \item location (String) - The user's public profile location.
#'  \item login (String) - The username used to login.
#'  \item name (String) - The user's public profile name.
#'  \item repository (Repository) - Find Repository.
#'  \item viewerCanFollow (Boolean) - Whether or not the viewer is able to follow the user.
#'  \item viewerIsFollowing (Boolean) - Whether or not this user is followed by the viewer.
#'  \item websiteURL (String) - A URL pointing to the user's public website/blog.
#' }
#' @examples
#' viewer('.', login)
#' viewer('.', login, email)
#' viewer('.', login, email, watching(first = 10, name, isPrivate))
viewer <- function(.args, ...) {
  viewer_(.args, .dots = lazyeval::lazy_dots(...))
}

viewer_ <- function(.args, login, ..., .dots) {
  #pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  args <- sprintf("{ %s }", paste0(vapply(tmp, function(z) {
    deparse(z$expr)
  }, ""), collapse = " "))
  view <- sprintf("viewer %s", args)
  structure(c(.args, view), class = "ql")
}

watching <- function(.args, ...) {
  watching_(.args, .dots = lazyeval::lazy_dots(...))
}

watching_ <- function(.args, ..., .dots) {
  list(.args, lazyeval::all_dots(.dots, ...))
}

watching <- function(.args, ..., first = NULL, after = NULL, last = NULL, before = NULL) {
  watching_(.args, first = NULL, after = NULL, last = NULL, before = NULL, .dots = lazyeval::lazy_dots(...))
}

watching_ <- function(.args, ..., first = NULL, after = NULL, last = NULL, before = NULL, .dots) {
  args <- list(first = first, after = after, last = last, before = before)
  list(.args, args, lazyeval::all_dots(.dots, ...))
}

# combine_args <- function(x) {
#
# }
