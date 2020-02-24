ghql
====



[![Build Status](https://travis-ci.org/ropensci/ghql.svg?branch=master)](https://travis-ci.org/ropensci/ghql)
[![codecov.io](https://codecov.io/github/ropensci/ghql/coverage.svg?branch=master)](https://codecov.io/github/ropensci/ghql?branch=master)

`ghql` - a GraphQL client for R

GraphQL - <https://graphql.org>

Examples of GraphQL APIs:

* GitHub: https://developer.github.com/v4/guides/intro-to-graphql/
* Opentargets: https://genetics-docs.opentargets.org/technical-pipeline/graphql-api

Other GraphQL R packages:

* [graphql][] - GraphQL query parser
* [gqlr][] - GraphQL server and query methods

## GitHub Authentication

Note: To be clear, this R package isn't just for the GitHub GraphQL API, but it
is the most public GraphQL API we can think of, so is used in examples
throughout here.

See https://developer.github.com/v4/guides/intro-to-graphql/ for getting an OAuth token.

Store the token in a env var called `GITHUB_GRAPHQL_TOKEN`

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
con <- GraphqlClient$new(
  url = "https://api.github.com/graphql",
  headers = list(Authorization = paste0("Bearer ", token))
)
```

## load schema

Since not every GraphQL server has a schema at the base URL, have to manually
load the schema in this case


```r
con$load_schema()
```


## Queries

Make a `Query` class object


```r
qry <- Query$new()
```

When you construct queries we check that they are properly formatted using the 
[graphql][] that leverages the [libgraphqlparser][] C++ parser. If the query
is malformed, we return a message as to why the query is malformed.

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
(x <- con$exec(qry$queries$mydata))
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

## Parameterize a query by a variable

Define a query


```r
qry <- Query$new()
qry$query('getgeninfo', 'query getGeneInfo($genId: String!){
  geneInfo(geneId: $genId) {
    id
    symbol
    chromosome
    start
    end
    bioType
    __typename
  }
}')
```

Define a variable as a named list


```r
variables <- list(genId = 'ENSG00000137033')
```

Creat a clint and make a request, passing in the query and then the variables


```r
con <- GraphqlClient$new('https://genetics-api.opentargets.io/graphql')
res <- con$exec(qry$queries$getgeninfo, variables)
jsonlite::fromJSON(res)
#> $data
#> $data$geneInfo
#> $data$geneInfo$id
#> [1] "ENSG00000137033"
#> 
#> $data$geneInfo$symbol
#> [1] "IL33"
#> 
#> $data$geneInfo$chromosome
#> [1] "9"
#> 
#> $data$geneInfo$start
#> [1] 6215786
#> 
#> $data$geneInfo$end
#> [1] 6257983
#> 
#> $data$geneInfo$bioType
#> [1] "protein_coding"
#> 
#> $data$geneInfo$`__typename`
#> [1] "Gene"
```

## run a local GraphQL server

* Copy the `server.js` file from this package located at `inst/server.js` somewhere on your machine. Can locate it on your machine like `system.file("js/server.js", package = "ghql")`. Or you can run the file from where it's at, up to you.
* Make sure node is installed. If not, see <https://nodejs.org>
* Run `node server.js`
* Navigate to your browser - go to http://localhost:4000/graphql
* Back in R, user that URL to connect


```r
(con <- GraphqlClient$new("http://localhost:4000/graphql"))
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
con$exec(xxx$queries$query)
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
[graphql]: https://github.com/ropensci/graphql
[libgraphqlparser]: https://github.com/graphql/libgraphqlparser
[coc]: https://github.com/ropensci/ghql/blob/master/CODE_OF_CONDUCT.md
