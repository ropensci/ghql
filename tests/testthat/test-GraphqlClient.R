test_that("GraphqlClient client initialization works", {
  expect_is(GraphqlClient, "R6ClassGenerator")

  aa <- GraphqlClient$new()

  expect_is(aa, "GraphqlClient")
  expect_is(aa, "R6")
  expect_is(aa$.__enclos_env__, "environment")
  expect_is(aa$print, "function")
  expect_is(aa$ping, "function")
  expect_is(aa$load_schema, "function")
  expect_is(aa$dump_schema, "function")
  expect_is(aa$schema2json, "function")
  expect_is(aa$fragment, "function")
  expect_is(aa$exec, "function")
  expect_is(aa$prep_query, "function")
  expect_null(aa$url)
  expect_null(aa$headers)
  expect_null(aa$schema)
  expect_null(aa$result)
  expect_is(aa$fragments, "list")
  expect_equal(length(aa$fragments), 0)
})

test_that("GraphqlClient construction works", {
  skip_on_cran()

  token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
  aa <- GraphqlClient$new(
    url = "https://api.github.com/graphql",
    headers = list(Authorization = paste0("Bearer ", token))
  )

  # ping method
  expect_true(aa$ping())

  qry <- Query$new()
  qry$query('repos', '{
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
  
  # execute method
  out <- aa$exec(qry$queries$repos)

  expect_is(out, "character")
  expect_match(out, "repositories")
  expect_match(out, "isPrivate")
  
  parsed <- jsonlite::fromJSON(out)
  expect_is(parsed, "list")
  expect_named(parsed, "data")
  expect_is(parsed$data$viewer$repositories$edges, "data.frame")
})

test_that("GraphqlClient construction works with comments inside the query and inside fragment", {
  skip_on_cran()

  token <- Sys.getenv("GITHUB_GRAPHQL_TOKEN")
  aa <- GraphqlClient$new(
    url = "https://api.github.com/graphql",
    headers = list(Authorization = paste0("Bearer ", token))
  )

  # ping method
  expect_true(aa$ping())

  frag <- Fragment$new()
  frag$fragment('ownerInfo', '
    fragment on RepositoryOwner {
      # we can also comment inside a fragment
      id
      avatarUrl
      resourcePath # that is nice
      url
  }')

  qry <- Query$new()
  qry$query('repos', '{
    # let\'s get two repositories using our fragment
    ghql: repository(owner: "ropensci", name: "ghql") {
      name # the name of the repository
      owner {
        ...ownerInfo # fragment
      }
    }
    jsonlite: repository(owner: "jeroen", name: "jsonlite") {
      name
      owner {
      ...ownerInfo # fragment
      }
    }
  }')
  qry$add_fragment('repos', frag$fragments$ownerInfo)

  
  # execute method
  out <- aa$exec(qry$queries$repos)
  expect_is(out, "character")
  expect_match(out, "ghql")
  expect_match(out, "jsonlite")
  expect_match(out, "avatarUrl")
  
  parsed <- jsonlite::fromJSON(out)
  expect_is(parsed, "list")
  expect_named(parsed, "data")
  expect_is(parsed$data$ghql, "list")
  expect_is(parsed$data$jsonlite, "list")
})

test_that("GraphqlClient class fails well", {
  expect_error(GraphqlClient$new(a = 5), "unused argument")

  rr <- GraphqlClient$new()
  expect_error(rr$fragment(), "argument \"name\" is missing")
  expect_error(rr$exec(), "argument \"query\" is missing")
})
