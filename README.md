# Urman_and_Herranz_etal_2020
Trained and ready to use Neural Networks and Script for synthetic data generation and Neural Network train and validation of already selected features. \n
 Please to load the trained model in R use:\n
 Chosen_Model<-readRDS("Downloaded_Model_Name.rds")\n
 
 To predict outcomes from your data use:\n
 Predictions<-predict(Chosen_Model, Newdata)\n
 
 Legend:\n
 Model              Outcome   Meanning \n
 Lipids_PDAC_NN       1         PDAC\n
 Lipids_CCA_NN        0         CCA\n
 Proteomics_PDAC_NN   0         CCA\n
 Proteomics_CCA_NN    1         PDAC\n
