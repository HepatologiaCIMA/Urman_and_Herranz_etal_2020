# Urman_and_Herranz_etal_2020
Trained and ready to use Neural Networks and Script for synthetic data generation and Neural Network train and validation of already selected features. <br/>
 Please to load the trained model in R use:<br/>
 Chosen_Model<-readRDS("Downloaded_Model_Name.rds")<br/>
 
 To predict outcomes from your data use:<br/>
 Predictions<-predict(Chosen_Model, Newdata)<br/>
 
 Legend:<br/>
 Model              Outcome   Meanning <br/>
 Lipids_PDAC_NN       1         PDAC<br/>
 Lipids_CCA_NN        0         CCA<br/>
 Proteomics_PDAC_NN   0         CCA<br/>
 Proteomics_CCA_NN    1         PDAC<br/>
