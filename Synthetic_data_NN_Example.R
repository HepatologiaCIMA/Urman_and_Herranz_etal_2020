#Load librarys
library(tidyverse)#Formatting and data editing
library(MASS)#Generate synthetic data
library(icesTAF) #Generate folders with mkdir
library(corrr)#Compute the correlation matrix and build correlograms
#Set working directory
setwd("H:/Reproducibility/P2_2020/Last AI Definitive/Datasets/Proteomics/")

#Study name
Study_name<-"Proteomics_OWL_28_May_2020_Testing_Synthetic"

#Load real data (Must be complete). The first column must specify the grouping variable, remaining ones numeric features
Reals_Data<-read.delim("Real_data/Complete_Lipids.txt", sep=" ", header=T) #Here we specify de separator and header to make it easy to change formats
colnames(Reals_Data)[1]<-"GROUP" #For simplicity and universality the first column is called GROUP

#Make data from features numeric conserving the exact number
Numerical_dataset<-NA #Initialize Numerical_dataset variable
for (a in 2:dim(Reals_Data)[2]){ #Start numeric conversion loop
  Numerical_Data_Point<-as.numeric(as.character(sub("," , ".", Reals_Data[,a]))) #Convert a variable from character to numeric maintaining the number
  Numerical_dataset<-cbind(Numerical_dataset,Numerical_Data_Point) #Bind as a table
}
Numerical_dataset<-Numerical_dataset[,2:dim(Numerical_dataset)[2]] #Delete the first useless column (NA)
colnames(Numerical_dataset)<-colnames(Reals_Data)[2:(dim(Reals_Data)[2])] #Add original column names
Reals_Data[,2:dim(Reals_Data)[2]]<-as.matrix(Numerical_dataset) #Change the datatype of original variable
#Generate suffled data (To test if the NN is overfitting rather than learning)
Suffle_Data<-Reals_Data #Copy data to a new variable
Number_Row<-sample(nrow(Reals_Data)) #Sample row numbers in random order
Suffle_Data[,1]<-Suffle_Data[Number_Row,1] #Use that random order to reorder the group variable (NO DIFERENCES ASSUMED)
rm(Number_Row) #Free space
  
#Synthetic data
groups<-levels(Reals_Data$GROUP)                            #Define groups
  
mkdir("Synthetic_Data")                                      #Create output folder for synthetic data
setwd("Synthetic_Data")                                      #set output folder for synthetic data
  
set.seed(3) #Set the seed to make this run reproducible 
Reals_Data[,2:length(Reals_Data)]<-jitter(as.matrix(Reals_Data[,2:length(Reals_Data)])) #Add jitter to real data (Reality and non 0 values for correlation)
set.seed(3)#Set the seed to make this run reproducible 
Suffle_Data[,2:length(Suffle_Data)]<-jitter(as.matrix(Suffle_Data[,2:length(Suffle_Data)])) #Add jitter to suffled data (Same conditions than Real data)
  
########## This loop computes the SD, Media and correlation matrix of each group in suffled and real data#########
mkdir("Real_Based_")                                          #Create output folder for synthetic data
setwd("Real_Based_")                                          #Set the output directory
names_data_M<-NA                                             #Initialize Medias files names vector
names_data_SD<-NA                                            #Initialize SD files names vector
names_data_CM<-NA                                            #Initialize CorrelMatrix files names vector
names_Group<-NA                                              #Initialize Group names vector
    for (y in 1:(length(groups))){    #Uses the group number to indicate the group           
      Medias<-NA                #Initialize Medias vector for each group
      SDs<-NA                   #Initialize SD vector for each group
      ####### Use the correct set for synthetic data generation, real or suffled.
      Dataset<-Reals_Data %>% filter(GROUP==groups[y]) #Get only one group per calculation not all at once
      corMat<-round(cor(Dataset[,2:dim(Dataset)[2]], use = "complete.obs"),2)    #Compute Correlation matrix
      for (x in 2:dim(Dataset)[2]){               #Compute the SD and means for each variable
        Media<-mean(Dataset[,x],na.rm = TRUE)                  #Compute the means for variable X
        Media<-format(round(Media, 2), nsmall = 2)            #Format standart deviation data to avoid floating point precission issues (BUTTERFLY EFFECT)
        SD<-sd(Dataset[,x],na.rm = TRUE)                       #Compute the SD for variable X
        SD<-format(round(SD, 3), nsmall = 3)            #Format standart deviation data to avoid floating point precission issues (BUTTERFLY EFFECT)
        Medias<-cbind(Medias, Media)               #Store the means in a vector
        SDs<-cbind(SDs,SD)                     #Store the SDs in a vector
      }
      
      SDs<-SDs[2:(length(SDs))] #Delete the first element, non informative, initialization element NA from SD
      Medias<-Medias[2:(length(Medias))] #Delete the first element, non informative, initialization element NA from Media
      write.csv(Medias,paste(groups[y],"Means_",Study_name)) #Write in a CSV the means for specific group
      write.csv(SDs,paste(groups[y],"SDs_",Study_name)) #Write in a CSV the sds for specific group
      write.csv(corMat,paste(groups[y],"CM_",Study_name)) #Write in a CSV the correlation matrix for specific group
      names_data_CM<-cbind(names_data_CM,paste(groups[y],"CM_",Study_name)) #Store names of all Correlation matrix files
      names_data_M<-cbind(names_data_M,paste(groups[y],"Means_",Study_name)) #Store names of all means files
      names_data_SD<-cbind(names_data_SD,paste(groups[y],"SDs_",Study_name)) #Store names of all sd files
      names_Group<-cbind(names_Group,paste(groups[y]))        #Store names of groups
    }
    names_data_SD<-names_data_SD[2:length(names_data_SD)] #Delete the initialization element from Names vector of SDs
    names_data_M<-names_data_M[2:length(names_data_M)] #Delete the initialization element from Names vector of means
    names_data_CM<-names_data_CM[2:length(names_data_CM)] #Delete the initialization element from Names vector of Correlation matrix
    names_Group<-names_Group[2:length(names_Group)] #Delete the initialization element from Names vector 
    
    Full_Table<-NA #Initialize table that will store the final synthetic data
    
    #### Compute the synthetic data #####
    for (i in 1:length(groups)){ #For each group generate synthetic data with its mean and covariance matrix
      mu <- read.csv(paste(names_data_M[i]))[,2] #Input medias data for specific group
      stddev <- read.csv(paste(names_data_SD[i]))[,2] #Input SDs data for specific group
      corMat<-read.csv(paste(names_data_CM[i]))[,2:(length(stddev)+1)] #Input Correlation Matrix data for specific group
      corMat<-as.matrix(corMat)#Specify matrix class
      
      stddev<-round(stddev,3) #Round standart deviation to avoid floating point imprecissions (Just in case, as the data have been already rounded)
      mu<-round(mu,2) #Round mean to avoid floating point imprecissions (Just in case, as the data have been already rounded)
      covMat <- stddev %*% t(stddev) * corMat #Compute covarianze matrix
      covMat <- covMat + diag(ncol(covMat))*0.01 #Precission issues 
      covMat<-round(covMat,2) #Round covariance matrix to avoid floating point imprecissions
      #Synthetic data generation#
      set.seed(42)#Stablish the seed for reproducibility issues
      Syndata <- mvrnorm(n = 300, #Generate 300 data points per group
                         mu = mu, #Set the mean
                         Sigma = covMat,#Set the correlation matrix
                         tol = 1e-1, #Tolarance of data precission to 1 decimal, actually we use 2, but setting to 1 ensure that this line works
                         empirical = F) #The output data has no empirically identical mean, reality
      
      Syndata<-cbind(GROUP=names_Group[i],Syndata) #Identify the data with its correspondent group
      colnames(Syndata)[2:(dim(corMat)[2]+1)]<-colnames(corMat) #Recover the feature names
      Full_Table<-rbind(Full_Table, Syndata) #Add to the final table
      write.csv(Syndata, paste(names_Group[i], "Synthetic_data_",Study_name)) #Write the data of the group alone
    }
    
    Full_Table<-Full_Table[2:(dim(Full_Table)[1]),] #Delete useless variables
    #Make data from features numeric conserving the exact number#
    Numerical_dataset<-NA #Initialize Numerical_dataset variable
    for (a in 2:dim(Full_Table)[2]){
      Numerical_datapoint<-as.numeric(as.character(sub("," , ".", Full_Table[,a])))#Convert a variable from character to numeric, maintaining the number
      Numerical_dataset<-cbind(Numerical_dataset,Numerical_datapoint)#Bind as a table
    }
    
    #Numerical_dataset[,2:dim(Numerical_dataset)[2]]<-Numerical_dataset[,2:dim(Numerical_dataset)[2]]^2
    #Numerical_dataset[,2:dim(Numerical_dataset)[2]]<-Numerical_dataset[,2:dim(Numerical_dataset)[2]]^0.5
    Full_Table<-cbind(GROUP=Full_Table[,1],Numerical_dataset[,2:dim(Numerical_dataset)[2]]) #Change the datatype of original variable
    colnames(Full_Table)[2:dim(Full_Table)[2]]<-colnames(corMat) #Set feature names as the originals
    write.csv(Full_Table, paste("Complete_Synthetic_Data_", Study_name)) #Write complete synthetic data
    setwd("../")#Return to home directory
}
  
  
  
  
#Packages for the neural network
library(tidyverse) #Data filtering
library(ROCR) #Package for ROC curve visualization
library(caret) #Package for easy AI algorythms
library(nnet) #Package for neural networks (Used to encode hot vector)
  
  
  
#Data setting
setwd("H:/Reproducibility/P2_2020/Last AI Definitive/Datasets/Proteomics/")
  
#Load data
Train_Raw<- read.delim(paste("Synthetic_Data/Real_Based_/Complete_Synthetic_Data_ ", Study_name, sep=""), sep=",")  #Training dataset (Synthetic)

Validation_Raw<- read.delim("Real_data/Complete_Lipids.txt", sep=" ", header=T)#Validation dataset (Real)
  
  

Train_Raw<-Train_Raw[,2:length(Train_Raw)] #Delete the index column
colnames(Validation_Raw)[1]<-"GROUP" #Set the grouping variable with GROUP name
Vars<-c("PC.14.0.16.1.", "PC.16.1.20.4.", "Cer.d18.1.16.0.", "Cer.42.3.", "PC.16.1.18.2.", "PC.17.1.18.1.", "PC.20.4", "Triacylglycerols", "PC.18.3.18.3.", "PC.14.0.18.2.") #CCA
Group_A<-"CONTROL" #Group 1 name
Group_B<-"CCA" #Group 2 name
#Format data
Train<-Train_Raw %>% filter(GROUP==Group_A | GROUP==Group_B) %>%droplevels()#Select only one vs one combination per time
Train <- cbind(Train[,2:dim(Train)[2]], class.ind(as.factor(Train[,1])))    #Encode as hot vector
  
Comparation<-paste(Group_A," vs ", Group_B) #Compared groups
Outcome<-names(Train)[dim(Train)[2]] #Select the outcome variable
Train[,Outcome]<-as.factor(Train[,Outcome])#Convert to a factor
  
validation<-Validation_Raw %>% filter(GROUP==Group_A | GROUP==Group_B) %>%droplevels()#Select only one vs one combination per time
validation <- cbind(validation[,2:dim(validation)[2]], class.ind(as.factor(validation[,1]))) #Encode as hot vector
  
validation<-validation[,1:(dim(validation)[2])] #Get only one output column
validation[,dim(validation)[2]]<-as.factor(validation[,dim(validation)[2]])#Convert to a factor
  

set.seed(2) #Reproducibility issues
rows <- sample(nrow(Train)) #Sample row numbers in random order
Train <- Train[rows, ] #Use that random order to reorder the rows 

#Control of training method
control<-trainControl(method = "cv", #Cross validation
                        p = 0.90) #90% for training, 10% for validation
nnetGrid <-  expand.grid(size = 18,decay = 0.2) #These are the optimal parameters for CCA
  
  #Test 5
set.seed(2)#Reproducibility issues
model_nnet  <- train(Train[,Vars], #train set input predictors
                       Train[,Outcome], #train set output
                       method="nnet", #Neural network algorithm
                       maxit=2000, #Maximum iteration before stop when training (unless converge)
                       trControl=control, #Control specified above
                       tuneGrid = nnetGrid, #Optimum parameters
                       verbose=FALSE) #Dont show results
  
final_predictions <- predict(model_nnet, validation[,Vars]) #Prediction of the validation set (Real data)
nnet_R_ROC<-confusionMatrix(final_predictions, validation[, Outcome])#Get prediction capacity parameters
  
  
Predicted<-predict(model_nnet, validation[,Vars], type = "prob")[2] #Prediction of the validation set (Real data) to compute AUC
Predicted<-Predicted$`1`         #Get only the values from one group class probability
predictions=as.vector(Predicted) #Transform into a vector
pred=prediction(predictions,validation[, Outcome]) #Match with the real output
perf_AUC=performance(pred,"auc") #Calculate the AUC value
AUC_NNet=perf_AUC@y.values[[1]] #Extract the AUC value
