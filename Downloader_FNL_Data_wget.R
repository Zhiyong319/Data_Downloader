### set the environment
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

cat("\014")

### login
email = "your_email"
pass <- "your_password"

system(paste0('wget.exe -O auth_status.rda.ucar.edu --save-cookies auth.rda_ucar_edu  --post-data="email=', email, '&passwd=', pass, '&action=login" https://rda.ucar.edu/cgi-bin/login'))

### time period
Sys.setenv(TZ='GMT')
data_i <- "2008-01-29" #readline(prompt = "Data inicial para analise de dados no formato (AAAA-MM-DD): ")
data_f <- "2008-01-30" #readline(prompt = "Data final para analise de dados no formato (AAAA-MM-DD): ")

seq_dates <- seq(as.POSIXct(data_i), as.POSIXct(data_f), by = "6 hour")
list_dates <- format(seq_dates, "%Y%m%d_%H_00")
file_name <- paste0("fnl_", list_dates, ".grib2") #as.list(paste(my_url, file_name, sep = ""))

if (data_i <= "2007-12-06" & data_f <= "2007-12-06") {
  
  down_link <- paste0("http://rda.ucar.edu/data/ds083.2/grib1/", format(seq_dates, "%Y"), "/", format(seq_dates, "%Y.%m"),"/fnl_", list_dates, ".grib1")
  
} else if (data_i >= "2007-12-06" & data_f >= "2007-12-06") {
  
  down_link <- paste0("http://rda.ucar.edu/data/OS/ds083.2/grib2/", format(seq_dates, "%Y"), "/", format(seq_dates, "%Y.%m"),"/fnl_", list_dates, ".grib2")
  
}

for (i in 1:length(file_name)){
  
  if (file.exists(file_name[i])) {
    
    cat(paste0(file_name[i], " - already downloaded. \n"))
    
  } else {
    
    system(paste0("wget.exe -N --load-cookies auth.rda_ucar_edu ", down_link[i]))
    
  }
}

system(paste0("del auth_status.rda.ucar.edu auth.rda_ucar_edu"))

cat("Download finished with:", "\n", length(file_name), "files")
