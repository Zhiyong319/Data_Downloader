rm(list = ls())

library(httr)
library(jsonlite)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

sensors <- read.csv('../Private_Sensors.csv')
API_Key <-"8C362491-3A53-11EB-9893-42010A8001E8"

# set the start and end time and create full time sequences 
starttime <- as.POSIXct("2022-01-01 05:00:00 UTC", origin="1970-01-01", tz="UTC")
endtime   <- as.POSIXct("2022-06-27 05:00:00 UTC", origin="1970-01-01", tz="UTC")
TIME_seq <- seq(unclass(starttime),unclass(endtime),10*60) # 10 min interval
TIME <- as.POSIXct(TIME_seq, origin="1970-01-01", tz="UTC")

# Loop to download data for each site and each day
ndays <- (unclass(endtime)-unclass(starttime))/(24*60*60)
stime <- starttime

for (id in 1:nrow(sensors)) {
  
  rawdata <- data.frame(matrix(ncol = 0, nrow = 0)) # initiate the data.frame to store data 
  for (iday in 1:ndays) {
  
# currently Purple Air API allows a maximum length of 3 days for 10 min average data download
# URL example: https://api.purpleair.com/v1/sensors/128079/history/csv?read_key=GK4UAC7T968I8KME&start_timestamp=1640995200&end_timestamp=1654732800&average=10&fields=humidity_a%2Chumidity_b%2Ctemperature_a%2Ctemperature_b%2Cpressure_a%2Cpressure_b

    pa_url <- paste("https://june2022.api.purpleair.com/v1/sensors/",sensors$Sensor_ID[id],"/history/csv?read_key=",sensors$Key[id],sep="")
    response <- GET(pa_url,
                content_type_json(),
                query = list(start_timestamp=unclass(stime),end_timestamp=unclass(stime)+24*60*60,average=10,
                             fields="pm2.5_cf_1_a,pm2.5_atm_a,pm10.0_cf_1_a,pm10.0_atm_a,humidity_a,temperature_a,pressure_a"),
                add_headers('X-API-Key' = API_Key) )
    
    if (response$status_code==200) {
      print(paste(sensors$Sensor_ID[id],sensors$Name[id],stime,'iday:',iday,'download GOOD!'))
    } else {
      print(paste(sensors$Sensor_ID[id],sensors$Name[id],stime,'iday:',iday,'download FAILED!!!'))
    }

# convert raw data to char
    txt <- rawToChar(response$content)
   # txt <- content(response, as="text", encoding="UTF-8")
  
    if (nchar(txt)>1) {
      df <- read.table(text = txt, sep =",", header = TRUE, stringsAsFactors = FALSE)
      rawdata <- rbind(rawdata, df)
    } else {
      print(paste(sensors$Sensor_ID[id],sensors$Name[id],stime,'iday:',iday,'Data not available!'))
    }
    
    stime <- stime + 24*60*60
  }
  
  rawdata$time <- as.POSIXct(rawdata$time_stamp, origin="1970-01-01", tz="UTC")

# adds rows of NAs for the periods of missing records 
  emptyrow <- rawdata[1,]
  emptyrow[1,] <- NA  # data.frame with NAs
  missingrows <- data.frame(matrix(ncol = 0, nrow = 0))
  for (ii in 1:length(TIME)) {
    if (length(which(rawdata$time==TIME[ii]))==0) {
      emptyrow$time_stamp <- unclass(TIME[ii])
      emptyrow$time <-TIME[ii]
      missingrows <- rbind(missingrows, emptyrow)
    }
  }

  rawdata <- rbind(rawdata,missingrows)

  rawdata_sort <- rawdata[order(rawdata$time_stamp),]
  rawdata_sort$label <- sensors$Sensor_ID[id]
  rawdata_sort$longitude <- sensors$longitude[id]
  rawdata_sort$latitude <- sensors$latitude[id]
  rawdata_sort$pm2.5_cf_1_b <- NA

  rawdata_out <- rawdata_sort[,c('label','latitude','longitude','time','pm2.5_cf_1_a','pm2.5_cf_1_b','temperature_a','humidity_a','pressure_a','pm2.5_atm_a','pm10.0_cf_1_a','pm10.0_atm_a')]

  filename <- paste('../Data/Raw/Rcode downloading/SensorID',sensors$Sensor_ID[id],'_',sensors$Name[id],'_10min.csv',sep="")
  write.csv(rawdata_out,file=filename,row.names =FALSE)

}