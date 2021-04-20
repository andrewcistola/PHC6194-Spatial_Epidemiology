### Import and Join Labels (W) with Predictors (X) and Outcomes (Y)
df_W = read.csv('_data/FIPS_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_X = dbGetQuery(con_1, 'SELECT * FROM CDC_PLACES_2019_ZCTA') # Select first 6 lines from table with PostgreSQL query
df_WX = merge(df_W, df_X, by = 'ZCTA', how = 'inner') # Merge data frame into data slot in SpatialDataFrame
df_WX$population[!is.finite(df_WX$population)] <- 0
df_WX$mhlth_crudeprev <- df_WX$D1_23
df_WX$mhlth_percent <- df_WX$mhlth_crudeprev
df_WX$mhlth_count =  df_WX$mhlth_percent * df_WX$population / 100 # Calculate countd counts from rates
df_WX$total_pop <- df_WX$population
df_WX$mhlth_count[!is.finite(df_WX$mhlth_count)] <- 0
df_WX$mhlth_count = round(df_WX$mhlth_count, 0)
df_WX = df_WX[c('mhlth_count', 'mhlth_percent', 'total_pop', 'ZCTA')]
head(df_WX)
write.csv(df_WX, paste('_data/CDC_PLACES_2020_mhlth.csv', sep = ''), row.names = FALSE) # Clean in excel and select variable
