#Assignment 5

#Q0. Load packages "GWmodel", "tigris", "sqldf", "lme4", "rgeos", "arm", "ggplot2", "plyr" and set "WK10" folder as the working directory (0 pt)

library(tigris)  
library(sqldf)
library(lme4) # Linear mixed effect modeling in R
library(rgeos) 
library(arm) # Visualizations of linear mixed effect modeling using 'lme4' in R
library(ggplot2) # General use plotting library from Hadley Wickham
library(plyr) # Data manipulation from Hadley Wickham 



########################################
#Part 1. Data Import and Clean (30 pts)#
########################################

#Q1. Load the built-in data "USelect" using the data() function. Print the first 6 rows of its data slot, and check its SRID. (2 pts)


#Q2. Assign SRID 4326 to USelect2004, and add an id variable "electid" to the data slot of "USelect2004" with value automatically increased from 1 to 3111. (2 pts)


#Q3. Download boundaries of all states using the states() function from the package "tigris", save them as an object "us", and check its SRID. (1 pt)


#Q4. Transform the SRID of "us" to 4326, and remove Alaska (02), Hawaii (15), American Samoa (60), Guam (66), Northern Mariana Islands (69), Puerto Rico (72), and Virgin Islands (78). (5 pts)


#Q5. Import "stateEduc.csv" from the "dat" folder as "stateEduc". Rename "GEO.id2" to "GEOID". (2 pts)


#Q6. Calculate percentage of population with education less than high school (HD01_VD02/HD01_VD01), save it as a new column "plowedu". (2 pts)


#Q7. Merge "plowedu" to the data slot of "us" based on "GEOID". (5 pts)


#Q8. Get the centroids of election divisions, and save them as "centroidelect". (3 pts)


#Q9. Use the over() function to overlay the centroids and state boundaries, and merge "GEOID" and "plowedu" from "us" to "USelect2004". (5 pts)


#Q10. Create a new column in "USelect2004" named "bush", which equals to 1 if winner="Bush", and 0 otherwise. (3 pts)


#######################################
#Part 2. Mixed Effects Models (30 pts)#
#######################################
#Q11. Build a mixed-effects model "m1" with the binary variable "bush" as the outcome, "pctcoled" and "plowedu" as the predictors. Please fit the model with fixed slopes and a random intercept by "GEOID". Use display() function to print out the summary of the results. (5 pts)

#Q12. Calculate ICC based on the output of "m1". (5 pts)

#Q13. Calculate the ORs and 95% CI for each 10% increase in "pctcoled" and 1% increase in "plowedu". (10 pts)

#Q14. Build a second model "m2" using the same outcome and predictors as "m1", but with a varying intercept, a varying slope for "pctcoled", and a fixed slope for "plowedu". Print out the summary of the results. (5 pts)

#Q15. Calculate the OR and 95% CI for each 10% increase in "pctcoled" in the state of Florida. (5 pts)

######################
#Part 3. GWR (40 pts)#
######################
#Q16. Generate the centroids of all states and save them as "centroidstate". (2 pts)

#Q17. Generate two distance matrices with "DM1" using "centroidelect" as dp.locat, and "DM2" using "centroidelect" as dp.locat and "centroidstate" as rp.locat. (5 pts)

#Q18. Use cross-validation to find the optimal N for a GWR with "bush" as the outcome, "pctcoled" and "plowedu" as the predictors, and "DM1" as the distance matrix. Please use a "gaussian" kernel, with "longlat" option set to "TRUE". Save the optimal N as "gwrn". (5 pts)

#Q19. Fit a GWR to the ceontroids of election divisions using the optimal N with a "Gaussian" kernel. Save the model as "gwrm1", and print out the first 6 rows of the results. (5 pts)

#Q20. Calculate the OR for each 10% increase in "pctcoled" and save it as a new column "ORpctcoled" in "USelect2004". Print out the first 6 ORs. (3 pts)

#Q21. Map the ORs. (5 pts)

#Q22. Fit another GWR to the ceontroids of states using the optimal N with a "Gaussian" kernel. Save the model as "gwrm2", and print out the first 6 rows of the results. (5 pts)

#Q23. Calculate the OR for each 10% increase in "pctcoled" and save it as a new column "ORpctcoled" in "us". Print out the first 6 ORs. (5 pts)

#Q24. Map the ORs. (5 pts)
