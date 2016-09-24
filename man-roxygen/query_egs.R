#' @examples \dontrun{
#' library("httr")
#' ql('query { }', config=verbose())
#'
#' ql('query { viewer { login email }}', config=verbose())
#'
#' qry <- 'query { search(type: ISSUE, query: "Octocat", first: 30) { edges { node { ... on Issue { title }}}}}'
#' ql(qry, config=verbose())
#'
#' qry <- 'query { search(type: ISSUE, query: "Octocat", first: 30) { edges { node }}}'
#' ql(qry, config=verbose())
#'
#' qry <- '{
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
#' }'
#' ql(qry, config=verbose())
#'
#' qry <- '{
#'   search(type: ISSUE, query: "Starkast", first: 30) {
#'     edges {
#'       node {
#'         ... on Issue {
#'          title
#'          author {
#'            id
#'          }
#'         }
#'      }
#'    }
#'  }
#' }'
#' ql(qry, config=verbose())
#'
#' qry <- '{
#'   repositoryOwner(login:"sckott") {
#'     repositories(first: 5, orderBy: {field:PUSHED_AT,direction:DESC}, isFork:false) {
#'       edges {
#'         node {
#'           name
#'           stargazers {
#'             totalCount
#'           }
#'         }
#'       }
#'     }
#'   }
#' }'
#' res <- ql(qry, config=verbose())
#' res$data
#' res$data$repositoryOwner
#' res$data$repositoryOwner$repositories
#' res$data$repositoryOwner$repositories$edges
#' res$data$repositoryOwner$repositories$edges$node
#' res$data$repositoryOwner$repositories$edges$node$name
#' res$data$repositoryOwner$repositories$edges$node$stargazers
#' res$data$repositoryOwner$repositories$edges$node$stargazers$totalCount
#'
#' # pagination
#' ## get first 30
#' qry <- '{
#'   repositoryOwner(login: "ropensci") {
#'     repositories(first: 30) {
#'       edges {
#'         node {
#'           id
#'           name
#'         }
#'       }
#'     }
#'   }
#' }'
#' ql(qry)
#'
#' ## get last 30 results
#' qry <- '{
#'   repositoryOwner(login: "ropensci") {
#'     repositories(last: 30) {
#'       edges {
#'         node {
#'           id
#'           name
#'         }
#'       }
#'     }
#'   }
#' }'
#' ql(qry)
#'
#' ## get open issues for a repo for a given owner
#' qry <- '{
#'   repositoryOwner(login: "ropensci") {
#'     repository(name: "taxize") {
#'       issues(states:[OPEN], first: 30) {
#'           edges {
#'             node {
#'               number,
#'               title
#'             }
#'           }
#'       }
#'     }
#'   }
#' }'
#' ql(qry)
#' }
