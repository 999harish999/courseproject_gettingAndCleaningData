#course project : Getting and cleaning data 

# 1. downlad the ZIP data and extract the content
library(dplyr)
library(reshape2)

fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

dataDir<-"./data01"
zipdatadir<-paste(dataDir,"/","rawdata.zip",sep = "")
rawdataDir<-paste0(dataDir,"/UCI HAR Dataset")


if(!dir.exists(dataDir)){
  dir.create(dataDir)
  download.file(fileUrl,destfile = zipdatadir)
  unzip(zipfile = zipdatadir,exdir = dataDir)
}
#_______________________________________________________________________________
# 2. merge Training and test Dataset

## 2.1 Read Training data

trainingDataset<-read.table(paste0(rawdataDir,"/train/X_train.txt"))         #read the training data
trainingActivityLabels<-read.table(paste0(rawdataDir,"/train/y_train.txt"))     #read the labels(walking,sitting etc) for training data
trainingSubjects<-read.table(paste0(rawdataDir,"/train/subject_train.txt"))     #read the subjects(peopple 1:30) who performed the activity

## 2.2 Read Test data

testDataset<-read.table(paste0(rawdataDir,"/test/X_test.txt"))            #read the test data
testActivityLabels<-read.table(paste0(rawdataDir,"/test/y_test.txt"))    #read the labels(walking,sitting etc) for test data
testSubjects<-read.table(paste0(rawdataDir,"/test/subject_test.txt"))     #read the subjects(peopple 1:30) who performed the activity

## 2.3 merge each data sets

mergedDataset<-rbind(trainingDataset,testDataset)
mergedActivityLabels<-rbind(trainingActivityLabels,testActivityLabels)
mergedSubjects<-rbind(trainingSubjects,testSubjects)

## 2.4 combine mergedDataset, mergedActivityLabels and mergedSubjects to from single table

allData<-cbind(mergedActivityLabels,mergedSubjects,mergedDataset)

#______________________________________________________________________________

# 3 Extracts only the measurements on the mean and standard deviation for each measurement.

##3.1 Label the the features in allData 

featureNames<-read.table(paste0(rawdataDir,"/features.txt"))
allvarialNames<-append(c("activity","subjects"),featureNames[,2])
names(allData)<-allvarialNames

##3.2 find the indeces of feature mean and sd in allVariableNames

mean_std_ineces<-grep("mean|std",allvarialNames)

##3.3 extract only measurement on the mean and standard deviation

allData<-allData[,c(1,2,mean_std_ineces)]

#_______________________________________________________________________________

# 4 Uses descriptive activity names to name the activities in the data set

## 4.1 Read activity names 

activityNames<-read.table(paste0(rawdataDir,"/activity_labels.txt"))


## 4.2 Assign the activity names in allData

allData$activity<-as.factor(allData$activity)
levels(allData$activity)<-activityNames[,2]

#_______________________________________________________________________________

# 5 From the data set in step 4, creates a second, independent tidy data set 
#   with the average of each variable for each activity and each subject.

allData$subjects<-as.factor(allData$subjects)
meltedData <- melt(allData, id = c("subjects", "activity"))
tidyData <- dcast(meltedData, subjects + activity ~ variable, mean)

#write the datafrom to file tidyData.txt

write.table(tidyData,"./data01/tidyData.txt")
