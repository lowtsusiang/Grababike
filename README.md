---
title: "#Developing Shiny App: Grab a Bike"
author: "Fig & Co| i. Noraisha Yusuf (WQD180008)| ii.Low Tsu Siang (WQD180072)| iii.Kaveenaasvini (WQD180017)| Iv. Prabavathi (WQD180030)"
date: "December 13, 2018"
output:
  html_document: default
  word_document: default
---

####A group assignment for WQD7001: Principle Data Science, University Malaya


> **Introduction**

Bike sharing culture is on the rise particularly in urban cities. Many urbanites have adopted this mode of transport. It provides an alternative means of travelling that is cheaper, healthier and environmentally friendly. 

The City of Chicago launched Divvy, a new bike share system designed to connect people to transit, and to make short one-way trips across town easy. The Divvy bikes are gaining more popularity since its establishment in 2013.


> **Question**

The Divvy bikes has an impressive amount of 592 bike stations in Chicago city. We were particularly interested with the number of trips at these locations in 2017. When and where do bikers normally ride their rented Divvy bikes? 

We believed that these information would be useful to bikers, nearby and new businesses and the bike rental company itself. In view that these interested parties would be driven by different motives, it is essential that the shiny app allows the users to explore the bike trips in accordance with their preferences. 
It is challenging to visualize the distribution of bike trips across the 592 Divvy bike stations. Hence, we opted to develop the Shiny App to produce a spatial/map visualization of the bike trips.


> **Goal**

In order to answer our questions, we have to map out and categorize the popularity of the bike stations based on:
<ul>
  <li>specific date</li>
  <li>time frame</li>
  <li>gender</li>
</ul>

 
*Note:* On this page, the focus is on describing our data preparation and exploratory data analysis. For the Shiny App codes, the ui.r and server.r files are available in the same github account.


> **Data Preparation**

We obtained the dataset from https://www.kaggle.com/yingwurenjian/chicago-divvy-bicycle-sharing-data. The same dataset can also be obtained directly from Divvy Bike Share's website. 

1. Load the data. In view that our focus is only for 2017, we subset the data by filtering the year column to 2017 only. 
```{r}
bike <- read.csv("data.csv")
dataset <- subset(bike,bike$year == 2017)
```


```{r include=FALSE}
library(dplyr)
library(tidyr)
library(tidyverse)
```

2. A brief overview of the dataset. 
```{r}
glimpse(dataset)
```

3. There are no missing values found in the dataset. 
```{r}
colSums(is.na(dataset))
```

4. Aligning with our objective, we filtered the dataset further based on these variables
  + stoptime: _the time when the bike trips end_
  + to_station_name: _the name of the bike destination station_
  + latitude_end: _part of the coordinates of the bike destination station_
  + longitude_end: _part of the coordinates of the bike destination station_
  + gender: _male or female bikers_

```{r}
dataset <- dataset[c(10,20,21,22,8)]
```

5. We separated the date and time from the variable stoptime into two columns respectively. 
```{r}
dataset <- separate(dataset, stoptime, into=c("arr_date","time"),sep=" ")
head(dataset)
```


6. For the purpose of our analysis, we extracted the arrival hour information from time variable
```{r}


dataset <- separate(dataset, time, into=c("arr_hour","min","sec"),sep=":")
dataset <- dataset[-c(3,4)]

```

7. Renamed columns
```{r}
colnames(dataset)[c(4,5)] <- c("latitude","longitude")
```


8. Created a new column that computes the total number of trips given a date, gender and destination station
```{r}

dataset$arr_date <- as.Date(dataset$arr_date)
dataset$arr_hour <- as.numeric(dataset$arr_hour)

dataset <- dataset %>%
  group_by(arr_date,arr_hour,to_station_name,latitude,longitude,gender) %>%
  summarise(total_trips = n())%>%
  glimpse()
```


> **Exploratory Data Analysis**

1. We explored the statistical information of our processed dataset. 

  + The range of arrival date is from 1st January 2017 up till 1st January 2018. 
  + The median of arrival hour is around 3pm, implying about 50% of the bike trips occurs at 3 pm. 
  + Gender wise, Male bikers are significantly higher than female bikers by around 34%
  + Lastly, the total number of trips given a specific date, hour and gender range from 1 to a maximum of 98 bike trips. The average number of trips is 1.924. Most of the bike trips i.e. 75% reached up to 2 trips only. 
```{r}
summary(dataset)
```


2. Visualizing distribution of total number of bike trips by gender factor in 2017. 

We can observe that the peak number of trips is similar for both genders, form mid-June to October 2017. The bike trips for male can reached more than 10,000 bike trips in a day during peak season. 

```{r}
library(ggplot2)

dately <- dataset %>%
  group_by(arr_date,gender) %>%
  summarise(total = sum(total_trips))


ggplot(dately, aes(x=arr_date,y=total))+ 
  geom_jitter(aes(color = gender))+
  theme_light()

```



3. Visualizing bike trips according to bike stations

This is a basic view using tree map approach. From the diagram, we can see the more popular destination bike stations are Canal St & Adams St, ClintonSt & Madison St, Clinton St & Washington Blvd, Kingsbury st & Kinzie St, Canal St & Madison St, Daisy Center Plaza, Micigan Ave & Washington St. and Franklin St & Monroe St. 

```{r}

station <- dataset %>%
  group_by(to_station_name) %>%
  summarise(total = sum(total_trips))

sample_n(station, 10)
library(treemap)

treemap(station,index = "to_station_name",vSize = "total")
```


4. Visualizing the peak number of bike trips by date

Majority of the high number of bike trips occurred between mid June up till October 2017. Hence, Summer to Autumn are the most preferred season to bike in Chicago. 

```{r}

dateterm <- dataset %>%
  group_by(arr_date) %>%
  summarise(total = sum(total_trips))

ggplot(dateterm, aes(x=arr_date,y=total,fill=total))+
  geom_bar(stat = "identity") +
  scale_fill_gradient(low="gray", high="blue") +
  theme_light()+
  coord_polar()+
  labs(title="Polar Area Diagram", subtitle="Daily total number of trips", x="Date", y="Total trips")
```


5. Visualizing the number of trips around the 24 hours duration

Majority preferred to bike around 7-8 am and 4-6 pm. The highest number of bike trips happened around 8 am and 5 pm. Although minimal, there are some bike trips nearing midnight time. This would be useful information to bike share company to ensure that their bikes are safe for use during late night time. 

```{r}

hourly <- dataset%>%
  group_by(arr_hour)%>%
  summarise(total = sum(total_trips))


ggplot(hourly, aes(x=arr_hour,y=total,fill=total))+
  geom_bar(stat="identity") +
  theme_light()+
  coord_polar()+
  scale_fill_gradient(low="gray", high="blue") +
  labs(title="Polar Area Diagram", subtitle="Hourly number of trips", x="Hour", y="Total trips")
  



```



A quick look at the Grab a Bike app

![capture](https://github.com/lowtsusiang/testing/blob/master/Image/main.gif?raw=true)



*Note:* Please refer to the ui.r and server.r files which are available in the same github account, for the Shiny App construction. 
