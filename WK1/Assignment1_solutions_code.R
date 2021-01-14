# Assignment 1
# PHC 6194 - Spring 21
# Andrew Cistola
setwd('/home/drewc/GitHub/_colab/PHC6194/_student') # Set wd to project repository

# Q1. Load the built in data "USArrests" and print out the first 6 rows (10pts)
data(USArrests) # Load built in R dataset
df_arrest = data.frame(USArrests) # Save object as data frame
head(df_arrest) # Print mini table with first 6 observations 

# Q2. Categorize UrbanPop into quartiles and save it as a new variable "UrbanPopG" (10pts) 
df_arrest$UrbanPopG = cut(df_arrest$UrbanPop, breaks = quantile(df_arrest$UrbanPop, probs = c(0,0.25,0.5,0.75,1)), include.lowest = T) # Create column of quantiles based on column
df_arrest$UrbanPopG # Show column in dataframe

# Q3. Convert "UrbanPopG" from factor into num (1=1st quartile, 2=2nd quartile, 3=3rd quartile, 4=4th quartile) (10pts)
df_arrest$UrbanPopG = factor(df_arrest$UrbanPopG, labels = c(1, 2, 3, 4)) # Convert column in data frame to factor and define labels
df_arrest$UrbanPopG = as.numeric(df_arrest$UrbanPopG) # Convert column in data frame to numeric
df_arrest$UrbanPopG # Show column in dataframe

#Q4. Subset the data: select rows with Murder>=10 and UrbanPopG>=2, and save them as a dataframe "Q4" (10pts)
df_Q4 = subset(df_arrest, Murder >= 10 & UrbanPopG >= 2) # using subset function
print(df_Q4) # Show object in terminal

#Q5. Print out all the name of States included in the dataframe "Q4" (10pts)
v_state = row.names(df_Q4) # Save rownames from data frame as vector
print(v_state) # Show object in terminal

#Q6. Generate a correlatin matrix with pairwise correlations among all variables in USArrests except for UrbanPopG, round the results to 3 decimal places, and save the results as a data.frame.matrix named "Q6" (10pts)
df_arrest = data.frame(USArrests) # Save object as data frame
df_Q6 = round(cor(df_arrest, use = "pairwise.complete.obs"),3) # Create correlation matrix, round to 3 decimal places
print(df_Q6) # Show object in terminal

#Q7. Create a linear regression model using USArrests with Murder as the outcome, and Assault, UrbanPopG (treat it as a categorical variable), and Rape as the predictors, save the model as "Q7", and print out a summary of the model (10pts)


#Q8. Use the package "ggplot2" and the data "USArrests" to create separated scatterplots between Murder and Assault by UrbanPopG (with different colors of the points by UrbanPopG, and size of the points proportional to the value of Rape). Add some transparency (alpha=0.9), and save the plot as Q8 (10pts)


#Q9. Based on the plot created in Q8, add the title, labels, and a trend line, remove the background shading, and use a cutom color palette of "Reds" (10pts)


#Q10. Generate a correlation heatmap among all variables in USArrests except for UrbanPopG, round the results to 3 decimal places (show all the correlation coefficients except for those equal to 1) (10pts)
