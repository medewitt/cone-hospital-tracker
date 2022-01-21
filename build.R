library(dplyr)
library(data.table)
hh <- here::here
library(rvest)

# pull hospitalizations ---------------------------------------------------

hospitalizations <- read_html("https://coviddata.conehealth.com/cone.html")

all_src<- hospitalizations %>% 
	html_nodes("script") %>% 
	.[[55]] %>% 
	html_text()

tmp <- tempfile(fileext = ".json")

writeLines(all_src, tmp)

 hospitalization_data <- jsonlite::fromJSON(tmp)

raw_dat <- hospitalization_data[["x"]][["hc_opts"]][["series"]][["data"]][[1]]

raw_dat <- head(within(raw_dat, date <- as.Date(date)),-1)

raw_dat <- raw_dat[,c("cases", "date")]

fwrite(raw_dat, sprintf("data-raw/%s-reported-cases.csv", Sys.Date()))
