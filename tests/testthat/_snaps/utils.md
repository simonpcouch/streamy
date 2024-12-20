# check_generator works

    Code
      check_generator(1)
    Condition
      Error:
      ! `generator` must be the output of `coro::generator(fn)()`, not a number.

---

    Code
      check_generator(NULL)
    Condition
      Error:
      ! `generator` must be the output of `coro::generator(fn)()`, not NULL.

---

    Code
      check_generator(list())
    Condition
      Error:
      ! `generator` must be the output of `coro::generator(fn)()`, not an empty list.

# check_context works

    Code
      check_context(1)
    Condition
      Error:
      ! `context` must be document context from rstudioapi, not a number.

---

    Code
      check_context(NULL)
    Condition
      Error:
      ! `context` must be document context from rstudioapi, not NULL.

---

    Code
      check_context(list())
    Condition
      Error:
      ! `context` must be document context from rstudioapi, not an empty list.

# parse_interface works

    Code
      parse_interface("unknown")
    Condition
      Error:
      ! `interface` should be one of "replace", "prefix", or "suffix", not a string.

---

    Code
      parse_interface(c("replace", "prefix"))
    Condition
      Error:
      ! `interface` should be one of "replace", "prefix", or "suffix", not a character vector.

---

    Code
      parse_interface(1)
    Condition
      Error:
      ! `interface` should be one of "replace", "prefix", or "suffix", not a number.

---

    Code
      parse_interface(NULL)
    Condition
      Error:
      ! `interface` should be one of "replace", "prefix", or "suffix", not NULL.

