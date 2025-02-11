test_generator <- function() {
  Sys.setenv(RETURN_ON_DISPATCH = "true")
  generate_abc <- coro::generator(function() {
    withr::defer(Sys.unsetenv("RETURN_ON_DISPATCH"))
    for (x in c("a", "b", "c")) {
      coro::yield(x)
    }
  })

  generate_abc()
}
