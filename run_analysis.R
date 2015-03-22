#run_analysis.R 



#You should create one R script called run_analysis.R that does the following. 
#1- Merges the training and the test sets to create one data set.
#2- Extracts only the measurements on the mean and standard deviation for each measurement. 
#3- Uses descriptive activity names to name the activities in the data set
#4- Appropriately labels the data set with descriptive variable names. 
#5 -From the data set in step 4, creates a second, independent tidy data set with the average 
#   of each variable for each activity and each subject.


## Download and Unzip the Files into a directory named projectData in the same
## folder as teh run_head(analysis.R script
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if(!file.exists("projectData")){
  
  dir.create("projectData")
  temp <- tempfile()
  download.file(url,temp)
  unzip(temp,exdir = "projectData")
}
dataRoot<-file.path(getwd(),"projectData/UCI HAR Dataset/")[1]



# readfeatureLabelsTest
featureLabels<-read.table(file.path(dataRoot,"features.txt"))
#read activity labels 
activityLabels<-read.table(file.path(dataRoot,"activity_labels.txt"))

## read the test data, which is the smaller set
X_test<-read.table(file.path(dataRoot,"\\test\\X_test.txt"))
##insert the colnames from featureLabels
colnames(X_test)<-featureLabels[,2]
##read the test data activity labels
Y_test_activities<-read.table(file.path(dataRoot,"\\test\\y_test.txt"))
##read the test subject labels
Y_test_subjects<-read.table(file.path(dataRoot,"\\test\\subject_test.txt"))
## the first column can have the test subject no
X_testS<-cbind(Y_test_subjects,Y_test_activities,X_test)



## read the train data, which is the larger set
X_train<-read.table(file.path(dataRoot,"\\train\\X_train.txt"))
##insert the colnames from featureLabels
colnames(X_train)<-featureLabels[,2]

##read the train data labels
Y_train_activities<-read.table(file.path(dataRoot,"\\train\\y_train.txt"))

##read the train subject labels
Y_train_subjects<-read.table(file.path(dataRoot,"\\train\\subject_train.txt"))

## the first column can have the test subject no
X_trainS<-cbind(Y_train_activities,Y_train_subjects,X_train)

## the first column can have the test subject no
X_trainS<-cbind(Y_train_subjects,Y_train_activities,X_train)


## let's merge them together= stack them up
X_merged<-rbind(X_testS,X_trainS)

## Let's label the first column as well, so it doesn't cry, feeling all left out named after a WWII rocket 
colnames(X_merged)[1]<-"Subject"
## Let's label the second column for the same reason
colnames(X_merged)[2]<-"Activity"

## We would like to look at the mean  and std of each measurement
## It looks like they are already calculated in this set so we don't have to
## We will just pick the columns that contain words: Subjcet Activity std() or mean() or Subject 

X_merged_mean_std<-X_merged[grep("Subject|Activity|mean()|std()", colnames(X_merged))]


#let's apply the activity label
X_merged_mean_std$Activity<-factor(X_merged_mean_std$Activity,levels=activityLabels[,1],labels=activityLabels[,2])

#X_merged_mean_std  is our First Data set with descriptive activity labels
#----------------------------

#5 -From the data set in step 4, creates a second, independent tidy data set with the average 
#   of each variable for each activity and each subject.


library(dplyr)
## group by subject and activity
sjectsandAct<-group_by(X_merged_mean_std,Subject,Activity)

## summarise each variable
result<-summarise_each(sjectsandAct,funs(mean))

write.table(result,file = "result.txt")


