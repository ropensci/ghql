test_that("Fragment initialization works", {
  expect_is(Fragment, "R6ClassGenerator")

  aa <- Fragment$new()

  expect_is(aa, "Fragment")
  expect_is(aa, "R6")
  expect_is(aa$.__enclos_env__, "environment")
  expect_is(aa$fragment, "function")
  expect_is(aa$fragments, "list")
  expect_is(aa$print, "function")
  expect_equal(length(aa$fragments), 0)
})

test_that("Fragment construction works", {
  aa <- Fragment$new()

  aa$fragment('Watchers', '
    fragment on Repository {
      watchers(first: 3) {
        edges {
          node {
            name
         }
      }
    }
  }')

  expect_is(aa, "Fragment")
  expect_equal(length(aa$fragments), 1)
  expect_named(aa$fragments, "Watchers")
  expect_is(aa$fragments$Watchers, "fragment")
  expect_is(unclass(aa$fragments$Watchers), "character")
})

test_that("Fragment class fails well", {
  expect_error(Fragment$new(a = 5), "there is no initialize method")

  rr <- Fragment$new()
  expect_error(rr$fragment(), "\"name\" is missing")
})
