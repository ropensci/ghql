ghql
====



[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![cran checks](https://cranchecks.info/badges/worst/ghql)](https://cranchecks.info/pkgs/ghql)
[![Build Status](https://travis-ci.org/ropensci/ghql.svg?branch=master)](https://travis-ci.org/ropensci/ghql)
[![codecov.io](https://codecov.io/github/ropensci/ghql/coverage.svg?branch=master)](https://codecov.io/github/ropensci/ghql?branch=master)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/ghql)](https://github.com/metacran/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/ghql)](https://cran.r-project.org/package=ghql)

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
[graphql][] package that leverages the [libgraphqlparser][] C++ parser. If the query
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
#> [1] "{\"data\":{\"repositoryOwner\":{\"repositories\":{\"edges\":[{\"node\":{\"name\":\"Headstart\",\"stargazers\":{\"totalCount\":132}}},{\"node\":{\"name\":\"crul\",\"stargazers\":{\"totalCount\":74}}},{\"node\":{\"name\":\"veyor\",\"stargazers\":{\"totalCount\":2}}},{\"node\":{\"name\":\"makeregistry\",\"stargazers\":{\"totalCount\":3}}},{\"node\":{\"name\":\"extcite\",\"stargazers\":{\"totalCount\":6}}}]}}}}\n"
# parse to an R list
jsonlite::fromJSON(x)
#> $data
#> $data$repositoryOwner
#> $data$repositoryOwner$repositories
#> $data$repositoryOwner$repositories$edges
#>      node.name node.totalCount
#> 1    Headstart             132
#> 2         crul              74
#> 3        veyor               2
#> 4 makeregistry               3
#> 5      extcite               6
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

## Example: Datacite

[Datacite](https://datacite.org/) provides DOIs for research data. Check out the 
[Datacite GraphQL docs](https://support.datacite.org/docs/datacite-graphql-api-guide)
to get started. A minimal example:


```r
con <- GraphqlClient$new("https://api.datacite.org/graphql")
qry <- Query$new()
qry$query('dc', '{
  publications(query: "climate") {
    totalCount

    nodes {
      id
      titles {
        title
      }
      descriptions {
        description
      }
      creators {
        name
        familyName
      }
      fundingReferences {
        funderIdentifier
        funderName
        awardTitle
        awardNumber
      }
    }
  }
}')
res <- con$exec(qry$queries$dc)
head(jsonlite::fromJSON(res)$data$publications$nodes)
#>                                     id
#> 1 https://doi.org/10.4122/1.1000000046
#> 2 https://doi.org/10.4122/1.1000000047
#> 3 https://doi.org/10.4122/1.1000000048
#> 4 https://doi.org/10.4122/1.1000000054
#> 5 https://doi.org/10.4122/1.1000000055
#> 6 https://doi.org/10.4122/1.1000000056
#>                                                     titles
#> 1                    Single Cell Protein from Landfill Gas
#> 2                    Single Cell Protein from Landfill Gas
#> 3                    Single Cell Protein from Landfill Gas
#> 4                        Reengineering of Tietgenkollegiet
#> 5                        Reengineering of Tietgenkollegiet
#> 6 Reengineering of Tietgen Kollegiet into a green building
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       descriptions
#> 1 Municipal solid waste (MSW) landfills are one of the largest human-generated sources of methane emissions in the United States and other countries globally. Methane is believed to be a very potent greenhouse gas that is a key contributor to global climate change, over 21 times stronger than CO2. Methane also has a short (10-year) atmospheric life. Because methane is both potent and short-lived, reducing methane emissions from MSW landfills is one of the best ways to achieve a near-term beneficial impact in mitigating global climate change. The United States Environmental Protection Agency estimates that a landfill gas (LFG) project will capture roughly 60-90% of the methane emitted from the landfill, depending on system design and effectiveness. The captured methane can be then purified and used for industrial applications, as in this case the production of SCP. Utilizing methane in this way decreases its demand from fossil fuels which is its traditional source.
#> 2 Municipal solid waste (MSW) landfills are one of the largest human-generated sources of methane emissions in the United States and other countries globally. Methane is believed to be a very potent greenhouse gas that is a key contributor to global climate change, over 21 times stronger than CO2. Methane also has a short (10-year) atmospheric life. Because methane is both potent and short-lived, reducing methane emissions from MSW landfills is one of the best ways to achieve a near-term beneficial impact in mitigating global climate change. The United States Environmental Protection Agency estimates that a landfill gas (LFG) project will capture roughly 60-90% of the methane emitted from the landfill, depending on system design and effectiveness. The captured methane can be then purified and used for industrial applications, as in this case the production of SCP. Utilizing methane in this way decreases its demand from fossil fuels which is its traditional source.
#> 3 Municipal solid waste (MSW) landfills are one of the largest human-generated sources of methane emissions in the United States and other countries globally. Methane is believed to be a very potent greenhouse gas that is a key contributor to global climate change, over 21 times stronger than CO2. Methane also has a short (10-year) atmospheric life. Because methane is both potent and short-lived, reducing methane emissions from MSW landfills is one of the best ways to achieve a near-term beneficial impact in mitigating global climate change. The United States Environmental Protection Agency estimates that a landfill gas (LFG) project will capture roughly 60-90% of the methane emitted from the landfill, depending on system design and effectiveness. The captured methane can be then purified and used for industrial applications, as in this case the production of SCP. Utilizing methane in this way decreases its demand from fossil fuels which is its traditional source.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Integrated functional design project containing reengineering of Tietgenkollegiet. The purpose is to meet the requirements of low energy class 1, and a satisfying inddor air climate and level of daylight.
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Integrated functional design project containing reengineering of Tietgenkollegiet. The purpose is to meet the requirements of low energy class 1, and a satisfying inddor air climate and level of daylight.
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Reengineering of Tietgen Kollegiet into a green building in terms of energy consumption and indoor climate.
#>                                                                                                                                            creators
#> 1                                                                                 Babi, Deenesh, Price, Jason, Woodley, Prof. John, Babi, Price, NA
#> 2                                                                                 Babi, Deenesh, Price, Jason, Woodley, Prof. John, Babi, Price, NA
#> 3                                                                                 Babi, Deenesh, Price, Jason, Woodley, Prof. John, Babi, Price, NA
#> 4                           Chaachouh, Hassan Valid, Pedersen, Stine Holst, Alilou, Zahra, Hvid, Christian Anker, Chaachouh, Pedersen, Alilou, Hvid
#> 5                           Chaachouh, Hassan Valid, Pedersen, Stine Holst, Alilou, Zahra, Hvid, Christian Anker, Chaachouh, Pedersen, Alilou, Hvid
#> 6 Løvborg, Daniel, Holck, Jakob Trier, Sørensen, Jannie Bakkær, Birkemose, Stig, Hviid, Christian Anker, Løvborg, Holck, Sørensen, Birkemose, Hviid
#>   fundingReferences
#> 1              NULL
#> 2              NULL
#> 3              NULL
#> 4              NULL
#> 5              NULL
#> 6              NULL
```
## Example: Countries Data
A public GraphQL API for information about countries, continents, and languages. This project uses Countries List and provinces as data sources, so the schema follows the shape of that data, with a few exceptions:

Link to the GraphQL schema api
```r
link <- 'https://countries.trevorblades.com/'
```

Create a new graphqlClient object 
```r
conn <- GraphqlClient$new(url = link)
```

Define a Graphql Query
```r
query <- '
query($code: ID!){
  country(code: $code){
    name
    native
    capital
    currency
    phone
    languages{
      code
      name
    }
  }
}'
```

The `ghql` query class and define query in a character string
```r
new <- Query$new()$query('link', query)
```

Inspecting the schema
```r
new$link
## query($code: ID!){
##   country(code: $code){
##     name
##     native
##     capital
##     currency
##     phone
##     languages{
##       code
##       name
##     }
##   }
## }
```

Define a variable as a named list
```r
variable <- list(
  code = "DE"
)
```

Let's make a request, passing in the query and then the variables. After all that you can convert the raw object to a structured json object
```r
result <- conn$exec(new$link, variables = variable) %>% 
  fromJSON(flatten = F)
result
## $data
## $data$country
## $data$country$name
## [1] "Germany"
## 
## $data$country$native
## [1] "Deutschland"
## 
## $data$country$capital
## [1] "Berlin"
## 
## $data$country$currency
## [1] "EUR"
## 
## $data$country$phone
## [1] "49"
## 
## $data$country$languages
##   code   name
## 1   de German
```

Convert the json data into a tibble object
```r
country_data <- result$data$country %>% 
  as_tibble()
country_data
## # A tibble: 1 x 6
##   name    native      capital currency phone languages$code $name 
##   <chr>   <chr>       <chr>   <chr>    <chr> <chr>          <chr> 
## 1 Germany Deutschland Berlin  EUR      49    de             German
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
