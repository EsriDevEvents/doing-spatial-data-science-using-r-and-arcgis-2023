library(arcgisbinding)
arc.check_product()

#### Some Basic Vars ####
f <- 1.0
i = 10
s = "My String"

#### Some Basic Containers ####
C = rep(i, 10)
m = matrix(0, 10, 10)
diag(m) = i

#### Basic Function with Loop and One Return ####
basic = function(values, value2Count){
  counter = 0
  for (i in 1:length(values)){
    if (values[i] == value2Count){
      counter = counter + 1
    }
  }
  counter
}

r = floor(runif(20, 0, 5))
bc = basic(r, 1)

#### Boolean Vector Way ####
where1 = r == 1
bc2 = sum(where1)

#### Functions with Multiple Returns ####
multi = function(values, value2Count){
  counter = 0
  ind = c()
  for (i in 1:length(values)){
    if (values[i] == value2Count){
      counter = counter + 1
      ind = c(ind, i) 
    }
  }
  res = list(counter=counter, ind=ind)
}

mc = multi(r, 1)
mc$counter
mc$ind

#### Back to Boolean Using Which ####
which(r == 1)

#### Getting Libraries (Forecast, MLmetrics) ####
library(forecast)
library(MLmetrics)
data = AirPassengers

#### Training and Validation Splits ####
training=window(data, start = c(1949,1), end = c(1955,12))
validation=window(data, start = c(1956,1))

#### Naive Forecast and Plot ####
naive = snaive(training, h=length(validation))
MAPE(naive$mean, validation) * 100

plot(data, col="blue", xlab="Year", ylab="Passengers", 
     main="Seasonal Naive Forecast", type='l')
lines(naive$mean, col="red", lwd=2)