#### Web scraping ----
# Input company ID and report year,
# and then the report would be downloaded with file name "co_taxID"
fn_download_annual_report <- function(year, co_id, co_taxid){
  
  ## Navigate to website
  url <- str_c(
    "https://doc.twse.com.tw/server-java/t57sb01?step=1&colorchg=1&co_id=", co_id,
    "&year=", year,
    "&mtype=F&",
    sep = ""
  )
  dri$navigate(url)
  # Check error ---
  stop_error <- length(dri$findElements(using = "xpath", xpath_err))
  if(stop_error == 1) fn_custom_stop("stop_error", "website is blocked(1), please wait...\n")
  
  ## Determine whether elem exists -----------------------------------------------------
  my_error <- length(dri$findElements(using = "xpath", "//a[contains(text(), 'F04')]"))
  if(my_error == 0) cat(str_c(paste0("[", i, "]"), co_taxid, "No report found\n", sep = " ")) else{
    
    ## Search for elem and return matched file type
    elem <- dri$findElement(using = "xpath", "//a[contains(text(), 'F04')]")
    url_temp <- elem$getElementAttribute("href") %>% unlist()
    
    file_type <- c("\\.pdf|\\.zip|\\.doc")
    file_type_match <- str_extract(url_temp, file_type)
    
    ## Take corresponding actions -------------------------------------------------------------------
    if(file_type_match == ".pdf"){
      ## Click url, Switch to poping tab and close current page
      elem$clickElement()
      # Check error ---
      stop_error <- length(dri$findElements(using = "xpath", xpath_err))
      if(stop_error == 1) fn_custom_stop("stop_error", "website is blocked(2), please wait...")
      
      url_tab <- dri$getWindowHandles()[[2]]
      dri$closeWindow()
      dri$switchToWindow(windowId = url_tab)
      # Check error ---
      stop_error <- length(dri$findElements(using = "xpath", xpath_err))
      if(stop_error == 1) fn_custom_stop("stop_error", "website is blocked(3), please wait...\n")
      
      
      ## Download through url: Search for element, and extract url
      elem <- dri$findElement(using = "xpath", "//a[contains(text(), 'F04')]") 
      url_download <- elem$getElementAttribute("href") %>% unlist()
      download.file(url_download, destfile = paste0("download/", co_taxid, file_type_match), mode = "wb", quiet = TRUE)
      cat(str_c(paste0("[", i, "]"), co_taxid, "dowwnload successfully\n", sep = " "))
      log_fileType[i] <<- file_type_match
    } else{
      ## Download through post: Search for element, extract text, and generate url
      elem <- dri$findElement(using = "xpath", "//a[contains(text(), 'F04')]") 
      url_part <- elem$getElementText() %>% unlist()
      url_download <- str_c(
        "https://doc.twse.com.tw/server-java/t57sb01?",
        "colorchg=1&step=9&kind=F&co_id=", co_id, "&filename=", url_part,
        sep = ""
      )
      download.file(url_download, destfile = paste0("download/", co_taxid, file_type_match), mode = "wb", quiet = TRUE)
      cat(str_c(paste0("[", i, "]"), co_taxid, "dowwnload successfully\n", sep = " "))
      log_fileType[i] <<- file_type_match
    }
  }
  Sys.sleep(20)
}

