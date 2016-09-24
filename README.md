ghql
====

[![Build Status](https://travis-ci.org/ropensci/ghql.svg?branch=master)](https://travis-ci.org/ropensci/ghql)

`ghql` - general purpose GraphQL client

GraphQL - <http://graphql.org>

Examples of GraphQL APIs:

* [Github GraphQL API](https://developer.github.com/early-access/graphql/)

## Github Authentication

See <https://developer.github.com/early-access/graphql/guides/accessing-graphql/> for getting an OAuth token.

Store the token in a env var called `GITHUB_GRAPHQL_TOKEN`
before trying this pkg.

## Install

Development version


```r
devtools::install_github("ropensci/ghql")
```


```r
library("ghql")
library("jsonlite")
```

## initialize client


```r
library("httr")
token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
cli <- graphql(
  url = "https://api.github.com/graphql",
  headers = add_headers(Authorization = paste0("Bearer ", token))
)
```

## basic query


```r
cli$query('query { }')
cli$query_string
#> [1] "query { }"
```


```r
cli$exec()
#> $data
#> named list()
```


## more complex query


```r
cli$query('{
  repositoryOwner(login:"sckott") {
    repositories(first: 5, orderBy: {field:PUSHED_AT,direction:DESC}, isFork:false) {
      edges {
        node {
          name
          stargazers {
            totalCount
          }
        }
      }
    }
  }
}')
cli$query_string
#> [1] "{  repositoryOwner(login:\"sckott\") {    repositories(first: 5, orderBy: {field:PUSHED_AT,direction:DESC}, isFork:false) {      edges {        node {          name          stargazers {            totalCount          }        }      }    }  }}"
```


```r
cli$exec()
#> $data
#> $data$repositoryOwner
#> $data$repositoryOwner$repositories
#> $data$repositoryOwner$repositories$edges
#>        node.name node.totalCount
#> 1 fishbasestatus               0
#> 2          egnar               1
#> 3       habanero              12
#> 4          fluxy               0
#> 5         pygbif               6
```

## Meta

* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
