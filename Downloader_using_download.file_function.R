# This script uses the R function download.file() to download files from http://
# It can be extended to any http:// .

### set the environment
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(httr)

options(timeout=10000) # set a large timeout limit

### download files
for (ifile in 1:60) {
  
  # file <- paste0('2019ge_eftables_cb6_st',formatC(ifile, width=2, flag="0"),'.zip')
  file <- paste0('2019ge_eftables_cb6_st',ifile,'.zip')
  destPath <- 'C:/Users/zwu/Downloads/2019/2019emissions/'
  destfile <- paste0(destPath,file)
  
  if (!file.exists(destfile)) { 
    
    theURL <- paste0('https://gaftp.epa.gov/Air/emismod/2019/2019emissions/moves_eftables/',file)
    
    hd <- HEAD(theURL)
    status <- hd$all_headers[[1]]$status
    
    if (status==200) {
      download.file(theURL,destfile)
    } else if(status==404) {
      print('File does not exist on the server!')
    } else {
      print(paste0('Something wrong happened: status=',status))
    }
    
  } else {
    
    print('File exists on the local disk. No need to download! But please check if the file is compeleted!')
  
    }
}
