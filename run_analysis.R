#create a folder
if(!file.exists("./data")){dir.create("./data")}

#downloand and unzip files
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data") #Unzipped files are in folder UCI HAR DATASET

path <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
files

#assign variables for datasets from files
ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

#High level overview of the variables
str(ActivityTest)
str(ActivityTrain)

###1 Merges the training and the test sets to create one data set.
#concatenate by rows
Subject <- rbind(SubjectTrain, SubjectTest)
Activity<- rbind(ActivityTrain, ActivityTest)
Features<- rbind(FeaturesTrain, FeaturesTest)

#set names to variables
names(Subject)<-c("subject")
names(Activity)<- c("Activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#Merge columns to get the data frame for all
dataCombine <- cbind(Subject, Activity)
Data <- cbind(dataFeatures, dataCombine)
Data

###2 Extracts only the measurements on the mean and standard deviation for each measurement.
#mean and std deviations
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
str(Data)

###3 Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
activityLabels

###4 Appropriately labels the data set with descriptive variable names.
#t is replaced by time
#Acc is replaced by Accelerometer
#Gyro is replaced by Gyroscope
#prefix f is replaced by frequency
#Mag is replaced by Magnitude
#BodyBody is replaced by Body

names(Data)<-gsub("^t", "Time", names(Data))
names(Data)<-gsub("^f", "Frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)

###5 From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
library(plyr);
Data2<-aggregate(. ~subject + Activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$Activity),]
write.table(Data2, file = "tidy.txt",row.names = FALSE)
