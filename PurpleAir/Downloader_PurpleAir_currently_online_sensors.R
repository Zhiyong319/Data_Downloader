### get the real-time sensor info / currently online sensors 

### set the environment
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(httr)
library(jsonlite)
# library(rjson)

api_key <- "2606CD3F-738E-11EE-A8AF-42010A80000A"

# Create JSON and dataframe objects
pa_url <- paste0("https://api.purpleair.com/v1/sensors/?api_key=", api_key, "&fields=name,date_created,last_seen,location_type,latitude,longitude,pm2.5,pm2.5_10minute,pm2.5_60minute,humidity,temperature,private")

pa_json <- fromJSON(pa_url)

sensorList <- as.data.frame(pa_json[["data"]])
pa_header <- as.character(pa_json[["fields"]])
colnames(sensorList) <- pa_header
sensorList$date_created <- as.POSIXct(as.integer(sensorList$date_created), origin="1970-01-01", tz="UTC")
sensorList$last_seen <- as.POSIXct(as.integer(sensorList$last_seen), origin="1970-01-01", tz="UTC")

print(paste0('Derived info for ', nrow(sensorList), ' Sensors'))

# subset sensor list by matching sensor name
sensorList_sub <- sensorList[grepl("TR_RTI_", sensorList$name), ]

#write.csv(sensorList_sub,file='TR_RTIsensorStatus.csv',row.names =FALSE)