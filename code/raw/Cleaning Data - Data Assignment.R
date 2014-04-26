# Peer Assignment

# You should create one R script called run_analysis.R that does the following. 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive activity names. 
# Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

# 0. Preliminary work

# set working dir as base directory (one level up from "UCI HAR DAtaset"))
# adapt this to your file system if you want to run the code

 wd <- "C:\\Users\\massimo\\Google Drive\\Data Science\\03 - Getting and Cleaning Data\\Peer Assignment\\GetCleanDataPA"
 setwd(wd)

# manually created dir. Contains manually provided files and the final dataset.
DatDir      <- paste(wd,"/data", sep="")

TrainDir    <- paste(wd,"/UCI HAR Dataset/train", sep="")
TestDir     <- paste(wd,"/UCI HAR Dataset/test", sep="")
BaseDir     <- paste(wd,"/UCI HAR Dataset", sep="")

ActivityFile<- "activity_labels.txt"

NamesFile   <- "names.txt"
Result      <- "SummarizedTidy.csv"


TestFile    <- "X_test.txt" 
TestActFile <- "y_test.txt" 
TestSubj    <- "subject_test.txt"

TrainFile   <- "X_train.txt" 
TrainActFile<- "y_train.txt" 
TrainSubj   <- "subject_train.txt"

#  3.  Uses descriptive activity names to name the activities in the data set
#  4.  Appropriately labels the data set with descriptive activity names. 

# read the data files
test  <- read.table(paste(TestDir, TestFile, sep="/"), header=F)
train <- read.table(paste(TrainDir,TrainFile, sep="/"), header=F)

# read the activity files
test.act   <- read.table(paste(TestDir,  TestActFile,  sep="/"), header=F)
train.act  <- read.table(paste(TrainDir, TrainActFile, sep="/"), header=F)
# activity names
act.names  <- read.table(paste(BaseDir,  ActivityFile, sep="/"), header=F)
test.act.nam  <- merge(test.act,  act.names)
train.act.nam <- merge(train.act, act.names)

# subject files
test.sub   <- read.table(paste(TestDir,  TestSubj,  sep="/"), header=F)
train.sub  <- read.table(paste(TrainDir, TrainSubj, sep="/"), header=F)


# merge variables and activities and subjects
test$Activity    <- test.act.nam$V2
test$Subject     <- test.sub$V1

train$Activity   <- train.act.nam$V2
train$Subject    <- train.sub$V1

# mantain the origin of the data
test$Origin  <- "Test"
train$Origin <- "Train"

# 1. merge the data
merged <- rbind(train, test)

# see the number of observation per origin and if Activity correctly attribuited
table(merged$Origin)
table(merged$Activity)

#  give manually arranged variable names 
#       
VarNames<-read.table(paste(DatDir,NamesFile, sep="/"), header=T)
names(merged) <- c(as.character(VarNames$NAME), "Activity", "Subject" , "Origin")

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#    I am not so sure the "Angle_..Mean.." shoul be extracted. I extract them anyway

#     could do it in a single row but it would be less readable
means  <- grep("Mean.", names(merged),ignore.case=T)
stdevs <- grep("Standard.Dev", names(merged),ignore.case=T)

# mantains the original order 
cols   <- sort(c(means,stdevs))
# cleaned data set

restrictDF <- cbind(merged[,cols], merged[, c("Activity", "Subject")])
head(restrictDF)

# 5. Creates a second, independent tidy data set with the average of each variable 
#   for each activity and each subject
#   data table is the cleanest way to do it
library(data.table)
restrictDT <- data.table(restrictDF)
cleanDT <- restrictDT[, lapply(.SD, mean), by=c("Activity", "Subject")]

# write table on the base directory
ResCsv <- paste(DatDir,  Result, sep="/")
write.csv(cleanDT, ResCsv , row.names = FALSE)



