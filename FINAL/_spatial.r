# allocativ 3001.2021.0002

## Spatial Step 1: Import and Clean Data
sp1 = 'Spatial Step 1: Import and Clean Data'

### Import and Join Labels (W) with Predictors (X) and Outcomes (Y)
df_W = read.csv('_data/FIPS_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_X1 = dbGetQuery(con_1, 'SELECT * FROM CDC_PLACES_2019_ZCTA') # Select first 6 lines from table with PostgreSQL query
df_X2 = dbGetQuery(con_1, 'SELECT * FROM CENSUS_ACS_2019_ZCTA') # Select first 6 lines from table with PostgreSQL query
df_X = merge(df_X1, df_X2, by = 'ZCTA', how = 'inner') # Merge data frame into data slot in SpatialDataFrame
df_Y = read.csv(paste('_data/', DV_file, '.csv', sep = ''), stringsAsFactors = FALSE) # Import dataset from _data folder
df_Y$D1_23 <- NULL
df_WX = merge(df_W, df_X, by = 'ZCTA', how = 'inner') # Merge data frame into data slot in SpatialDataFrame
df_WXY = merge(df_WX, df_Y, by.x = 'ZCTA', all.x = TRUE) # Merge data frame into data slot in SpatialDataFrame
head(df_WXY) # Verify

### Join with Shapes (Z)
sdf_Z = readOGR(dsn = '_shape/CENSUS_TIGER_2018_ZCTA', layer = 'cb_2018_us_zcta510_500k') # Import shape file with rgdal package
sdf_Z$ZCTA = as.character(sdf_Z$GEOID10) # Convert numeric to character
sdf_Z$ZCTA = paste('ZCTA', sdf_Z$ZCTA, sep = '') # Add character string to each value in column
library(sp) # Reimport sp library for merge() function
sdf_WXYZ = merge(sdf_Z, df_WXY, by = 'ZCTA') # Merge data frame into data slot in SpatialDataFrame
sdf_WXYZ = sdf_WXYZ[which(sdf_WXYZ$ST == ST & sdf_WXYZ$population >= 0), ]
head(sdf_WXYZ) # Verify
sdf_WXYZ # Show SpatialDataFrame

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(sp1, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c('Selected States: ', states, '\n'), file = 'summary.txt', append = TRUE)
cat(c('Zip Code Observations: ', nrow(df_WXY), '\n\n'), file = 'summary.txt', append = TRUE)
print(sdf_WXYZ)
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()

## Spatial Step 2: Create Spatially Adjusted Outcomes
sp2 = 'Spatial Step 2: Create Spatially Adjusted Outcomes'

### Tidy Counts
spm0 = 'Observed counts from Raw Data'
spr0 = 'count'
sdf_WXYZ$count <- sdf_WXYZ$mhlth_count
sdf_WXYZ$population[!is.finite(sdf_WXYZ$population)] <- 0
sdf_WXYZ$count[!is.finite(sdf_WXYZ$count) | sdf_WXYZ$population == 0] <- 0
summary(sdf_WXYZ$count) # verify

### Calculate Crude Rates
spm1 = 'Observed counts per 1000 residents from American Community Survey'
spr1 = 'crude'
sdf_WXYZ$crude =  sdf_WXYZ$count / sdf_WXYZ$population * 1000 # Calculate countd counts from rates
sdf_WXYZ$crude[!is.finite(sdf_WXYZ$crude) | sdf_WXYZ$population == 0] <- 0
sdf_WXYZ$crude = round(sdf_WXYZ$crude, 0)
summary(sdf_WXYZ$crude) # verify

### Log transform crude rates
spm2 = 'Transformed crude rates'
spr2 = 'log'
sdf_WXYZ$log = log(sdf_WXYZ$crude)
sdf_WXYZ$log[!is.finite(sdf_WXYZ$log)| sdf_WXYZ$population == 0] <- 0
summary(sdf_WXYZ$log) # Verify

### Calculate Standardized Rates
spm3 = 'Ratio of observed counts to expected counts based on global population rate'
spr3 = 'SMR'
US_rate = sum(sdf_WXYZ$count)/sum(sdf_WXYZ$population) # Calculate rate across US
sdf_WXYZ$expected = US_rate * sdf_WXYZ$population # Calculate expected rate
sdf_WXYZ$SMR = sdf_WXYZ$count / sdf_WXYZ$expected # Standardized mortality ratio (actual/expected)
sdf_WXYZ$SMR[!is.finite(sdf_WXYZ$SMR) | sdf_WXYZ$population == 0] <- NULL
summary(sdf_WXYZ$SMR) # verify

### Binary transformed standardized rates
spm4 = 'Binary variable representing SMR above 1'
spr4 = 'binary'
sdf_WXYZ$binary <- 0
sdf_WXYZ$binary[sdf_WXYZ$population > 0 & sdf_WXYZ$SMR > 1] <- 1
sdf_WXYZ$binary[sdf_WXYZ$population > 0 & sdf_WXYZ$SMR < 1] <- 0
sdf_WXYZ$binary[sdf_WXYZ$population == 0] <- NA
summary(sdf_WXYZ$binary) # verify

### Local Empirical Bayes Smoothing
spm5 = 'Local Empirical Bayes smoothed observed counts'
spr5 = 'bayes'
queen_N = poly2nb(sdf_WXYZ, queen = TRUE)# Queen's neighbors
bayes_local = EBlocal(sdf_WXYZ$count, sdf_WXYZ$population+1, queen_N) # Local Empirical Bayes smooothing, add 1 to population to remvoe zeros
sdf_WXYZ$bayes = bayes_local$est # Save as new column
sdf_WXYZ$bayes[!is.finite(sdf_WXYZ$bayes) | sdf_WXYZ$population == 0] <- 0
summary(sdf_WXYZ$bayes) # verify

### Standard Scaled bayes rate
spm6 = 'Standard Scaled bayes rate'
spr6 = 'scale'
sdf_WXYZ$scale = predict(boxcox(sdf_WXYZ$bayes, standardize = TRUE))
sdf_WXYZ$scale[!is.finite(sdf_WXYZ$scale)] <- 0
summary(sdf_WXYZ$scale) # Verify

### Verify
rates = c(spr0, spr1, spr2, spr3, spr4, spr5, spr6) # Save rates as object
summary(sdf_WXYZ[rates]) # Descriptive statistics on rates
dim(sdf_WXYZ[rates]) # Observations and variables
head(sdf_WXYZ[rates]) # Verify

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(sp2, '\n\n'), file = 'summary.txt', append = TRUE)
summary(sdf_WXYZ[rates])
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat(c(spr0, '=', spm0, '\n'), file = 'summary.txt', append = TRUE)
cat(c(spr1, '=', spm1, '\n'), file = 'summary.txt', append = TRUE)
cat(c(spr2, '=', spm2, '\n'), file = 'summary.txt', append = TRUE)
cat(c(spr3, '=', spm3, '\n'), file = 'summary.txt', append = TRUE)
cat(c(spr4, '=', spm4, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c(spr5, '=', spm5, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c(spr6, '=', spm6, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()

## Spatial Step 3: Test for Spatial Autocorrelation
sp3 = 'Spatial Step 3: Test for Spatial Autocorrelation'

### Moran's Test I for Spatial Autocorrelation
spm5 = 'Morans I and LISA weights using Queens Neighbors and Local Empirical Bayes smoothed counts'
spa1 = 'LISA'
queen_W = nb2listw(queen_N, zero.policy = TRUE) # Weight matrix based on neighbors
Y <- sdf_WXYZ$bayes
Y[is.na(Y)] <- 0 # Remove NA
moran_test = moran.test(Y, queen_W, zero.policy = TRUE) 
LISA = localmoran(Y, queen_W) # local moran test using queen's neighbors
colnames(LISA)[5] <- 'P'
colnames(LISA) <- paste('LISA_', colnames(LISA), sep = '') # Change column names to P
LISA[is.na(LISA)] <- 0 # Remove NA
sdf_WXYZ = cbind(sdf_WXYZ, LISA)
sdf_WXYZ$LISA <- 0 # create a new variable identifying the moran plot quadrant (dismissing the non-siginificant ones)
sdf_WXYZ$m.crude = sdf_WXYZ$crude - mean(sdf_WXYZ$crude) # center the variables around its mean
sdf_WXYZ$m.LISA_Ii = sdf_WXYZ$LISA_Ii - mean(sdf_WXYZ$LISA_Ii) # center the variables around its mean
sdf_WXYZ$LISA[sdf_WXYZ$m.crude < 0 & sdf_WXYZ$m.LISA_Ii < 0] <- -1
sdf_WXYZ$LISA[sdf_WXYZ$m.crude < 0 & sdf_WXYZ$m.LISA_Ii > 0] <- 0
sdf_WXYZ$LISA[sdf_WXYZ$m.crude > 0 & sdf_WXYZ$m.LISA_Ii < 0] <- 0
sdf_WXYZ$LISA[sdf_WXYZ$m.crude > 0 & sdf_WXYZ$m.LISA_Ii > 0] <- 1
sdf_WXYZ$LISA[sdf_WXYZ$LISA_P > 0.05] <- 0 # non-significant
summary(sdf_WXYZ$LISA) # verify

### Geographic Weighted Regression
spm6 = 'Geographic weighted regression'
spa2 = 'GWR'
Y = 'crude'

### Adjust for local health status
spi1 = 'health' 
X = names(subset(df_X1, select = -c(ZCTA)))
F = as.formula(paste(Y, ' ~ ', paste(X, collapse = ' + '), sep = ''))
D = sdf_WXYZ@data[c(X, Y)]
for(i in 1:ncol(D)) {D[ , i][is.na(D[ , i])] <- median(D[ , i], na.rm = TRUE)} # Replace missing values with column medians
head(D)

#### Get variance weights from PCA, importance weights from RandomForest
pca = prcomp(D[X], scale = TRUE, rank. = 1) # PCA from tidyverse, `scale = TRUE` standard scale features, `tol = 0.1` threshold percent of highest variance to keep components
df_pca = rownames_to_column(data.frame(abs(pca$rotation)))
df_pca = df_pca[which(df_pca$PC1 > quantile(df_pca$PC1, 0.5)[[1]]), ]
colnames(df_pca) <- c('feature', 'variance')
rf = randomForest(formula = F, data = D, ntree = 1000, importance = TRUE)
df_rf = rownames_to_column(as.data.frame(importance(rf)))
df_rf[,2] = df_rf[,2] / 100
df_rf = df_rf[,-3]
colnames(df_rf) <- c('feature', 'importance') # Change column names to easily readible
df_fp = merge(df_rf, df_pca, by = 'feature')
df_fp$weight = df_fp[,2] * df_fp[,3]
df_health = df_fp
head(df_fp)

#### Create Index
df_X$health = rowSums(df_X[df_fp$feature] * df_fp$weight)
df_X3 = df_X[c('ZCTA', 'health')]
sdf_WXYZ = merge(sdf_WXYZ, df_X3, by = 'ZCTA') # Merge data frame into data slot in SpatialDataFrame
sdf_WXYZ$health[!is.finite(sdf_WXYZ$health)] <- median(sdf_WXYZ$health, na.rm = TRUE)
summary(sdf_WXYZ$health) # Verify
head(sdf_WXYZ)

### Adjust for local social factors
spi2 = 'social' 
X = names(subset(df_X2, select = -c(ZCTA)))
F = as.formula(paste(Y, ' ~ ', paste(X, collapse = ' + '), sep = ''))
D = sdf_WXYZ@data[c(X, Y)]
for(i in 1:ncol(D)) {D[ , i][is.na(D[ , i])] <- median(D[ , i], na.rm = TRUE)} # Replace missing values with column medians
head(D)

#### Get variance weights from PCA, importance weights from RandomForest
pca = prcomp(D[X], scale = TRUE, rank. = 1) # PCA from tidyverse, `scale = TRUE` standard scale features, `tol = 0.1` threshold percent of highest variance to keep components
df_pca = rownames_to_column(data.frame(abs(pca$rotation)))
df_pca = df_pca[which(df_pca$PC1 > quantile(df_pca$PC1, 0.5)[[1]]), ]
colnames(df_pca) <- c('feature', 'variance')
rf = randomForest(formula = F, data = D, ntree = 1000, importance = TRUE)
df_rf = rownames_to_column(as.data.frame(importance(rf)))
df_rf[,2] = df_rf[,2] / 100
df_rf = df_rf[,-3]
colnames(df_rf) <- c('feature', 'importance') # Change column names to easily readible
df_fp = merge(df_rf, df_pca, by = 'feature')
df_fp$weight = df_fp[,2] * df_fp[,3]
df_social = df_fp
head(df_fp)

#### Create index
df_X$social = rowSums(df_X[df_fp$feature] * df_fp$weight)
df_X3 = df_X[c('ZCTA', 'social')]
sdf_WXYZ = merge(sdf_WXYZ, df_X3, by = 'ZCTA') # Merge data frame into data slot in SpatialDataFrame
sdf_WXYZ$social[!is.finite(sdf_WXYZ$social)] <- median(sdf_WXYZ$social, na.rm = TRUE)
summary(sdf_WXYZ$social) # Verify
head(sdf_WXYZ)

#### Get Bandwidth and GWR weights
RP = coordinates(gCentroid(sdf_WXYZ, byid = T, id = sdf_WXYZ$ZCTA))
DM1 = gw.dist(dp.locat = RP) # Compute the distances between the centroid points of polygons
fixed = sqrt(mean(aggregate(as.numeric(sdf_WXYZ$ALAND10), by = list(FIPS = sdf_WXYZ$FIPS), FUN = sum)$x)*3)
GWR = gwr.basic(bayes ~ 0 + social + health, data = sdf_WXYZ, kernel = "gaussian", regression.points = RP, bw = fixed, longlat = T, dMat = DM1) # Fit a GWR to the ceontroids of election divisions using the optimal N with a "Gaussian" kernel.
sdf_WXYZ$GWR <- -1*(log(abs(GWR$SDF$health - median(GWR$SDF$health)))) # Save weighhted coefficients as new column
sdf_WXYZ$GWR[!is.finite(sdf_WXYZ$GWR)] <- 0
summary(sdf_WXYZ$GWR) # Verify

### Calculate County wide crude, SMR, and bayes
df_Y2 = aggregate(sdf_WXYZ$population, by = list(FIPS = sdf_WXYZ$FIPS), FUN = ineq)
colnames(df_Y2) <- c('FIPS', 'population')
df_Y2$count = aggregate(sdf_WXYZ$count, by = list(FIPS = sdf_WXYZ$FIPS), FUN = sum)$x
df_Y2$count[!is.finite(df_Y2$count)] <- 0
df_Y2$crude = df_Y2$count / df_Y2$population
df_Y2$crude[!is.finite(df_Y2$crude)] <- 0
df_Y2$SMR = aggregate(sdf_WXYZ$SMR, by = list(FIPS = sdf_WXYZ$FIPS), FUN = mean)$x
df_Y2$SMR[!is.finite(df_Y2$SMR)] <- 0
df_Y2$bayes = aggregate(sdf_WXYZ$bayes, by = list(FIPS = sdf_WXYZ$FIPS), FUN = mean)$x
df_Y2$bayes[!is.finite(df_Y2$bayes)] <- 0

### Calculate County specific GINI, LISA, and GWR
spm7 = 'Gini index of crude hospitalization rate among zip codes within counties'
spa3 = 'gini'
df_Y2$gini = aggregate(sdf_WXYZ$crude, by = list(FIPS = sdf_WXYZ$FIPS), FUN = ineq)$x
df_Y2$gini[!is.finite(df_Y2$gini)] <- 0
df_Y2$LISA = aggregate(sdf_WXYZ$LISA, by = list(FIPS = sdf_WXYZ$FIPS), FUN = mean)$x
df_Y2$LISA[!is.finite(df_Y2$LISA)] <- 0
df_Y2$GWR = aggregate(sdf_WXYZ$GWR, by = list(FIPS = sdf_WXYZ$FIPS), FUN = mean)$x
df_Y2$GWR[!is.finite(df_Y2$GWR)] <- 0
head(df_Y2)

### Verify
auto = c(spr1, spr3, spr5, spa1, spa2, spa3) # Save rates as object
summary(df_Y2[auto]) # Descriptive statistics on rates
dim(df_Y2[auto]) # Observations and variables
head(df_Y2[auto]) # Verify

### Export Spatial Outcomes by Zip Code
ZCTA = c(spr0, spr1, spr2, spr3, spr4, spr5, spr6, spi1, spi2, 'ZCTA') # Save rates as object
df_Y_ZCTA = sdf_WXYZ[ZCTA] # Save
write.csv(df_Y_ZCTA, paste('_data/_spatial_ZCTA.csv', sep = ''), row.names = FALSE) # Clean in excel and select variable

### Export Spatial Outcomes by County
FIPS = c(spr1, spr3, spr5, spa1, spa2, spa3, 'FIPS') # Save rates as object
df_Y_FIPS = df_Y2[FIPS] # Save
write.csv(df_Y_FIPS, paste('_data/_spatial_FIPS.csv', sep = ''), row.names = FALSE) # Clean in excel and select variable

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(sp3, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c(spm5, ' (Null = No Autocorrelation)'), file = 'summary.txt', append = TRUE)
print(moran_test)
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat(c(spm6, '\n\n'), file = 'summary.txt', append = TRUE)
cat('Create composite indices from health variables\n'), file = 'summary.txt', append = TRUE)
head(df_health)
cat(c('\n'), file = 'summary.txt', append = TRUE)
print(cor.test(sdf_WXYZ$crude, sdf_WXYZ$health, method = 'spearman'))
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat('Create composite indices from social variables\n', file = 'summary.txt', append = TRUE)
head(df_social)
cat(c('\n'), file = 'summary.txt', append = TRUE)
print(cor.test(sdf_WXYZ$crude, sdf_WXYZ$social, method = 'spearman'))
cat(c('\n'), file = 'summary.txt', append = TRUE)
print(GWR)
cat(c('\n'), file = 'summary.txt', append = TRUE)
summary(df_Y2[auto])
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat('crude = crude rate per popualtion by County\n', file = 'summary.txt', append = TRUE)
cat('SMR = Mean zip code SMR by County\n', file = 'summary.txt', append = TRUE)
cat('bayes = Mean zip code bayes by County\n', file = 'summary.txt', append = TRUE)
cat(c(spa1, '=', spm5, '\n'), file = 'summary.txt', append = TRUE)
cat(c(spa2, '=', 'Weighted Coefficients of health index using ', spm6, '\n'), file = 'summary.txt', append = TRUE)
cat(c(spa3, '=', spm7, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()