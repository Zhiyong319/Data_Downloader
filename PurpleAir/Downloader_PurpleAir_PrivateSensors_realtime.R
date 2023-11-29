rm(list = ls())

library(httr)
library(jsonlite)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

sensors <- read.csv('Sensors_List.csv')

API_Key <-"your_API_key"

for (id in 1:nrow(sensors)) {
# real time
  pa_url <- paste0("https://api.purpleair.com/v1/sensors/",sensors$Sensor_ID[id],"?read_key=",sensors$Key[id])
  response <- GET(pa_url,
                  content_type_json(),
                  add_headers('X-API-Key' = API_Key) )

  if (response$status_code==200) {
    print(paste(sensors$Sensor_ID[id],sensors$Name[id],'download GOOD!'))
  } else {
    print(paste(sensors$Sensor_ID[id],sensors$Name[id], 'download FAILED!!!'))
  }
  
# convert raw data to char
  txt <- rawToChar(response$content)
# txt <- content(response, as="text", encoding="UTF-8")

# convert JSON data to list
  dat = fromJSON(txt,flatten=TRUE,simplifyVector =FALSE)
  
  if (length(dat$sensor$longitude)>0) {
    sensors$longitude[id] <- dat$sensor$longitude
    sensors$latitude[id]  <- dat$sensor$latitude
  } else {
    print(paste(sensors$Sensor_ID[id],sensors$Name[id], 'Can not access the lon and lat data!!!'))
    sensors$longitude[id] <- NA
    sensors$latitude[id]  <- NA
  }
  
  print(dat)
  
}