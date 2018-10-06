# Scraping Wikipedia's 2018 World Cup Data
# https://en.wikipedia.org/wiki/2018_FIFA_World_Cup_squads
# Tombayu Amadeo Hidayat
# August 2018

rm(list = ls())
setwd('M:/Coding/R/webscraping')

# Libraries
library(tidyverse)
library(rvest)
library(rlist)
library(stringi)
library(htmltab)

url <- "https://en.wikipedia.org/wiki/2018_FIFA_World_Cup_squads"

# Extract the list of countries
countries <- url %>%
  read_html %>%
  html_nodes("body #content #bodyContent #mw-content-text .mw-parser-output h3 .mw-headline") %>%
  html_text() %>%
  as.character()

# Extract the tables
countryTables <- url %>%
  read_html() %>%
  html_nodes("body #content #bodyContent #mw-content-text .mw-parser-output table") %>%
  html_table()
countryTables <- countryTables[1:32]

# Clean the tables
for (i in 1:length(countryTables)) {
  countryTables[[i]] <- cbind(countries[i], countryTables[[i]]) # add country column
  names(countryTables[[i]]) <- c("Country", "Number", "Position", "Name", "DoB", "Caps", "Goals", "Club") # change column names
  countryTables[[i]]$Position <- gsub("\\d", "", countryTables[[i]]$Position) %>%
    as.factor()# remove the number in Pos. column, convert as factor
  countryTables[[i]]$Name <- gsub("\\((.*?)\\)", "", countryTables[[i]]$Name)
  countryTables[[i]]$DoB <- gsub("\\((.*?)\\)", "", countryTables[[i]]$DoB) %>% 
    as.Date(format = "%d %B %Y") # remove brackets, change column format
  countryTables[[i]]$Club <- as.factor(countryTables[[i]]$Club) # factoring club column
}

# Combine into one dataframe
countryData <- countryTables[[1]]
for (i in 2:length(countryTables)) {
  countryData <- rbind(countryData, countryTables[[i]])
}

# Export into csv
write_csv(countryData, "worldcup2018.csv")
