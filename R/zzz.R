gh_base <- function() "https://api.github.com/graphql"

ct <- function(x) Filter(Negate(is.null), x)

gh_GET <- function(query, ...){
  temp <- httr::POST(
    gh_base(),
    body = list(query = query),
    ghql_auth(),
    encode = "json",
    ...)
  httr::stop_for_status(temp)
  temp
}

ghql_auth <- function(x) {
  key <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
  if (key == "") stop("no GITHUB_GRAPHQL_TOKEN key found", call. = FALSE)
  httr::add_headers(Authorization = paste0("Bearer ", key))
}

cont <- function(x) {
  httr::content(x, as = 'text', encoding = "UTF-8")
}
