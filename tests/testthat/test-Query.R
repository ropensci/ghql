test_that("Query client initialization works", {
  expect_is(Query, "R6ClassGenerator")

	aa <- Query$new()

  expect_is(aa, "Query")
  expect_is(aa, "R6")
  expect_is(aa$.__enclos_env__, "environment")
  expect_is(aa$add_fragment, "function")
  expect_is(aa$queries, "list")
  expect_equal(length(aa$queries), 0)
})

test_that("Query query construction works", {
  aa <- Query$new()

	aa$query('myquery', '{ field(arg:"") }')

  expect_is(aa, "Query")
  expect_equal(length(aa$queries), 1)
  expect_named(aa$queries, "myquery")
  expect_named(aa$queries$myquery, c('query', 'fragment'))
  expect_identical(aa$queries$myquery$query, '{ field(arg:"") }')
})

test_that("Query class fails well", {
  expect_error(Query$new(a = 5), "there is no initialize method")

  rr <- Query$new()
  expect_error(rr$add_fragment(), "argument \"query_name\" is missing")
  expect_error(rr$query('adsfafafd'), "argument \"x\" is missing")
})

test_that("Query checks queries - and fails as expected", {
  qry <- Query$new()  
  expect_error(qry$query(x = 'adsfafafd'), "syntax error")
  expect_error(qry$query('x', 'query { }'), "1.9: syntax error, unexpected }")
  expect_error(qry$query('x', 'query myQuery { \a }'),
    "1.17: unrecognized character")
  expect_error(qry$query('x', '{ field(arg:\"\b\") }'),
    "1.13-14: unrecognized character")
})
