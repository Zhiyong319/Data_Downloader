### set the environment
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(httr)
library(jsonlite)
library(openxlsx)
# library(rjson)

### sensor info list
sensors <- read.xlsx('PurpleAirSensors20230713.xlsx', "SensorInfo")
# str(sensors)

API_Key <- "xxxxx" 

# The map has history data period limits. They are as follows:
#   
# Real-time: 2 days
# 10-minute : 3 days
# 30-minute: 7 days
# 1-hour: 14 days
# 6-hour: 90 days
# 1-day: 1 year
# 1-week: 5 years
# 1-month: 20 years
# 1-year: 100 years

# adjust time_step based on time_interval (see the above look-up table)
time_interval <- 60 # The desired average in minutes, one of the following: 0 (real-time), 10 (default if not specified), 30, 60, 360 (6 hour), 1440 (1 day)
time_step <- 14*24*60*60 # in seconds

for (id in 1:nrow(sensors)) {
  
  # set the start and end time 
  starttime <- as.POSIXct("2020-12-31 00:00:00 UTC", origin="1970-01-01", tz="UTC")
  endtime   <- as.POSIXct("2023-07-01 23:00:00 UTC", origin="1970-01-01", tz="UTC")
  
  rawdata <- data.frame(matrix(ncol = 0, nrow = 0)) # initiate the data.frame to store data
  while (starttime < endtime) {
   
    pa_url <- paste("https://api.purpleair.com/v1/sensors/",sensors$sensor_index[id],"/history/csv?",sep="")
    response <- GET(pa_url,
                content_type_json(),
                query = list(start_timestamp = unclass(starttime), 
                             end_timestamp = unclass(starttime)+time_step, 
                             average = time_interval,
                             fields = "pm2.5_atm_a,pm2.5_atm_b,humidity,temperature,pressure"),
                add_headers('X-API-Key' = API_Key) )
    
    if (response$status_code==200) {
      
      # convert raw data to char
      txt <- rawToChar(response$content)
      # txt <- content(response, as="text", encoding="UTF-8")
      
      df <- read.table(text = txt, sep =",", header = TRUE, stringsAsFactors = FALSE)
      rawdata <- rbind(rawdata, df)
      
      if (nrow(df)>0) {
        print(paste(sensors$sensor_index[id],starttime,'download GOOD, but no data avaiable!'))
      } else {
        print(paste(sensors$sensor_index[id],starttime,'download GOOD!'))
      }
      
    } else {
      print(paste(sensors$sensor_index[id],starttime,'download FAILED!!!'))
    }

    starttime <- starttime + time_step
    
    Sys.sleep(3) # Delay Between API Calls in seconds
    
  } # end of time loop
  
  # check if at least 1 row of data is available
  if (nrow(rawdata)>1) {
    rawdata$time <- as.POSIXct(rawdata$time_stamp, origin="1970-01-01", tz="UTC")
    
    rawdata_out <- rawdata[,c('sensor_index','time','pm2.5_atm_a','pm2.5_atm_b','temperature','humidity','pressure')]
    
    filename <- paste(sensors$sensor_name[id],'_60min.csv',sep="")
    write.csv(rawdata_out,file=filename,row.names =FALSE)
  } else {
    print('!!!',paste(sensors$sensor_index[id],'no data avaiable during the defined period !!!'))
  }
  
} # end of sensor loop
