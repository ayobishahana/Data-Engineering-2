
# Loading Packages
library(httr)
library(aws.s3)
library(jsonlite)
library(lubridate)
library(testit)


# Activating
keyfile = list.files(path=".", pattern="accessKeys.csv", full.names=TRUE)
if (identical(keyfile, character(0))){
  stop("ERROR: AWS key file not found")
} 
keyTable <- read.csv(keyfile, header = T) # *accessKeys.csv == the CSV downloaded from AWS containing your Access & Secret keys
AWS_ACCESS_KEY_ID <- as.character(keyTable$Access.key.ID)
AWS_SECRET_ACCESS_KEY <- as.character(keyTable$Secret.access.key)

Sys.setenv("AWS_ACCESS_KEY_ID" = AWS_ACCESS_KEY_ID,
           "AWS_SECRET_ACCESS_KEY" = AWS_SECRET_ACCESS_KEY,
           "AWS_DEFAULT_REGION" = "eu-west-1") 


## Setting the subject date
DATE_PARAM="2022-10-20"
date <- as.Date(DATE_PARAM, "%Y-%m-%d")


# Getting the top page-views data from Wikipedia
url <- paste(
  "https://wikimedia.org/api/rest_v1/metrics/pageviews/top/en.wikipedia.org/all-access/",
  format(date, "%Y/%m/%d"), sep='')


# Saving the Raw Response
print(paste('Requesting REST API URL: ', url, sep=''))
wiki.server.response = GET(url)
wiki.response.status = status_code(wiki.server.response)
wiki.response.body = content(wiki.server.response, 'text')
print(paste('Wikipedia REST API Response body: ', wiki.response.body, sep=''))
print(paste('Wikipedia REST API Response Code: ', wiki.response.status, sep=''))

# Saving the API response to raw-views folder
RAW_LOCATION_BASE='raw-views'
dir.create(file.path(RAW_LOCATION_BASE), showWarnings = TRUE, recursive = TRUE)
print(paste('The folder to save page-views:', file.path(RAW_LOCATION_BASE), sep=' '))
raw.output.filename = paste("raw-views-", format(date, "%Y-%m-%d"), '.txt',
                            sep='')
raw.output.fullpath = paste(RAW_LOCATION_BASE, '/', 
                            raw.output.filename, sep='')
write(wiki.response.body, raw.output.fullpath)

# Uploading the response to S3
BUCKET="ceu-shahana"
put_object(file = raw.output.fullpath,
           object = paste('datalake/raw/', 
                          raw.output.filename,
                          sep = ""),
           bucket = BUCKET,
           verbose = TRUE)



# Converting the response into a JSON lines formatted file
wiki.response.parsed = content(wiki.server.response, 'parsed')
top.views = wiki.response.parsed$items[[1]]$articles
current.time = Sys.time() 
json.lines = ""

for (article in top.views){
  record = list(
    article = article$article,
    views = article$views,
    rank = article$rank,
    date = format(date, "%Y-%m-%d"),
    retrieved_at = current.time
  )
  
  json.lines = paste(json.lines,
                     toJSON(record,
                            auto_unbox=TRUE),
                     "\n",
                     sep='')
}

JSON_LOCATION_BASE='data/views'
dir.create(file.path(JSON_LOCATION_BASE), showWarnings = TRUE)
json.lines.filename = paste("views-", format(date, "%Y-%m-%d"), '.json',
                            sep='')
json.lines.fullpath = paste(JSON_LOCATION_BASE, '/', 
                            json.lines.filename, sep='')
write(json.lines, file = json.lines.fullpath)

# Uploading the JSON lines file to S3 
put_object(file = json.lines.fullpath,
           object = paste('datalake/views/', 
                          json.lines.filename,
                          sep = ""),
           bucket = BUCKET,
           verbose = TRUE)

