# Urman_and_Herranz_etal_2020
Trained and ready to use Neural Networks and Script for synthetic data generation and Neural Network train and validation of already selected features. 
 Please to load the trained model in R use:
 Chosen_Model<-readRDS("Downloaded_Model_Name.rds")
 
 To predict outcomes from your data use:
 Predictions<-predict(Chosen_Model, Newdata)
 
 Legend:
 Model              Outcome   Meanning 
 Lipids_PDAC_NN       1         PDAC
 Lipids_CCA_NN        0         CCA
 Proteomics_PDAC_NN   0         CCA
 Proteomics_CCA_NN    1         PDAC
