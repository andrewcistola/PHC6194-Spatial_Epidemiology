#Assignment 4

#Q0. Load packages "spdep", "tigris", "sqldf", "RColorBrewer", "rsatscan", "ggplot2", "plyr", and set "WK8" folder as the WD. (0 pt)

########################################
#Part 1. Data Import and Clean (20 pts)#
########################################

#Q1. Import the Florida 2016 county-level mortality data "fldeath2016.txt" as a dataframe "fldeath". Please DO NOT import strings as factors. Print the first 6 rows of "fldeath". (3 pts)

#Q2. Import the Florida county boundaries data from TigerLine. You can use the counties() function in the package "tigris". Save it as a SpatialPolygonDataFrame "fl". Check the projection of it. (5 pts)

#Q3. Rename the varaibles "Crude.Rate" as "mort", and "County.Code" as "fips". (2 pts)

#Q4. Merge the variables "Deaths", "Population", "mort" from "fldeath" to the data slot in "fl" based on fips code. Hint: you can use the package "sqldf" to run sql query in R without passing it to a sql database. (5 pts)

#Q5. Calculate the expected number of deaths for each county and save it as a new variable "expdeaths" in "fl". Print out the first 6 rows of the data slot in "fl". (5 pts)


##################################
#Part 2. Disease Mapping (20 pts)#
##################################

#Q6. Assuming a Poisson distribution, please calculate the probability P[y<=Y] (observed<=expected). You can save the probability as a new variable "prob" in "fl". (5 pts)

#Q7. Show the probability "prob" on a map. Use the following cutoff to categorize the probability: 0,.05,.1,.25,.5,.75,.9,.95,1. (5 pts)

#Q8. Generate a local Empirical Bayes Smoothed mortality rate based on Queen neighbors, and save it as "mortlebs" in "fl". Print out the first 6 rows of the data slot in "fl". (5 pts)

#Q9. Plot the local Empirical Bayes Smoothed mortality rates. Use the following cutoff to categorize the probability: 0,.002,.004,.006,.008,.010,.012,.014,.016,.018. (5 pts)

################################################
#Part 3. Disease Clustering: Moran's I (25 pts)#
################################################

#Q10. Calculate Global Moran's I based on the local Empirical Bayes Smoothed mortality rates and Queen neighbor weight matrix. (5 pts)

#Q11. Calculate LISA using the local Empirical Bayes Smoothed mortality rates and Queen neighbor weight matrix. Save the results as "lm". Print out the first 6 rows in "lm". (5 pts)

#Q12. Merge "lm" to the data slot in "fl". (5 pts)

#Q13. Create a new variable "quad_sig" in "fl" to save the moran plot quadrant (1=low-low, 2=low-high, 3=high-low, 4=high-high, 5=non-significant (use 0.1 as sig level)). (5 pts)

#Q14. Plot "quad_sig" on a map. (5 pts)

##############################################
#Part 4. Disease Clustering: SatScan (35 pts)#
##############################################

#Q15. Generate the case, population, and geo data for Satscan. Name them "flcas", "flpop", and "flcrd". (5 pts)

#Q16. Output these data to temporary directory as "fl.cas", "fl.pop", and "fl.geo". (5 pts)

#Q17. Set and output parameters as "fl" to the temporary directory: using a Discrete Poisson moel with purely spatial analyses. (5 pts)

#Q18. Run SatScan, save the results as "flss" and print the summary of the results. (5 pts)

#Q19. Save the boundaries of clusters as "flcluster". (5 pts)

#Q20. Map the boundaries of clusters overlaid with the local EBS mortality rates. (10 pts)
