#Assignment 1

#Q1. Load the built in data "USArrests" and print out the first 6 rows (10pts)


#Q2. Categorize UrbanPop into quartiles and save it as a new variable "UrbanPopG" (10pts) 


#Q3. Convert "UrbanPopG" from factor into num (1=1st quartile, 2=2nd quartile, 3=3rd quartile, 4=4th quartile) (10pts)


#Q4. Subset the data: select rows with Murder>=10 and UrbanPopG>=2, and save them as a dataframe "Q4" (10pts)


#Q5. Print out all the name of States included in the dataframe "Q4" (10pts)


#Q6. Generate a correlatin matrix with pairwise correlations among all variables in USArrests except for UrbanPopG, round the results to 3 decimal places, and save the results as a data.frame.matrix named "Q6" (10pts)


#Q7. Create a linear regression model using USArrests with Murder as the outcome, and Assault, UrbanPopG (treat it as a categorical variable), and Rape as the predictors, save the model as "Q7", and print out a summary of the model (10pts)


#Q8. Use the package "ggplot2" and the data "USArrests" to create separated scatterplots between Murder and Assault by UrbanPopG (with different colors of the points by UrbanPopG, and size of the points proportional to the value of Rape). Add some transparency (alpha=0.9), and save the plot as Q8 (10pts)


#Q9. Based on the plot created in Q8, add the title, labels, and a trend line, remove the background shading, and use a cutom color palette of "Reds" (10pts)


#Q10. Generate a correlation heatmap among all variables in USArrests except for UrbanPopG, round the results to 3 decimal places (show all the correlation coefficients except for those equal to 1) (10pts)
