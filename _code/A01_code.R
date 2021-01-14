# title: Assignment 1: PHC 6194 - Spring 21
## author: Andrew S. Cistola MPH

### Setup Workspace
setwd('/home/drewc/GitHub/_colab/PHC6194/_student') # Set wd to project repository
library(ggplot2) # General use plotting library from Hadley Wickham
library(reshape2) # Library for long/wide conversions from Hadley Wickham
data(USArrests) # Load built in R dataset

### Q1. Load the built in data "USArrests" and print out the first 6 rows (10pts)
df_arrest = data.frame(USArrests) # Save object as data frame
head(df_arrest) # Print mini table with first 6 observations 

### Q2. Categorize UrbanPop into quartiles and save it as a new variable "UrbanPopG" (10pts)
df_Q02 = df_arrest # Rename dataframe 
df_Q02$UrbanPopG = cut(df_Q02$UrbanPop, breaks = quantile(df_Q02$UrbanPop, probs = c(0,0.25,0.5,0.75,1)), include.lowest = T) # Create column of quantiles based on column
print(df_Q02$UrbanPopG) # Show object in terminal

### Q3. Convert "UrbanPopG" from factor into num (1=1st quartile, 2=2nd quartile, 3=3rd quartile, 4=4th quartile) (10pts)
df_Q02 = df_Q03 # Rename dataframe 
df_Q03$UrbanPopG = factor(df_Q03$UrbanPopG, labels = c(1, 2, 3, 4)) # Convert column in data frame to factor and define labels
df_Q03$UrbanPopG = as.numeric(df_Q03$UrbanPopG) # Convert column in data frame to numeric
print(df_Q03$UrbanPopG) # Show object in terminal

### Q4. Subset the data: select rows with Murder>=10 and UrbanPopG>=2, and save them as a dataframe "Q4" (10pts)
df_Q04 = subset(df_Q03, Murder >= 10 & UrbanPopG >= 2) # Subset data frame by multiple column values with boolean operators
print(df_Q04) # Show object in terminal

### Q5. Print out all the name of States included in the dataframe "Q4" (10pts)
v_Q05 = row.names(df_Q04) # Save rownames from data frame as vector
print(v_Q05) # Show object in terminal

### Q6. Generate a correlatin matrix with pairwise correlations among all variables in USArrests except for UrbanPopG, round the results to 3 decimal places, and save the results as a data.frame.matrix named "Q6" (10pts)
df_Q06 = round(cor(df_arrest, use = "pairwise.complete.obs"), 3) # Create correlation matrix, round to 3 decimal places
print(df_Q06) # Show object in terminal

### Q7. Create a linear regression model using USArrests with Murder as the outcome, and Assault, UrbanPopG (treat it as a categorical variable), and Rape as the predictors, save the model as "Q7", and print out a summary of the model (10pts)
lin_Q07 = lm(Murder ~ Assault + factor(UrbanPopG) + Rape, data = df_Q03) # Create multiple linear regression model
summary(lin_Q07) # Print summary of model 

### Q8. Use the package "ggplot2" and the data "USArrests" to create separated scatterplots between Murder and Assault by UrbanPopG (with different colors of the points by UrbanPopG, and size of the points proportional to the value of Rape). Add some transparency (alpha=0.9), and save the plot as Q8 (10pts)
df_Q08 = df_Q02 # Rename dataframe
df_Q08$UrbanPopG = factor(df_Q08$UrbanPopG, labels = c(1, 2, 3, 4)) # Convert column in data frame to factor and define labels
p_Q08 = ggplot(data = df_Q08, aes(x = Assault, y = Murder)) + geom_point(aes(color = UrbanPopG, size = Rape, alpha = 0.9)) + facet_wrap(~UrbanPopG) # Create multi-panel plot based on column with formatting/style options
ggsave('/home/drewc/GitHub/_colab/PHC6194/_student/_fig/A01_Q08_graph.jpeg', plot = p_Q08) # Save ggplot as jpeg

### Q9. Based on the plot created in Q8, add the title, labels, and a trend line, remove the background shading, and use a cutom color palette of "Reds" (10pts)
p_Q09 = ggplot(data = df_Q08, aes(x = Assault, y = Murder)) + geom_point(aes(color = UrbanPopG, size = Rape, alpha = 0.9)) + scale_color_brewer(palette = "Reds") + stat_smooth() + facet_wrap(~UrbanPopG) + theme(panel.background = element_blank(), plot.title = element_text(face = 'bold'), axis.title = element_text(face = 'bold')) + ggtitle("Murder versus Assault") # Create multi-panel plot based on column with formatting/style options
ggsave('/home/drewc/GitHub/_colab/PHC6194/_student/_fig/A01_Q09_graph.jpeg', plot = p_Q09) # Save ggplot as jpeg

### Q10. Generate a correlation heatmap among all variables in USArrests except for UrbanPopG, round the results to 3 decimal places (show all the correlation coefficients except for those equal to 1) (10pts)
df_Q10 = melt(round(cor(df_arrest, use = "pairwise.complete.obs"), 3)) # Create correlation matrix, round to 3 decimal places
df_Q10 = subset(df_Q10, value < 1) # Subset data frame by multiple column values with boolean operators
p_Q10 = ggplot(df_Q10, aes(Var1, Var2)) + geom_tile(aes(fill = value)) + geom_text(aes(label = value), size = 3, fontface = "bold") + scale_fill_gradient2(low = "#67a9cf", high = "#ef8a62") +theme_minimal() +theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),  panel.border = element_blank(),panel.background = element_blank(), axis.title = element_blank(), axis.text = element_text(size = 12, face = "bold")) # Create correplation heatmap with formatting/style options
ggsave('/home/drewc/GitHub/_colab/PHC6194/_student/_fig/A01_Q10_graph.jpeg', plot = p_Q10) # Save ggplot as jpeg