#' @examples \dontrun{
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
#' }
