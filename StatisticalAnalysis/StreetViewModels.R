

############ StreetViewModels.R ############
# Author: Andrew Larkin
# Developed for Perry Hystad, Oregon State University
# Date created: November 30th, 2018
# This script performs lasso varaible selection and incremental varaible buffer reduction for streetscape land use
# regression variables.  Models based on remote sensing estimates, street view image-based estimates, and a combination
# of the two are derived for perception scores of safety, lively, and beauty.  


####### load required packages #########
library(glmnet) # lasso regression


################ helper functions ################


# calculate average RMSE of model predictions for each city in the dataset
calcCityRMSE <- function(inData,outcome) {
  
  
  cityNames <- unique(inData$CITY_NAME)
  
  rmse <- rep(0,length(cityNames)+1)
  medianPred <- rep(0,length(cityNames)+1)
  iqrPred <- rep(0,length(cityNames)+1)
  n <- rep(0,length(cityNames)+1)
  
  # stratify by city and store names 
  stratName <-rep("a",length(cityNames)+1)
  
  # calculate statistics for the entire dataset (i.e. all cities)
  medianActual <- rep(0,length(cityNames)+1)
  iqrActual <- rep(0,length(cityNames)+1)
  rmse[1] <-  sqrt(sum(inData$residuals^2)/length(inData$residuals))
  medianPred[1] <- median(inData$predictions)
  iqrPred[1] <- IQR(inData$predictions)
  stratName[1] <- "all"
  
  if(outcome == 'beautiful') {
    medianActual[1] <- median(inData$mu_beautiful)
    iqrActual[1] <- IQR(inData$mu_beautiful)
  }
  else if(outcome == 'safety') {
    medianActual[1] <- median(inData$mu_safety)
    iqrActual[1] <- IQR(inData$mu_safety)
  }
  
  else {
    medianActual[1] <- median(inData$mu_lively)
    iqrActual[1] <- IQR(inData$mu_lively)
  }
  
  # calculate statistics for each city 
  for(i in 1:length(cityNames)) {
    citySubset <- subset(inData,inData$CITY_NAME == cityNames[i])
    cat(length(citySubset$residuals))
    if(length(citySubset$residuals) >0) {
      rmse[i+1] <- sqrt(sum(citySubset$residuals^2)/length(citySubset$residuals))
      medianPred[i+1] <- median(citySubset$predictions)
      iqrPred[i+1] <- IQR(citySubset$predictions)
      if(outcome == 'beautiful') {
        medianActual[i+1] <- median(citySubset$mu_beautiful)
        iqrActual[i+1] <- IQR(citySubset$mu_beautiful)
      }
      else if(outcome == 'safety') {
        medianActual[i+1] <- median(citySubset$mu_safety)
        iqrActual[i+1] <- IQR(citySubset$mu_safety)
      }
      
      else {
        medianActual[i+1] <- median(citySubset$mu_lively)
        iqrActual[i+1] <- IQR(citySubset$mu_lively)
        
      }
      n[i+1] <- length(citySubset[,1])
      stratName[i+1] <- as.character(cityNames[i])
    }
  }
  
  # calculate ranks and difference in ranks for each city
  medianDiff <- medianPred - medianActual
  predRank <- rank(medianPred)
  actualRank <- rank(medianActual)
  rankDiff <- predRank - actualRank
  dataSet <- data.frame(rmse,medianPred,iqrPred,medianActual,iqrActual,medianDiff,predRank,actualRank, rankDiff,n,stratName)
  dataSet <- dataSet[order(dataSet$rankDiff),]
  return(dataSet)
  
} # end of calcCityRMSE




# calculate percent variance explained for each city
calcCityRSquared <- function(inData,outcome) {
  
  # initialize result arrays
  cityNames <- unique(inData$CITY_NAME)
  SSR <- rep(0,length(cityNames)+1)
  SSTOTAL <- rep(0,length(cityNames)+1)
  PartialR <- rep(0,length(cityNames)+1)
  stratName <-rep("a",length(cityNames)+1)
  
  # calculate SSR and SSTOTAL for the entire dataset
  stratName[1] <- "all"
  if(outcome == 'beautiful') {
    meanActual <- mean(inData$mu_beautiful)
    SSTOTAL[1] <- sum((inData$mu_beautiful - meanActual)^2)
  }
  else if(outcome == 'safety') {
    meanActual <- mean(inData$mu_safety)
    SSTOTAL[1] <- sum((inData$mu_safety - meanActual)^2)
  }
  else {
    meanActual <- mean(inData$mu_lively)
    SSTOTAL[1] <- sum((inData$mu_lively - meanActual)^2)
  }

  SSR[1] <- sum(inData$residuals^2)
  
  # calculate SSR and SSTOTAL for each city
  for(i in 1:length(cityNames)) {
    citySubset <- subset(inData,inData$CITY_NAME == cityNames[i])
    if(outcome == 'beautiful') {
      meanActual <- mean(citySubset$mu_beautiful)
      SSTOTAL[i+1] <- sum((citySubset$mu_beautiful - meanActual)^2)
    }
    else if(outcome == 'safety') {
      meanActual <- mean(citySubset$mu_safety)
      SSTOTAL[i+1] <- sum((citySubset$mu_safety - meanActual)^2)
    }
    else {
      meanActual <- mean(citySubset$mu_lively)
      SSTOTAL[i+1] <- sum((citySubset$mu_lively - meanActual)^2)
    }

    SSR[i+1] <- sum(citySubset$residuals^2)
    stratName[i+1] <- as.character(cityNames[i])
  }
 
  # calculate partial R2 for all strat levels 
  PartialR <- 1 - (SSR/SSTOTAL)
  
  returnData <- data.frame(SSR,SSTOTAL,PartialR,stratName)
  return(returnData)

} # end of calcCityRSquared
  

######################## setup #####################

setwd("C:/users/larkinan/desktop/PlacePulse")

rawData <- read.csv("PlacePulseMeasuresConstructs_Nov29_18.csv")

imagePredictors <- c('accessibility','allNature','animate','bluespace','building','builtEnv','car','grass','greenspace',
               'otherNature','person','plant','road','sidewalk','sky','tree','bench')


remotePredictors <- c('PM251000m','mjRds100m','mjRds250m','NO2100m','NO2250m','tr100m','tr250m','imp1000m','pop1000m',
                       'NDVI250m')


# image and remote sensing variables
allPredictors <- c('accessibility','allNature','animate','bluespace','building','builtEnv','car','grass','greenspace',
                   'otherNature','person','plant','road','sidewalk','sky','tree','bench',
                   'PM251000m','mjRds100m','mjRds250m','NO2100m','NO2250m','tr100m','tr250m','imp1000m','pop1000m',
                   'NDVI250m')



############## Beauty Analysis #############

# remove records without beauty comparisons
beauSubset <- subset(rawData,!is.na(rawData$mu_beautiful))
#restrict data to top quartile of comparisons
beauSubset <- subset(beauSubset,beauSubset$count_beautiful >=4)
beauOutcome <- beauSubset$mu_beautiful


beauAllPredictors <- as.matrix(beauSubset[allPredictors])
beauImagePredictors <- as.matrix(beauSubset[imagePredictors])
beauRemotePredictors <- as.matrix(beauSubset[remotePredictors])



cvfit <- glmnet::cv.glmnet(beauAllPredictors,beauOutcome,type.measure = "mse",standardize=TRUE,alpha = 1) # perform lasso regression
coefRaw <- coef(cvfit, s = "lambda.1se")


nameVals <- rownames(coefRaw)
keeps <- c("")

# skip intercept, store names of other variables selected by lasso regression
for( i in 2:length(coefRaw)) {
  if(coefRaw[i]^2 > 0) {
    keeps <- c(keeps,nameVals[i])
  }
}

# remove black space initializer
keeps <- keeps[2:length(keeps)]
beautyModelAll <- beauSubsetPred[keeps]

# remove non-significant variables
drops <- c("bench","tr250m")
beautyModelAll <- beautyModelAll[ , !(names(beautyModelAll) %in% drops)]


beautyModelForm <- lm(beauOutcome ~ as.matrix(beautyModelAll))
summary(beautyModelForm)
beautyModelForm <- lm(beauOutcome ~ as.matrix(as.matrix(beauAllPredictors)))

# calculate model predictions and residuals
predictions <- predict(beautyModelForm,beauSubset)
beauSubset$predictions <- predictions
beauSubset$residuals <- beauSubset$predictions - beauSubset$mu_beautiful 

# calculate RMSE and partial R2 for each city based on the beauty construct
beautyStats <- calcCityRMSE(beauSubset,"beautiful")
beautyR2 <- calcCityRSquared(beauSubset,"beautiful")

write.csv(beautyStats,"beautyStats.csv")
write.csv(beautyR2,"beautyR2.csv")

########## Safety Analysis ###########

# remove records without safety comparisons
safeSubset <- subset(rawData, !is.na(rawData$mu_safety))
# restrict data to top quartile of comaprisons
safeSubset <- subset(safeSubset,safeSubset$count_safety >=9)
safeOutcome <- safeSubset$mu_safety


safePred <- safeSubset[allPredictors]
safeAllPredictors <- as.matrix(safePred[allPredictors])
safeImagePredictors <- as.matrix(safePred[imagePredictors])
safeRemotePredictors <- as.matrix(safePred[remotePredictors])


###### safety - all predictors ########

# lasso variable selection
cvfit <- glmnet::cv.glmnet(safeAllPredictors,safeOutcome,type.measure = "mse",standardize=TRUE,alpha = 1) # perform lasso regression
coefRaw <- coef(cvfit, s = "lambda.1se")

# get names of selected variables
nameVals <- rownames(coefRaw)
keeps <- c("")
for( i in 2:length(coefRaw)) {
  if(coefRaw[i]^2 > 0) {
    keeps <- c(keeps,nameVals[i])
  }
  
}
keeps <- keeps[2:length(keeps)]
safeModelAll <- safePred[keeps]

# remove non-significant variables
drops <- c("tr250m","bench")
safeModelAll <- safeModelAll[ , !(names(safeModelAll) %in% drops)]
safeModelForm <- lm(safeOutcome ~ as.matrix(safeModelAll))
summary(safeModelForm)

# get model predictions and residuals
predictions <- predict(safeModelForm,safeSubset)
safeSubset$predictions <- predictions
safeSubset$residuals <- safeSubset$predictions - safeSubset$mu_safety 

# calculate city-specific RMSE and partial R2
safetyStats <- calcCityRMSE(safeSubset,"safety")
safetyR2 <- calcCityRSquared(safeSubset,"safety")

write.csv(safetyStats,"safetyStats.csv")
write.csv(safetyR2,"safetyR2.csv")


###### safety - image-only predictors ########

cvfit <- glmnet::cv.glmnet(safeImagePredictors,safeOutcome,type.measure = "mse",standardize=TRUE,alpha = 1) # perform lasso regression
coefRaw <- coef(cvfit, s = "lambda.1se")

nameVals <- rownames(coefRaw)
keeps <- c("")
for( i in 2:length(coefRaw)) {
  if(coefRaw[i]^2 > 0) {
    keeps <- c(keeps,nameVals[i])
  }
  
}
keeps <- keeps[2:length(keeps)]
safeModelAll <- safePred[keeps]
drops <- c("otherNature","bench")
safeModelAll <- safeModelAll[ , !(names(safeModelAll) %in% drops)]
safeModelForm <- lm(safeOutcome ~ as.matrix(safeModelAll))
summary(safeModelForm)



###### safety - remote-only predictors ########

cvfit <- glmnet::cv.glmnet(safeRemotePredictors,safeOutcome,type.measure = "mse",standardize=TRUE,alpha = 1) # perform lasso regression
coefRaw <- coef(cvfit, s = "lambda.1se")

nameVals <- rownames(coefRaw)
keeps <- c("")
for( i in 2:length(coefRaw)) {
  if(coefRaw[i]^2 > 0) {
    keeps <- c(keeps,nameVals[i])
  }
  
}
keeps <- keeps[2:length(keeps)]
safeModelAll <- safePred[keeps]
drops <- c("otherNature","bench")
safeModelAll <- safeModelAll[ , !(names(safeModelAll) %in% drops)]
safeModelForm <- lm(safeOutcome ~ as.matrix(safeModelAll))
summary(safeModelForm)


#################### Lively Analysis ################

# remove records with no lively comparisons
livelySubset <- subset(rawData, !is.na(rawData$mu_lively))
# restrict records to top quartile of number of comparisons
livelySubset <- subset(livelySubset,livelySubset$count_lively >=6)
livelyOutcome <- livelySubset$mu_lively 

livelyPred <- livelySubset[allPredictors]
livelyAllPredictors <- as.matrix(livelyPred[allPredictors])
livelyImagePredictors <- as.matrix(livelyPred[imagePredictors])
livelyRemotePredictors <- as.matrix(livelyPred[remotePredictors])


######### lively - all predictors ############

# lasso variable selection
cvfit <- glmnet::cv.glmnet(livelyAllPredictors,livelyOutcome,type.measure = "mse",standardize=TRUE,alpha = 1) # perform lasso regression
coefRaw <- coef(cvfit, s = "lambda.1se")

nameVals <- rownames(coefRaw)
keeps <- c("")
for( i in 2:length(coefRaw)) {
  if(coefRaw[i]^2 > 0) {
    keeps <- c(keeps,nameVals[i])
  }
}
keeps <- keeps[2:length(keeps)]
livelyModelAll <- livelyPred[keeps]
# drop non-significant variables
drops <- c("car","bench")
livelyModelAll <- livelyModelAll[ , !(names(livelyModelAll) %in% drops)]
livelyModelForm <- lm(livelyOutcome ~ as.matrix(livelyModelAll))
summary(livelyModelForm)


# calculate model predictions and residuals
predictions <- predict(livelyModelForm,livelySubset)
livelySubset$predictions <- predictions
livelySubset$residuals <- livelySubset$predictions - livelySubset$mu_lively 

# calculate city-specific RMSE and partial R2
livelyStats <- calcCityRMSE(livelySubset,"lively")
livelyR2 <- calcCityRSquared(livelySubset,"lively")

write.csv(safetyStats,"livelyStats.csv")
write.csv(safetyR2,"livelyR2.csv")


######## lively - image-based predictors ############

cvfit <- glmnet::cv.glmnet(livelyImagePredictors,livelyOutcome,type.measure = "mse",standardize=TRUE,alpha = 1) # perform lasso regression
coefRaw <- coef(cvfit, s = "lambda.1se")

nameVals <- rownames(coefRaw)
keeps <- c("")
for( i in 2:length(coefRaw)) {
  if(coefRaw[i]^2 > 0) {
    keeps <- c(keeps,nameVals[i])
  }
  
}
keeps <- keeps[2:length(keeps)]
livelyModelAll <- livelyPred[keeps]
drops <- c("bench")
livelyModelAll <- livelyModelAll[ , !(names(livelyModelAll) %in% drops)]
livelyModelForm <- lm(livelyOutcome ~ as.matrix(livelyModelAll))
summary(livelyModelForm)




######## lively - remote-based predictors ############

cvfit <- glmnet::cv.glmnet(livelyRemotePredictors,livelyOutcome,type.measure = "mse",standardize=TRUE,alpha = 1) # perform lasso regression
coefRaw <- coef(cvfit, s = "lambda.1se")

nameVals <- rownames(coefRaw)
keeps <- c("")
for( i in 2:length(coefRaw)) {
  if(coefRaw[i]^2 > 0) {
    keeps <- c(keeps,nameVals[i])
  }
  
}
keeps <- keeps[2:length(keeps)]
livelyModelAll <- livelyPred[keeps]
drops <- c("bench")
livelyModelAll <- livelyModelAll[ , !(names(livelyModelAll) %in% drops)]
livelyModelForm <- lm(livelyOutcome ~ as.matrix(livelyModelAll))
summary(livelyModelForm)


# end of StreetViewModels.R #

