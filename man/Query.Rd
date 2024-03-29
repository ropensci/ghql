% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query-class.R
\name{Query}
\alias{Query}
\title{Query}
\value{
a `Query` class (R6 class)
}
\description{
ghql query class
}
\note{
we run an internal method `check_query()` that runs the public
method `parse2json()` - if the query doesn't pass the libgraphqlparser
parser, we return the error message
}
\examples{
# make a client
qry <- Query$new()

## define query
qry$query('query2', '{
  viewer {
    repositories(last: 10, isFork: false, privacy: PUBLIC) {
      edges {
        node {
          isPrivate
          id
          name
        }
      }
    }
  }
}')
qry
qry$queries
qry$queries$query2

# fragments
## by hand
qry$query('querywithfrag', '{
  ropensci: repositoryOwner(login:"ropensci") {
    repositories(first: 3) {
      edges {
        node {
          ...Watchers
        }
      }
    }
  }
  ropenscilabs: repositoryOwner(login:"ropenscilabs") {
    repositories(first: 3) {
      edges {
        node {
          ...Watchers
        }
      }
    }
  }
}
fragment Watchers on Repository {
  watchers(first: 3) {
    edges {
      node {
        name
      }
    }
  }
}')
qry
qry$queries
qry$queries$querywithfrag


\dontrun{
token <- Sys.getenv("GITHUB_TOKEN")
con <- GraphqlClient$new(
  url = "https://api.github.com/graphql",
  headers = list(Authorization = paste0("Bearer ", token))
)
jsonlite::fromJSON(con$exec(qry$queries$querywithfrag))

## use Fragment class fragments generator
### define query without fragment, but referring to it
qry$query('queryfrag', '{
  ropensci: repositoryOwner(login:"ropensci") {
    repositories(first: 3) {
      edges {
        node {
          ...Watchers
        }
      }
    }
  }
  ropenscilabs: repositoryOwner(login:"ropenscilabs") {
    repositories(first: 3) {
      edges {
        node {
          ...Watchers
        }
      }
    }
  }
}')

### define a fragment, and use it later
frag <- Fragment$new()
frag$fragment('Watchers', '
  fragment on Repository {
    watchers(first: 3) {
      edges {
        node {
          name
       }
    }
  }
}')
frag$fragments
frag$fragments$Watchers

### add the fragment to the query 'queryfrag'
qry$add_fragment('queryfrag', frag$fragments$Watchers)
qry
qry$queries
qry$queries$queryfrag
}
}
\section{Public fields}{
\if{html}{\out{<div class="r6-fields">}}
\describe{
\item{\code{queries}}{(list) list of queries}
}
\if{html}{\out{</div>}}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-print}{\code{Query$print()}}
\item \href{#method-query}{\code{Query$query()}}
\item \href{#method-add_fragment}{\code{Query$add_fragment()}}
\item \href{#method-parse2json}{\code{Query$parse2json()}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-print"></a>}}
\if{latex}{\out{\hypertarget{method-print}{}}}
\subsection{Method \code{print()}}{
print method for the `Query` class
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Query$print(x, ...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{x}}{self}

\item{\code{...}}{ignored}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-query"></a>}}
\if{latex}{\out{\hypertarget{method-query}{}}}
\subsection{Method \code{query()}}{
define query in a character string
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Query$query(name, x)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{name}}{(character) name of the query}

\item{\code{x}}{(character) the query}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
nothing returned; sets query with `name` internally
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-add_fragment"></a>}}
\if{latex}{\out{\hypertarget{method-add_fragment}{}}}
\subsection{Method \code{add_fragment()}}{
add a fragment to a query
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Query$add_fragment(query_name, fragment)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{query_name}}{(character) the query name to add the fragment to}

\item{\code{fragment}}{(character) the fragment itself}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
nothing returned; sets the fragment with the query
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-parse2json"></a>}}
\if{latex}{\out{\hypertarget{method-parse2json}{}}}
\subsection{Method \code{parse2json()}}{
parse query string with libgraphqlparser and get back JSON
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Query$parse2json(query, parse_schema = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{query}}{(character) a query to parse}

\item{\code{parse_schema}}{(logical) enable schema definition parsing?
default: `FAlSE`}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
adf
}
}
}
