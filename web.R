#### Package/Function ----------------------------------------------------------------------------
packrat::on()
packrat::restore()
library(RSelenium)
library(magrittr)
library(stringr)
library(purrr)
library(dplyr)
library(readr)

source("function/fn_fill_zero.R")
source("function/fn_download_annual_report.R")
source("function/fn_custom_stop.R")

#### Data ---------------------------------------------------------------------------------------
# target_list
colist <- read_csv(
  "data/target_list.csv",
  col_types = cols(
    year = col_character(),
    co_ID = col_character(),
    co_name = col_character(),
    co_taxID = col_character()
  ),
  locale = locale(encoding = "BIG5")
)

colist <- colist %>% 
  mutate(
    co_ID = map_chr(co_ID, ~ fn_fill_zero(.x, 4)),
    co_taxID = map_chr(co_taxID, ~ fn_fill_zero(.x, 8))
  )

# dictionary
err_text <- read.table("data/dictionary.txt", sep = ",", encoding = "ANSI", stringsAsFactors = FALSE)
xpath_err <- str_c("//*[contains(text(), '",  err_text[1, 1], "') or contains(text(), '", err_text[1, 2], "') or contains(text(), '", err_text[1, 3], "')]")
# "//*[contains(text(), '查詢過量') or contains(text(), '頁面無法執行') or contains(text(), '下載過量')]"

#### Chrome Drive -----------------------------------------------------------------------------
system("java -jar selenium-server-standalone-3.141.59.jar" ,wait = FALSE)
dri <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4444,
  browserName = "chrome"
)
dri$open()

#### While Loop -------------------------------------------------------------------------------
log_err <- vector(mode = "character", length = nrow(colist))
log_fileType <- vector(mode = "character", length = nrow(colist))

i = 1
rerun = FALSE
while(i <= nrow(colist)){
  if(rerun){
    message("Continuing...")
    i = i - 1
  }
  rerun <- FALSE
  tryCatch(
    fn_download_annual_report(colist[i, 1], colist[i, 2], colist[i, 4]),
    stop_error = function(cnd){
      message(cnd)
      Sys.sleep(600)
      rerun <<- TRUE
    },
    error = function(cnd){
      console_err <- errorCondition(cnd)$message
      selem_err <- dri$errorDetails() %>% unlist() %>% unname()
      log_err[i] <<- console_err
      
      colist <- colist %>% 
        mutate(
          fileType = log_fileType,
          errMessage = log_err
        )
      write.csv(colist, file = "log/output_temp.csv", row.names = FALSE)
      message("Other error detected; session is terminated.\n")
      dri$close()
      Sys.sleep(600)
      
      message("Re-openning broswer...\n")
      dri$open()
    }
  )
  i = i + 1
}
#### Output log -------------------------------------------------------------------------
colist <- colist %>% 
  mutate(
    fileType = log_fileType,
    errMessage = log_err
  )
write.csv(colist, file = "log/output_complete.csv", row.names = FALSE)
dri$close()
packrat::off()

