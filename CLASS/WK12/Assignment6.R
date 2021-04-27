#Assignment 6

#Q0. Load packages "maptools", "spdep", "rgdal", "plyr", "INLA", and "ggplot2", and set "WK12" folder as the working directory (0 pt)

#Q1. Load the cleaned 2004 US election data "elect.Rda" in "data" folder using the load() function. (5 pts)

#Q2. Keep only the election divisions in Florida (GEOID=12), and save it as "FLelect2004". (10 pts)

#Q3 create a new ID variable "ID" for "FLelect2004" ranges from 1 to 67. (5 pts)

#Q4. Create an Queen adjacency graph, export the graph as "flelect.graph" in the "data" folder, and save the path to the graph file in "uselect.adj". (15 pts)

#Q5. Start with a "BYM" model with "bush" as the outcome, an intercept term, a spatially structured and a spatially unstrctured terms, and no covariates. Save the results of the model as "mod1". (Hint: family="binomial"). (15 pts)

#Q6. Obtain the marginal of spatially unstructured residual nu, save it as "m1", then calculate OR=exp(nu), unlist it and save it as "or1". (10 pts)

#Q7. Calculate the probability that the spatial effects OR are above 1. This is equivalent to calculate the probability that nu is above 0, which is easier to obtain. Unlist the probability and save it as "inlaprob1". (10 pts)

#Q8. Map the probability calculated in Q7. (10 pts)

#Q9. Add the covariates "unemploy","pctcoled","PEROVER65","pcturban", and "WHITE" to the model, and save the model as "mod2". (10 pts)

#Q10. Obtain the OR for each 10% increase in "WHITE" and its 95% CI. (10 pts)