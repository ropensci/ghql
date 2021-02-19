gh_base <- function() "https://api.github.com/graphql"

ct <- function(x) Filter(Negate(is.null), x)

gh_POST <- function(url, body, headers, ...){
  con <- crul::HttpClient$new(url, headers = headers, opts = list(...))
  res <- con$post(body = body, encode = "json")
  err(res)
  res
}

gh_GET <- function(url, headers, ...){
  con <- crul::HttpClient$new(url, headers = headers, opts = list(...))
  res <- con$get()
  res$raise_for_status()
  res
}

gh_HEAD <- function(url, headers, ...){
  con <- crul::HttpClient$new(url, headers = headers, opts = list(...))
  res <- con$head()
  res$raise_for_status()
  res
}

err <- function(x) {
  if (x$status_code >= 400) {
    mssg <- x$parse("UTF-8")
    if (!nzchar(mssg)) mssg <- x$status_http()$message
    stop(sprintf("[HTTP %s]", x$status_code), " ", mssg, call. = FALSE)
  }
}

cont <- function(x, encoding = "UTF-8") x$parse(encoding = encoding)

parze <- function(x) jsonlite::fromJSON(x)

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
