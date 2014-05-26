library(data.table) #Load data.table library for quicker data merges
library(corrgram) #Load corrgram library for dependency visualization
library(RWeka) #Load Weka package for machine learning algorithms
library(rpart)

setwd("~/Documents/R Working Directory/WalMart Kaggle Competition") #Set working directory 

train <- read.csv(file="train.csv") #Set training data as an object
test <- read.csv(file="test.csv") #Set testing data as an object
features <- read.csv(file="features.csv") #Set features data as an object
stores <- read.csv(file="stores.csv") #Set store data as an object

features$MarkDown1 [is.na(features$MarkDown1)] <- 0 #Turn NA markdown values into 0
features$MarkDown2 [is.na(features$MarkDown2)] <- 0 #Turn NA markdown values into 0
features$MarkDown3 [is.na(features$MarkDown3)] <- 0 #Turn NA markdown values into 0
features$MarkDown4 [is.na(features$MarkDown4)] <- 0 #Turn NA markdown values into 0
features$MarkDown5 [is.na(features$MarkDown5)] <- 0 #Turn NA markdown values into 0

train$id <- paste(train$Store,train$Date, sep="_") #Create id of store_dept_date i.e. 1_1_2-2-2000
features$id <- paste(features$Store,features$Date, sep="_") #Create id of store_dept_date i.e. 1_1_2-2-2000
test$id <- paste(test$Store,test$Date, sep="_") #Create id of store_dept_date i.e. 1_1_2-2-2000

train <- data.table(train, key=c("Store", "Date", "id")) #Create data.table with key variables for the below merge
test <- data.table(test, key=c("Store", "Date", "id")) #Create data.table with key variables for the below merge
features <- data.table(features, key=c("Store", "Date", "id")) #Create data.table with key variables for the below merge
stores <- data.table(stores, key=c("Store")) #Create data.table with key variables for the below merge

combtrain <- merge(train, features, by.x="id", by.y="id") #Combine data.tables with inner join to create 1 object for training
combtrain <- as.data.frame(merge(combtrain, stores, by.x="Store", by.y="Store")) #Combine data.tables with inner join to create 1 object for training
combtrain <- combtrain [-6] #Remove duplicate variables in data from merge
combtrain$id <- as.factor(combtrain$id) #Change the class of the id to be a factor

combtest <- merge(test, features, by.x="id", by.y="id") #Combine data.tables with inner join to create 1 object for training
combtest <- as.data.frame(merge(combtest, stores, by.x="Store.x", by.y="Store")) #Combine data.tables with inner join to create 1 object for training
colnames(combtest) [5] <- "Weekly_Sales" #Add weekly sales variable for prediction
combtest$Weekly_Sales <- 0 #Set weekly sales variable equal to 0
combtest$id <- as.factor(combtest$id) #Change the class of the id to be a factor
combtrain$Store <- as.factor(combtrain$Store) #Coerce value into a factor with discrete levels
combtrain$Dept <- as.factor(combtrain$Dept) #Coerce value into a factor with discrete levels
combtest$Store <- as.factor(combtest$Store) #Coerce value into a factor with discrete levels
combtest$Dept <- as.factor(combtest$Dept) #Coerce value into a factor with discrete levels

combtrain1 <- combtrain[sample(nrow(combtrain),size=300000,replace=FALSE),] #Sample the training data to save processing time
combtrain1 <- combtrain1 [c(5,1,4,6,7,8,9,10,11,12,13,14,15,16,17)] #Select columns to be included in the machine learning model
combtrain1$Store <- as.factor(combtrain1$Store) #Coerce value into a factor with discrete levels
combtrain1$Dept <- as.factor(combtrain1$Dept) #Coerce value into a factor with discrete leves

Bagging <- make_Weka_classifier("weka/classifiers/meta/Bagging") #Create Weka classifier of Bagging machine learning algorithm

ML1 <- Bagging(combtrain1$Weekly_Sales~., data=combtrain1, subset=combtrain1$IsHoliday.y) #Fit bagging model to sampled training data
ML2 <- Bagging(combtrain1$Weekly_Sales~., data=combtrain1) #Fit bagging model to sampled training data

combtrain$predictedsales1 <- predict(ML1, newdata=combtrain) #Make Bagging predictions on training set to see within model accuracy
combtest$predictedsales1 <- predict(ML1, newdata=combtest) #Make Bagging predictions on testing set to generate out of sample accuracy

combtrain$predictedsales2 <- predict(ML2, newdata=combtrain) #Make Bagging predictions on training set to see within model accuracy
combtest$predictedsales2 <- predict(ML2, newdata=combtest)

combtrain$predictedsales <- ((combtrain$predictedsales1 + combtrain$predictedsales2)/2)
combtest$predictedsales <- ((combtest$predictedsales1 + combtest$predictedsales2)/2)

combtrain$residual <- abs(combtrain$Weekly_Sales - combtrain$predictedsales) #Generate a value in training set that represents the error of the prediction
mean(combtrain$residual) #Calculate the mean of the residuals
plot(combtrain$residual) #Plot residuals to look for patterns

combtrain$weights <- ifelse(combtrain$IsHoliday.y == TRUE, 5, 1) #Weight the residuals according to competition evaluation rules
combtrain$weightedresidual <- combtrain$weights * combtrain$residual #Calculate weighted residual value for competition evaluation
WMSE <- (sum(combtrain$weightedresidual, na.rm=TRUE)) * (1/sum(combtrain$weights, na.rm=TRUE)) #Calculate weighted residual value for competition evaluation
WMSE #Print weighted mean square error

combtest$id <- paste(combtest$Store, combtest$Dept, combtest$Date, sep="_") #Create unique variable for each store, department, and date
submission <- combtest[c(3,18)] #Create data frame for Kaggle submission
colnames(submission) [1] <- "Id" #Rename submission variables
colnames(submission) [2] <- "Weekly_Sales" #Rename submission variables
write.csv(submission, file="submission.csv", row.names=FALSE) #Write submission file to working directory
