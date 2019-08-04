# D200Crawler

## 程式簡介
依據輸入的公司名單，到[公開資訊觀測站](https://mops.twse.com.tw/mops/web/t57sb01_q5)自動下載公司年報至*download*資料夾，並在下載完成後，在*log*資料夾內，輸出程式記錄檔`web.txt`與`output_complete.csv`。

## 版本資訊
- R-3.6.0 for Windows (32/64 bit)
- [Selenium Standalone Server-3.141.59](https://bit.ly/2TlkRyu)
- [ChromeDriver-74.0.3729.6 (Win32)](https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_win32.zip)

>*以上版本軟體都已經在目錄內，只要再將`R-3.6.0-win.rar`解壓縮並安裝即可。*  
>*另外，為使Selenium能夠運行，請先安裝[JAVA](https://www.java.com/zh_TW/download/)。*

## 使用說明
### 安裝套件
```
> install.packages("RSelenium")
> install.packages("magrittr")
> install.packages("stringr")
> install.packages("purrr")
> install.packages("dplyr")
> install.packages("readr")
```

### 檔案格式
- 檔案格式*CSV*，編碼格式*BIG5*，檔名要改成**target_list**。
- 欄位共有*4*欄，名稱由左至右依序為：
    1. **year**：要抓取的年報民國年分。
    2. **co_ID**：用來查詢年報的公司代碼。
    3. **co_name**：公司名稱。
    4. **co_taxID**：下載後要命名年報的名稱。
    
### 操作流程
1. 將符合格式的公司名單放至*data*資料夾內。
2. 開啟`web.bat`批次執行檔，*chrome*會開啟並開始下載程序。
3. 當批次執行檔畫面出現**請按任意鍵繼續**時，表示完成下載，這時即可關閉視窗。
> *資料夾說明：*
>- *data：讀取檔案的資料夾，用來放公司名單*
>- *download：年報下載後的存放位置*
>- *log：輸出程式執行紀錄檔的位置*

### 注意事項
1. 若開啟`web.bat`批次執行檔後不久，就出現**請按任意鍵繼續**的畫面，請關閉批次執行檔並重新啟動。
2. 程式運行中，不可以任意關閉批次執行檔及運作中的*chrome*。
3. 若瀏覽器顯示**查詢過量**、**頁面無法執行**或是**下載過量**，都是正常狀況，約*10*分鐘後程式會繼續下載。
4. 若下載程序未順利完成，且非注意事項1.所述的情況，則*log*資料夾會輸出`output_temp.csv`，記錄錯誤發生時console的訊息。

## 函數內容
1. `fn_download_annual_report(year, co_id, co_taxid)`：  
    主要的爬蟲函數，引述依序分別為*年報年度*、*公司代碼*及*公司統編*。
2. `fn_custom_stop(subclass, message, call = sys.call(-1), ...)`：  
   自定義錯誤處理，輸入*錯誤種類*及*訊息內容*。
3. `fn_fill_zero(x, n)`：  
   處理變數格式問題，輸入要調整的*字串*及*該字串的位數*，位數不足就會在字串前面補零。
