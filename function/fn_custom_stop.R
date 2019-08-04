# Custom condition ----
fn_custom_stop <- function(subclass, message, call = sys.call(-1), ...) {
  err <- structure(
    class = c(subclass, "condition"),
    list(message = message, call = call),
    ...
  )
  stop(err)
}