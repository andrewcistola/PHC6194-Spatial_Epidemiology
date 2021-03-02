#Assignment 3

#############################
#Part 1. Data Clean (20 pts)#
#############################

#Q1. Load the packages "RPostgreSQL","ggmap","rpostgis","sp","rgdal","ggplot2","rgeos","maptools","ggsn", and "plyr". (1 pt)

#Q2. Set the working directory to the "WK6" folder and create a connection to the "phc6194db" database in postgresql. (4 pts)

#Q3. Retrieve the three tables you created in Assignment 2 ("wk5.flbg", "wk5.publix", and "wk5.school") from the PostGIS and import them as Spatial*DataFrame objects in R (name them as "flbg", "publix", and "school", respectively). Hint: you can use the pgGetGeom() function. Please use the "pt_ggmap" as the geometry column for "wk5.publix" and "wk5.school" when importing them. (5 pts)

#Q4. Create a basic map using plot() function on "flbg", and print out the first 6 rows of the non-spatial data in "flbg". (2 pts)

#Q5. Print out the SRS of "flbg". (3 pts)

#Q6. You can see that "flbg" includes all block groups in FL. Please find a way to keep only the block groups in Alachua County, and save them as "alachuabg". Print out the first 6 rows of the nonspatial data in "alachuabg". (10 pts)

########################################
#Part 2. Visualization using R (25 pts)#
########################################

#Q7. Please make a map using "alachuabg", "publix", and "school" using ggmap, ggplot2, and ggsn packages in R. Please try to make it look as similar as you can to the example attached on canvas (colors do not need to be the same). (25 pts) 

###########################################
#Part 3. Visualization using QGIS (25 pts)#
###########################################

#Q8. Export "alachuabg" to PostGIS as "wk6.alachuabg". (5 pts)

#Q9. Please use QGIS to make a map using "wk6.alachuabg", "wk5.publix", and "wk5.school", and try to make it look as similar as you can to the example attached on canvas (colors do not need to be the same). Save your map as a png image, and attach it in your submission. (20 pts)

############################################
#Part 4. Visualization using Carto (30 pts)#
############################################

#Q10. Output "alachuabg", "publix", "school" as KML in the "WK6" folder. (5 pts)

#Q11. Please use Carto to make an interactive map using the KML files exported in Q10, and try to make the interactive map as similar as the example here: https://huihu.carto.com/builder/1349ea86-ba71-47e9-a1ea-939dc1561691/embed Please include the link to your map in your submission. (25 pts)