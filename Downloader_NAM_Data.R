# This script is designed to run in Windows environment (can be modified to run in Linux)
# It uses the windows executable wget.exe. If wget is not installed, please download a binary 
# from https://eternallybored.org/misc/wget/ and place the executable in the same folder with the
# R script.
  
### set the environment
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

cat("\014")

### login
email = "zwu@rti.org"
pass <- "Wu123456"

system(paste0('wget.exe -O auth_status.rda.ucar.edu --save-cookies auth.rda_ucar_edu  --post-data="email=', email, '&passwd=', pass, '&action=login" https://rda.ucar.edu/cgi-bin/login'))

### time period
Sys.setenv(TZ='GMT')
date_start <- "2018-12-01"  # start date
date_end <- "2018-12-30"  # end date

seq_dates <- seq(as.Date(date_start), as.Date(date_end), by="days")
list_dates <- format(seq_dates, "%Y%m%d") # YYYYMMDD
list_years <- format(seq_dates, "%Y") # YYYYMMDD
hours <- c('00', '06', '12', '18')

### download link
down_link <- vector()
for (i in 1:length(list_dates)) {
  for (j in 1:length(hours)) {
    file_name <- paste0(list_dates[i],'.nam.t',hours[j],'z.awphys00.tm00.grib2')
    down_link <- c( down_link,paste0('https://rda.ucar.edu/data/ds609.0/',list_years[i],'/',file_name) )
  }
}

for (i in 1:length(down_link)){
  file_nam <- substr(down_link[1],40,70)
  
  if (file.exists(file_name)) {
    cat(paste0(file_name, " - already downloaded. \n"))
  } else {
    system(paste0("wget.exe -N --load-cookies auth.rda_ucar_edu ", down_link[i]))
  }
}

system("del auth_status.rda.ucar.edu auth.rda_ucar_edu")

cat("Download finished with:", "\n", length(down_link), "files")