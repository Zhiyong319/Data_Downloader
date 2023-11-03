### retrive the address info (street + city + state + country) from Latitude/Longitude

rm(list = ls())

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(httr)
library(jsonlite)

source('../myRfunctions/myRfunctions.R')

sites <- read.csv('myfile.csv') # MUST include columns: Latitude and Longitude
sites$state <- NA
sites$country <- NA
sites$zipcode <- NA

API_Key <-"your_GOOGLE_API_key" 

for (id in 1:nrow(sites)) {

  geocoding_url <- paste0("https://maps.googleapis.com/maps/api/geocode/json?latlng=",sites$Latitude[id],",",sites$Longitude[id],'&key=',API_Key)
  response <- GET(geocoding_url, content_type_json())
  
  if (response$status_code==200) {
    print(paste(id,'GOOD!'))
  } else {
    print(paste(id,'FAILED!!!'))
  }
  
  # convert raw data to char
  txt <- rawToChar(response$content)
  # txt <- content(response, as="text", encoding="UTF-8")
  
  # convert JSON data to list
  dat = fromJSON(txt,flatten=TRUE,simplifyVector =FALSE)
  
  # parse state and country info
  # compound_code <- strsplit(dat$plus_code$compound_code,",")
  # compound_code <- compound_code[[1]]
  # sites$state[id] <- compound_code[length(compound_code)-1] # the last second item
  # sites$country[id] <- compound_code[length(compound_code)] # the last item
  
  formatted_address <- strsplit(dat$results[[2]]$formatted_address,",")[[1]]
  # formatted_address <- strsplit(dat$results[[3]]$formatted_address,",")[[1]]
  # formatted_address <- strsplit(dat$results[[3]]$formatted_address,",")[[1]]
  # formatted_address <- strsplit(dat$results[[4]]$formatted_address,",")[[1]]
  # formatted_address <- strsplit(dat$results[[5]]$formatted_address,",")[[1]]
  sites$state[id] <- trimws(formatted_address[length(formatted_address)-1]) # the last second item
  sites$country[id] <- trimws(formatted_address[length(formatted_address)]) # the last item
  sites$zipcode[id] <- trimws(strsplit(formatted_address[length(formatted_address)-1]," ")[[1]][3]) # the last second item
  
}

### write data
write.csv(sites,file=myfile) # over-write the original file

### check the results. In some cases,  full state names are returned, not abbreviated
state <- strsplit(sites$state," ")
for (i in 1:length(state)) {
  sites$state[i] <- state[[i]][1]
}
sites$state <- state.name2abb(sites$state)
