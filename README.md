ghql
====



`ghql` - github GraphQL API client

[Github GraphQL API](https://developer.github.com/early-access/graphql/)

## Authentication

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

## basic query


```r
ql('query { viewer { login }}')
#> $data
#> $data$viewer
#> $data$viewer$login
#> [1] "sckott"
```

## more complex query


```r
qry <- '{
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
}'
ql(qry)
#> $data
#> $data$repositoryOwner
#> $data$repositoryOwner$repositories
#> $data$repositoryOwner$repositories$edges
#>        node.name node.totalCount
#> 1 fishbasestatus               0
#> 2          egnar               1
#> 3       habanero              12
#> 4          fluxy               0
#> 5         pygbif               5
```

## Meta

* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
