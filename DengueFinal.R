
library(forecast)
library(vars)
# read in dataset
df = read.csv('/Users/kseowoo/Library/CloudStorage/OneDrive-UniversityofNorthCarolinaatChapelHill/statistical asseessment/assessment.csv')

# view the dataset
str(df)
head(df)
tail(df)

# copy the dataset
df1 = df

# create new variables: time and incidence rate
df1$time = df1$year*100+df1$epiweek
df1$incidenceRate = df1$dengue_cases/df1$pop

# remove year, dengue cases, population
df1 = df1[,-c(1,3:4)]

# view head of the datset
head(df1)

# split the dataset by district
split_df = split(df1, df1$ubigeo)


# create a function for var model
var.model <- function(dat, t.time) {
  # split train and test
  train <- dat %>% dplyr::filter(time <= t.time)
  test = dat %>% dplyr::filter(time>=202332)
  
  # load time series for each column
  incd <- ts(train$incidenceRate, start = c(2001,1), frequency = 365.25/7)
  rain <- ts(train$Rainfall.mm., start = c(2001,1), frequency = 365.25/7)
  air <- ts(train$AirTemperature.C., start = c(2001,1), frequency = 365.25/7)
  hum <- ts(train$SpecificHumidity.g.kg., start = c(2001,1), frequency=365.25/7)
  pres <- ts(train$SurfacePressure.Pa., start = c(2001,1), frequency = 365.25/7)
  stemp <- ts(train$SoilTemperature.C., start = c(2001,1), frequency = 365.25/7)
  smois <- ts(train$SoilMoisture.m3.m3., start = c(2001,1), frequency = 365.25/7)
  srun <- ts(train$SurfaceRunoff.mm., start = c(2001,1), frequency = 365.25/7)
  
  # decompose incidence and adjust for seasonality
  decomp <- decompose(incd)
  incdns <- incd - decomp$seasonal
  
  # combine all time series
  ts <- cbind(incdns, rain, air, hum, pres, stemp, smois, srun)
  
  # run var selection
  vars <- VARselect(ts, lag.max = 10, type = "both")
  p.num <- vars[["selection"]][["AIC(n)"]]
  
  # fit var
  var <- vars::VAR(ts, p=p.num, type = "const")
  summary(var)
  
  # forecasting
  var.forecast <- predict(var, n.ahead = 16, ci = 0.95)
  
  # extract 32-36th forecasting
  forecast <- var.forecast[["fcst"]][["incdns"]][-1:-11,]
  
  # calculate number of new cases
  cases <- forecast*tail(test$pop,1)
  
  return(list(summary = summary(var), irr = forecast, cases = cases))
}

# run var model for each district
for (i in 1:52) {
  result <- var.model(split_df[[i]], 202316)
  assign(paste0("result", i), result)
}

# combine the results
combine <- lapply(mget(paste0("result", 1:52)), function(x) cbind(x[[3]][,1]))
combine <- as.data.frame(combine)


# mapping
zim_shp <- maptools::readShapePoly("/Users/kseowoo/Library/CloudStorage/OneDrive-UniversityofNorthCarolinaatChapelHill/statistical asseessment/CDC_Distritos_Loreto.shp", IDvar = "distrito")
plot(zim_shp, border = "red", axes = TRUE, las = 1)

# matching the district name
district_name = zim_shp$distrito
combine$result53 = 0 # as all dengue_cases are zeros in distinct53
colnames(combine) = district_name

#divide by the week
week32_df <- data.frame(count = t(combine[1, ]),distrito = district_name);colnames(week32_df) = c('count32','distrito')
week33_df <- data.frame(week33 = t(combine[2, ]),distrito = district_name);colnames(week33_df) = c('count33','distrito')
week34_df <- data.frame(week34 = t(combine[3, ]),distrito = district_name);colnames(week34_df) = c('count34','distrito')
week35_df <- data.frame(week35 = t(combine[4, ]),distrito = district_name);colnames(week35_df) = c('count35','distrito')
week36_df <- data.frame(week36 = t(combine[5, ]),distrito = district_name);colnames(week36_df) = c('count36','distrito')


# color the map
library(sf)
zim_sf <- st_as_sf(zim_shp)
zim_sf <- merge(zim_sf, week32_df, by = 'distrito')
zim_sf <- merge(zim_sf, week33_df, by = 'distrito')
zim_sf <- merge(zim_sf, week34_df, by = 'distrito')
zim_sf <- merge(zim_sf, week35_df, by = 'distrito')
zim_sf <- merge(zim_sf, week36_df, by = 'distrito')

str(zim_sf)

df_sorted <- zim_sf[order(-zim_sf$count32), ]
# count by distinct: INAHUAYA > ALTO NANAY > CAPELO > FERNANDO LORES > ...

# dengue count map for 32 week in 2023
par(mfrow=c(2,3))

library(ggplot2)
ggplot(data = zim_sf) +
  geom_sf(aes(fill = zim_sf$count32), color = "black", size = 0.25) +
  scale_fill_gradient(low = "yellow", high = "red", name = "Dengue Count",limit=c(-0.1,41)) +
  labs(title = "32 week in 2023") +
  theme_minimal()

# dengue count map for 33 week in 2023
library(ggplot2)
ggplot(data = zim_sf) +
  geom_sf(aes(fill = zim_sf$count33), color = "black", size = 0.25) +
  scale_fill_gradient(low = "yellow", high = "red", name = "Dengue Count",limit=c(-0.1,41)) +
  labs(title = "33 week in 2023") +
  theme_minimal()

# dengue count map for 34 week in 2023
library(ggplot2)
ggplot(data = zim_sf) +
  geom_sf(aes(fill = zim_sf$count34), color = "black", size = 0.25) +
  scale_fill_gradient(low = "yellow", high = "red", name = "Dengue Count",limit=c(-0.1,41)) +
  labs(title = "34 week in 2023") +
  theme_minimal()

# dengue count map for 35 week in 2023
library(ggplot2)
ggplot(data = zim_sf) +
  geom_sf(aes(fill = zim_sf$count35), color = "black", size = 0.25) +
  scale_fill_gradient(low = "yellow", high = "red", name = "Dengue Count",limit=c(-0.1,41)) +
  labs(title = "35 week in 2023") +
  theme_minimal()

# dengue count map for 36 week in 2023
library(ggplot2)
ggplot(data = zim_sf) +
  geom_sf(aes(fill = zim_sf$count36), color = "black", size = 0.25) +
  scale_fill_gradient(low = "yellow", high = "red", name = "Dengue Count",limit=c(-0.1,41)) +
  labs(title = "36 week in 2023") +
  theme_minimal()



# Evaluation by RMSPE

# actual number of cases
split_df.cases = split(df, df$ubigeo)
actual <- list()
for (i in 1:53) {
  actual[[i]] <- sum(tail(split_df.cases[[i]]$dengue_cases, 5))
}

# predicted number of cases
predicted <- list()
for (i in 1:52) {
  predicted[[i]] <- sum(var.model(split_df[[i]], 202316)[[3]][,1])
}

# add 0 for 53rd district
predicted[[53]] <- 0

rmspe <- list()
for (i in 1:53) {
  rmspe[[i]] <- sqrt(mean(((predicted[[i]]-actual[[i]])/actual[[i]])^2))
  if(rmspe[[i]]=="Inf") {rmspe[[i]]=NA}
}
rmspe
# rmspe for 23rd district is very high


# visualize time series for 23rd district
dat.23 <- split_df[[23]]
incd <- ts(dat.23$incidenceRate, start = c(2001,1), frequency = 365.25/7)
plot.ts(incd)

# high spike between 2020 and 2023, so edit time boundary for train
predicted[[23]] <- sum(var.model(dat.23, 201916)[[3]][1,])

# calculate rmspe
rmspe <- list()
for (i in 1:53) {
  rmspe[[i]] <- sqrt(mean(((predicted[[i]]-actual[[i]])/actual[[i]])^2))
  if(rmspe[[i]] == "Inf") {rmspe[[i]]=NaN}
}

rmspem <- as.matrix(rmspe)
rmspem <- rmspe[!is.na(rmspem)] #remove NaN
mean(as.numeric(rmspem)) # calculate the mean rmspe across districts whose rmspe is not zero.

#other evaluation metrics
accuracy <- list()
for (i in 1:53) {
  accuracy[[i]] <- accuracy(predicted[[i]], actual[[i]])
}
accuracy


######## Table #########
library(knitr)
library(kableExtra)
library(dplyr)

# sort rmspe
sort(as.numeric(rmspe), decreasing = TRUE)
# highest: 44th, 21st; lowest: 15th, 1st

# create data frame
table <- data.frame(
  district = c("Teniente Manuel Clavero", "Mazan", "Jeberos", "Alto Nanay"),
  rmspe = c(9.59, 3.57, 0.15, 0.02)
)

# create a table
kable <- kable(table, "html", aligh = "c", col.names = c("District Name", "RMSPE")) %>% kable_styling(bootstrap_options = c("striped", "condensed"), full_width = F, font_size = 15)

kable


