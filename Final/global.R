library(shiny)
library(leaflet)
library(dplyr)
library(DT)
bike <- read.csv("./Data/bikeshare2017.csv",stringsAsFactors = F)
bike$arr_date <- as.Date(bike$arr_date)
bike$latitude <- as.numeric(bike$latitude)
bike$longitude <- as.numeric(bike$longitude)





