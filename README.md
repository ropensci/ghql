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

## load schema

Since not every GraphQL server has a schema at the base URL, have to manually
load the schema in this case


```r
cli$load_schema()
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

## run a local GraphQL server

* Copy the `server.js` file from this package located at `inst/server.js` somewhere on your machine. Can locate it on your machine like `system.file("js/server.js", package = "ghql")`. Or you can run the file from where it's at, up to you.
* Make sure node is installed. If not, see <https://nodejs.org>
* Run `node server.js`
* Navigate to your browser - go to <localhost:4000/graphql>
* Back in R, user that URL to connect


```r
(cli <- graphql("http://localhost:4000/graphql"))
#> <ghql client>
#>   url: http://localhost:4000/graphql
```


```r
cli$query('{
  __schema {
    queryType {
      name, 
      fields {
        name,
        description
      }
    }
  }
}')
```



```r
cli$exec()
#> $data
#> $data$`__schema`
#> $data$`__schema`$queryType
#> $data$`__schema`$queryType$name
#> [1] "Query"
#> 
#> $data$`__schema`$queryType$fields
#>    name description
#> 1 hello            
#> 2  name 
```

## Meta

* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
