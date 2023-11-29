### set the environment
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(httr)
library(jsonlite)
library(openxlsx)
# library(rjson)

### sensor info list
sensors <- read.xlsx('PurpleAirSensors20230713.xlsx', "sensors") # MUST have column: sensor_index

API_Key <- "xxxxxx"

rawdata <- data.frame(matrix(ncol = 0, nrow = 0)) # initiate the data.frame to store data 
for (id in 1:nrow(sensors)) {

  pa_url <- paste("https://api.purpleair.com/v1/sensors/",sensors$sensor_index[id],sep="")
  response <- GET(pa_url,
                  content_type_json(),
                  query = list(fields="name, latitude, longitude, altitude, date_created"),
                  add_headers('X-API-Key' = API_Key) )
  
  if (response$status_code==200) {
    txt <- rawToChar(response$content)
    # txt <- content(response, as="text", encoding="UTF-8")
    
    df <- as.data.frame(fromJSON(txt))
    # df <- read.table(text = txt, sep =",", header = TRUE, stringsAsFactors = FALSE)
    
    rawdata <- rbind(rawdata, df)
  } else {
    print(paste(sensors$sensor_index[id],'download FAILED!!!'))
  }
  
}

rawdata$date_created <- as.POSIXct(rawdata$sensor.date_created, origin="1970-01-01", tz="UTC")
rawdata_out <- rawdata[,c("sensor.name","sensor.sensor_index","date_created","sensor.latitude","sensor.longitude","sensor.altitude")]

write.csv(rawdata_out,file="SensorInfo.csv",row.names =FALSE)
