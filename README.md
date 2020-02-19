ghql
====



[![Build Status](https://travis-ci.org/ropensci/ghql.svg?branch=master)](https://travis-ci.org/ropensci/ghql)
[![codecov.io](https://codecov.io/github/ropensci/ghql/coverage.svg?branch=master)](https://codecov.io/github/ropensci/ghql?branch=master)

`ghql` - general purpose GraphQL client

GraphQL - <https://graphql.org>

Examples of GraphQL APIs:

* GitHub: https://developer.github.com/v4/guides/intro-to-graphql/
* Opentargets: http://open-targets-genetics.appspot.com/

Other GraphQL R projects:

* [graphql](https://github.com/ropensci/graphql) - GraphQL query parser
* [gqlr][] - GraphQL server and query methods

## Github Authentication

See https://developer.github.com/v4/guides/intro-to-graphql/ for getting an OAuth token.

Store the token in a env var called `GITHUB_GRAPHQL_TOKEN`
before trying this pkg.

## Install

CRAN version


```r
install.packages("ghql")
```

Development version


```r
remotes::install_github("ropensci/ghql")
```


```r
library("ghql")
library("jsonlite")
```

## initialize client


```r
token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
cli <- GraphqlClient$new(
  url = "https://api.github.com/graphql",
  headers = list(Authorization = paste0("Bearer ", token))
)
```

## load schema

Since not every GraphQL server has a schema at the base URL, have to manually
load the schema in this case


```r
cli$load_schema()
```


## basic query

Make a `Query` class object


```r
qry <- Query$new()
```

Get some stargazer counts


```r
qry$query('mydata', '{
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
qry
#> <ghql: query>
#>   queries:
#>     mydata
qry$queries$mydata
#>  
#>  {
#>   repositoryOwner(login:"sckott") {
#>     repositories(first: 5, orderBy: {field:PUSHED_AT,direction:DESC}, isFork:false) {
#>       edges {
#>         node {
#>           name
#>           stargazers {
#>             totalCount
#>           }
#>         }
#>       }
#>     }
#>   }
#> }
```


```r
# returns json
(x <- cli$exec(qry$queries$mydata))
#> [1] "{\"data\":{\"repositoryOwner\":{\"repositories\":{\"edges\":[{\"node\":{\"name\":\"Headstart\",\"stargazers\":{\"totalCount\":124}}},{\"node\":{\"name\":\"extcite\",\"stargazers\":{\"totalCount\":5}}},{\"node\":{\"name\":\"serrano\",\"stargazers\":{\"totalCount\":19}}},{\"node\":{\"name\":\"soylocs\",\"stargazers\":{\"totalCount\":2}}},{\"node\":{\"name\":\"makeregistry\",\"stargazers\":{\"totalCount\":3}}}]}}}}\n"
# parse to an R list
jsonlite::fromJSON(x)
#> $data
#> $data$repositoryOwner
#> $data$repositoryOwner$repositories
#> $data$repositoryOwner$repositories$edges
#>      node.name node.totalCount
#> 1    Headstart             124
#> 2      extcite               5
#> 3      serrano              19
#> 4      soylocs               2
#> 5 makeregistry               3
```

## run a local GraphQL server

* Copy the `server.js` file from this package located at `inst/server.js` somewhere on your machine. Can locate it on your machine like `system.file("js/server.js", package = "ghql")`. Or you can run the file from where it's at, up to you.
* Make sure node is installed. If not, see <https://nodejs.org>
* Run `node server.js`
* Navigate to your browser - go to http://localhost:4000/graphql
* Back in R, user that URL to connect


```r
(cli <- GraphqlClient$new("http://localhost:4000/graphql"))
#> <ghql client>
#>   url: http://localhost:4000/graphql
```


```r
xxx <- Query$new()
xxx$query('query', '{
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
cli$exec(xxx$queries$query)
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

* Please note that this project is released with a [Contributor Code of Conduct][coc]. By participating in this project you agree to abide by its terms.

[gqlr]: https://github.com/schloerke/gqlr
[coc]: https://github.com/ropensci/ghql/blob/master/CODE_OF_CONDUCT.md
