# Fill zero for column co_ID and co_taxID  ----
fn_fill_zero <- function(x, n){
  if(nchar(x) < n){
    insrt <- rep("0", n - nchar(x)) %>% str_c(collapse = "")
    y <- str_c(insrt , x, collapse = "")
    return(y)
  } else return(x)
}
