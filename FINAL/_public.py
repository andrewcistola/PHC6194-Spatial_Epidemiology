# healthy

## Data Step 1: Import 1st dataset from API
ds1 = 'Pull and Clean Datasource from API' # Step 1 descriptive title
dd1 = 'CDC PLACES 2020 Release by Zip Code' # Dataset 1 descriptive title
dr1 = 'https://www.cdc.gov/places/index.html' # Dataset 1 url location
df1 = 'CDC_PLACES_2019_ZCTA' # Dataset 2 file label

### Dataset 1 API Query (CSV)
query_d1 = ("https://chronicdata.cdc.gov/resource/kee5-23sr.csv?"
    "&$$app_token=YmHGXtIwwRViIV4urwHNCAv0h"
    "&$limit=40000") # Save API as query
df_d1_API = pd.read_csv(query_d1) # Create data frame from APi query
df_d1_API.head() # Print first 5 observations
df_d1_API.info() # Get class, memory, and column info: names, data types, obs.

### Keep Values of Interest
df_d1 = df_d1_API.set_index('zcta5') # Set column as index
df_d1 = df_d1.loc[:, df_d1.columns.str.contains('prev')] # Select columns by string value
df_d1 = df_d1.reset_index() # Reset Index
df_d1.head() # Print first 5 observations
df_d1.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Table'] = df2 # Append string to all rows in column
df_l2.to_sql((df2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Zip Code Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Table']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((df2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.
### Export to SQL database
df_d1.to_sql(df1, con_1, if_exists = 'replace', index = 'ZCTA') # Export dataframe to SQL database

### Append step 1 results to corresponding text file and check results
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('Data Step 1: ' + ds1 + '\n\n') # Step description
text_file.write('Dataset: ' + dd1 + '\n') # Dataset description
text_file.write('URL: ' + dr1 + '\n') # Dataset description
text_file.write('Table: ' + df1 + '\n') # Dataset description
text_file.write('Observations and variables: ' + str(df_d1.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_d1.head()) + '\n\n') # Result description and result dataframe
text_file.write(str(df_l1.head()) + '\n\n') # Print all rows in Labels dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file
text_file = open('summary.txt') # Write new corresponding text file
summary = text_file.read() # Close file
print(summary)
text_file.close() # Close file

## Step 2: Import 2nd Dataset from API with multiple queries
ds2 = 'Import Second Dataset from API' # Step 2 descriptive title
dd2 = 'CENSUS ACS 2020 Release by Zip Code' # Dataset 2 descriptive title
dr2 = 'https://www.census.gov/programs-surveys/acs/' # Dataset 3 url
df2 = 'CENSUS_ACS_2019_ZCTA' # Dataset 2 file label

### Dataset 2, Table 1
d2_1 = 'Detailed Profile 2 (DP02) - Selected Social Characteristics'
table = '_DP02'
feature = 'D2_T1_'
query = ("https://api.census.gov/data/2019/acs/acs5/profile?get=group(DP02)"
    "&for=zip%20code%20tabulation%20area"
    "&key=c82350b0bbe6c8a46ce163365ee3f2abcd16253e") # Save API query

#### Pull Data from API (JSON)
df_d2 = pd.read_json(query)
df_d2.to_sql((df2 + table + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Keep Values of Interest
df_d2.columns = df_d2.iloc[0] # Save first row as column names
df_d2 = df_d2.iloc[1:] # Remove first row
df_d2.columns.name = None # Remove label for column names
df_d2 = df_d2.set_index(['GEO_ID', 'state', 'zip code tabulation area', 'NAME']) # Drop Unwanted Columns
df_d2 = df_d2.loc[:, df_d2.columns.str.contains('PE')] # Select columns by string value
df_d2 = df_d2.loc[:, ~df_d2.columns.str.contains('A')] # Select columns by string value
df_d2 = df_d2.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d2 = df_d2.select_dtypes(include = ['float64']) # Drop all unwanted data types
df_d2 = df_d2[df_d2 <= 100] # Susbet numeric column by condition
df_d2 = df_d2[df_d2 >= 0] # Susbet numeric column by condition
df_d2 = df_d2.dropna(axis = 1, thresh = 0.95*len(df_d2)) # Drop features less than 75% non-NA count for all columns
df_d2 = df_d2.reset_index() # Reset Index
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Table'] = df2 # Append string to all rows in column
df_l2.to_sql((df2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Zip Code Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Table']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((df2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Dataset 2, Table 2
d2_2 = 'Detailed Profile 3 (DP03) - Selected Economic Characteristics'
table = '_DP03'
feature = 'D2_T2_'
query = ("https://api.census.gov/data/2019/acs/acs5/profile?get=group(DP03)"
    "&for=zip%20code%20tabulation%20area"
    "&key=c82350b0bbe6c8a46ce163365ee3f2abcd16253e")

#### Pull Data from API (JSON)
df_d2 = pd.read_json(query)
df_d2.to_sql((df2 + table + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Keep Values of Interest
df_d2.columns = df_d2.iloc[0] # Save first row as column names
df_d2 = df_d2.iloc[1:] # Remove first row
df_d2.columns.name = None # Remove label for column names
df_d2 = df_d2.set_index(['GEO_ID', 'state', 'zip code tabulation area', 'NAME']) # Drop Unwanted Columns
df_d2 = df_d2.loc[:, df_d2.columns.str.contains('PE')] # Select columns by string value
df_d2 = df_d2.loc[:, ~df_d2.columns.str.contains('A')] # Select columns by string value
df_d2 = df_d2.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d2 = df_d2.select_dtypes(include = ['float64']) # Drop all unwanted data types
df_d2 = df_d2[df_d2 <= 100] # Susbet numeric column by condition
df_d2 = df_d2[df_d2 >= 0] # Susbet numeric column by condition
df_d2 = df_d2.dropna(axis = 1, thresh = 0.95*len(df_d2)) # Drop features less than 75% non-NA count for all columns
df_d2 = df_d2.reset_index() # Reset Index
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Table'] = df2 # Append string to all rows in column
df_l2.to_sql((df2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Zip Code Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Table']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((df2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Dataset 2, Table 3
d2_3 = 'Detailed Profile 4 (DP04) - Selected Housing Characteristics'
table = '_DP04'
feature = 'D2_T3_'
query = ("https://api.census.gov/data/2019/acs/acs5/profile?get=group(DP04)"
    "&for=zip%20code%20tabulation%20area"
    "&key=c82350b0bbe6c8a46ce163365ee3f2abcd16253e")

#### Pull Data from API (JSON)
df_d2 = pd.read_json(query)
df_d2.to_sql((df2 + table + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Keep Values of Interest
df_d2.columns = df_d2.iloc[0] # Save first row as column names
df_d2 = df_d2.iloc[1:] # Remove first row
df_d2.columns.name = None # Remove label for column names
df_d2 = df_d2.set_index(['GEO_ID', 'state', 'zip code tabulation area', 'NAME']) # Drop Unwanted Columns
df_d2 = df_d2.loc[:, df_d2.columns.str.contains('PE')] # Select columns by string value
df_d2 = df_d2.loc[:, ~df_d2.columns.str.contains('A')] # Select columns by string value
df_d2 = df_d2.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d2 = df_d2.select_dtypes(include = ['float64']) # Drop all unwanted data types
df_d2 = df_d2[df_d2 <= 100] # Susbet numeric column by condition
df_d2 = df_d2[df_d2 >= 0] # Susbet numeric column by condition
df_d2 = df_d2.dropna(axis = 1, thresh = 0.95*len(df_d2)) # Drop features less than 75% non-NA count for all columns
df_d2 = df_d2.reset_index() # Reset Index
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Table'] = df2 # Append string to all rows in column
df_l2.to_sql((df2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Zip Code Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Table']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((df2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Dataset 2, Table 4
d2_4 = 'Detailed Profile 5 (DP05) - Selected Economic Characteristics'
table = '_DP05'
feature = 'D2_T4_'
query = ("https://api.census.gov/data/2019/acs/acs5/profile?get=group(DP05)"
    "&for=zip%20code%20tabulation%20area"
    "&key=c82350b0bbe6c8a46ce163365ee3f2abcd16253e")

#### Pull Data from API (JSON)
df_d2 = pd.read_json(query)
df_d2.to_sql((df2 + table + '_raw'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Keep Values of Interest
df_d2.columns = df_d2.iloc[0] # Save first row as column names
df_d2 = df_d2.iloc[1:] # Remove first row
df_d2.columns.name = None # Remove label for column names
df_d2 = df_d2.set_index(['GEO_ID', 'state', 'zip code tabulation area', 'NAME']) # Drop Unwanted Columns
df_d2 = df_d2.loc[:, df_d2.columns.str.contains('PE')] # Select columns by string value
df_d2 = df_d2.loc[:, ~df_d2.columns.str.contains('A')] # Select columns by string value
df_d2 = df_d2.apply(pd.to_numeric, errors = "coerce") # Convert all columns to numeric
df_d2 = df_d2.select_dtypes(include = ['float64']) # Drop all unwanted data types
df_d2 = df_d2[df_d2 <= 100] # Susbet numeric column by condition
df_d2 = df_d2[df_d2 >= 0] # Susbet numeric column by condition
df_d2 = df_d2.dropna(axis = 1, thresh = 0.95*len(df_d2)) # Drop features less than 75% non-NA count for all columns
df_d2 = df_d2.reset_index() # Reset Index
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Standardized labels
df_l2 = pd.DataFrame(df_d2.columns) # Save as Pandas dataframe
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.reset_index() # Reset Index
df_l2 = df_l2.set_axis(['Description', 'Feature', 'Label'], axis = 1)
df_l2 = df_l2.astype('str') # Change data type of column in data frame
df_l2['Feature'] = feature + df_l2['Feature'] # Append string to all rows in column
df_l2['Table'] = df2 # Append string to all rows in column
df_l2.to_sql((df2 + table + '_labels'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_l2.head() # Print first 5 observations
df_l2.info() # Get class, memory, and column info: names, data types, obs.

#### Create Zip Code Standard Column Names
df_d2['NAME'] = df_d2['NAME'].astype('str') # Change data type of column in data frame
df_d2['NAME'] = df_d2['NAME'].str.replace('5 ', '') # Remove all spaces in column
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2 =  df_d2.rename(columns = {'index': 'Label'}) # Rename multiple columns in place
df_d2 = pd.merge(df_l2, df_d2, on = "Label", how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = df_d2.drop(columns = ['Label', 'Table']) # Drop Unwanted Columns
df_d2 = df_d2.set_index('Feature') # Set column as index
df_d2 = df_d2.transpose() # Transpose Rows and Columns
df_d2 = df_d2.rename(columns = {(feature + '3'): 'ZCTA'}) # Rename multiple columns in place
df_d2 = df_d2.set_index('ZCTA') # Set column as index
df_d2 = df_d2.drop(columns = [(feature + '0'), (feature + '1'), (feature + '2')]) # Drop Unwanted Columns
df_d2.columns.name = None
df_d2 = df_d2.reset_index() # Set observatyion label column as index
df_d2.to_sql((df2 + table + '_stage'), con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Merge SQLite tables
df_d2_1 = pd.read_sql_query('SELECT * FROM ' + df2 + '_DP02_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2_2 = pd.read_sql_query('SELECT * FROM ' + df2 + '_DP03_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2_3 = pd.read_sql_query('SELECT * FROM ' + df2 + '_DP04_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2_4 = pd.read_sql_query('SELECT * FROM ' + df2 + '_DP05_stage', con_1) # Read table from SQlite db file into pandas dataframe
df_d2 = pd.merge(df_d2_1, df_d2_2, on = 'ZCTA', how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = pd.merge(df_d2, df_d2_3, on = 'ZCTA', how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2 = pd.merge(df_d2, df_d2_4, on = 'ZCTA', how = "inner") # Join by column while keeping only items that exist in both, select outer or left for other options
df_d2.to_sql(df2, con_1, if_exists = 'replace', index = False) # Export data farme to SQl table
df_d2.head() # Print first 5 observations
df_d2.info() # Get class, memory, and column info: names, data types, obs.

### Merge SQLite label tables and Export
df_l2_1 = pd.read_sql_query('SELECT * FROM ' + df2 + '_DP02_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2_2 = pd.read_sql_query('SELECT * FROM ' + df2 + '_DP03_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2_3 = pd.read_sql_query('SELECT * FROM ' + df2 + '_DP04_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2_4 = pd.read_sql_query('SELECT * FROM ' + df2 + '_DP05_labels', con_1) # Read table from SQlite db file into pandas dataframe
df_l2 = pd.concat([df_l2_1, df_l2_2]) # Combine rows with same columns
df_l2 = pd.concat([df_l2, df_l2_3]) # Combine rows with same columns
df_l2 = pd.concat([df_l2, df_l2_4]) # Combine rows with same columns
df_l2.head()

### Copy descripton file from healthy neighborhoods
os.popen('cp ' + path + 'healthy-neighborhoods/release_2020/labels/acs_labels.csv ' + '_label/' + df2 + '_desc.csv')
df_l2_desc = pd.read_csv('_label/' + df2 + '_desc.csv') # Import dataset saved as csv in _data folder
df_l2_desc =  df_l2_desc.rename(columns = {"Feature": "Label", "Label": "Description"}) # Rename multiple columns in place
df_l2_desc = pd.merge(df_l2, df_l2_desc, on = 'Label', how = 'inner')
df_l2_desc['Table'] = df2
df_l2_desc['Description'] = df_l2_desc['Description'].str.replace("Percent Estimate!!","") # Strip all spaces from column in data frame
df_l2_desc['Description'] = df_l2_desc['Description'].str.replace("!!"," ") # Strip all spaces from column in data frame
df_l2_desc['Description'] = df_l2_desc['Description'].str.title() # Strip all spaces from column in data frame
df_l2_desc.to_csv(path_or_buf = '_label/' + df2 + '.csv', index = False) # Clean in excel and select variable
os.remove('_label/' + df2 + '_desc.csv') # Delete original Zip folder
df_l2_desc.head() # Print first 5 observations
df_l2_desc.info() # Get class, memory, and column info: names, data types, obs.

### Clean SQLite database and memory
cur_1.execute('DROP TABLE ' + df2 + '_DP02_labels;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP03_labels;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP04_labels;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP05_labels;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP02_stage;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP03_stage;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP04_stage;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP05_stage;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP02_raw;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP03_raw;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP04_raw;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
cur_1.execute('DROP TABLE ' + df2 + '_DP05_raw;') # Drop single table `_label` and `_staged` data, keep `_raw` tables
df_d2_1 = 0 # Delete variable from memory
df_d2_2 = 0 # Delete variable from memory
df_d2_3 = 0 # Delete variable from memory
df_d2_4 = 0 # Delete variable from memory
df_l2_1 = 0 # Delete variable from memory
df_l2_2 = 0 # Delete variable from memory
df_l2_3 = 0 # Delete variable from memory
df_l2_4 = 0 # Delete variable from memory

### Append step 2 results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('Data Step 2: ' + ds2 + '\n\n') # Step description
text_file.write('Dataset: ' + dd2 + '\n') # Dataset description
text_file.write('URL: ' + dr2 + '\n') # Dataset description
text_file.write('Table: ' + df2 + '\n') # Dataset description
text_file.write('Observations and variables: ' + str(df_d2.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_d2.head()) + '\n\n') # Print first 6 rows of dataframe in summary file
text_file.write(str(df_l2.head()) + '\n\n') # Print first 6 rows of dataframe in summary file
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file
text_file = open('summary.txt') # Write new corresponding text file
summary = text_file.read() # Close file
print(summary)
text_file.close() # Close file

## Step 3: Import 3rd Dataset from URL and Extract
ds3 = 'Import 3rd Dataset from URL and Extract' # Step 3 descriptive title
dd3 = 'Dataset: HRSA Area health Resource File' # Step 3 dataset description
df3 = 'HRSA_AHRF_2019_FIPS' # Dataset 2 file label
dr3 = 'https://data.hrsa.gov/DataDownload/AHRF/AHRF_2019-2020.ZIP' # ASCII Format

### Get Dataset as Zip file from URL address, query 1
file_name, headers = urllib.request.urlretrieve(dr3, directory + '_data/' + df3 + '.zip') # Get file from url and save at location
with ZipFile(directory + '_data/' + df3 + '.zip', 'r') as zip_1: 
    zip_1.extractall(directory + '_data/' + df3) # Extract all the contents of zip file in current directory
os.remove(directory + '_data/' + df3 + '.zip') # Delete original Zip folder

### Manually Copy from hnb_2020
os.popen('cp ' + path + 'healthy-neighborhoods/release_2020/ahrf_5Y2018_FIPS.csv ' + '_data/' + df3 + '.csv')
os.popen('cp ' + path + 'healthy-neighborhoods/release_2020/labels/ahrf_labels.csv ' + '_label/' + df3 + '.csv')
df_d3 = pd.read_csv('_data/' + df3 + '.csv') # Import dataset saved as csv in _data folder
df_l3 = pd.read_csv('_label/' + df3 + '.csv') # Import dataset saved as csv in _data folder
df_l3 = df_l3.reset_index()
df_l3 =  df_l3.rename(columns = {'index': 'Feature', 'Code': 'Label', 'Label': 'Description'}) # Rename multiple columns in place
df_l3['Feature'] = 'D3_' + df_l3['Feature'].astype('str')
df_l3['Table'] = df3
df_l3.to_csv(path_or_buf = '_label/' + df3 + '.csv', index = False) # Clean in excel and select variable
df_l3.head()

### Append step 3 results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('Data Step 3: ' + ds3 + '\n\n') # Step description
text_file.write('Dataset: ' + dd3 + '\n') # Dataset description
text_file.write('URL: ' + dr3 + '\n') # Dataset description
text_file.write('Table: ' + df3 + '\n') # Dataset description
text_file.write('Observations and variables: ' + str(df_d3.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_d3.head()) + '\n\n') # Print first 6 rows of dataframe in summary file
text_file.write(str(df_l3.head()) + '\n\n') # Print first 6 rows of dataframe in summary file
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file
text_file = open('summary.txt') # Write new corresponding text file
summary = text_file.read() # Close file
print(summary)
text_file.close() # Close file

## Data Step 4: Import 4th dataset from local file
ds4 = 'Pull and Clean Datasource from local file' # Step 1 descriptive title

### Import from local csv and keep values of interest
df_d4 = pd.read_csv(local + subject + DV_path) # Import dataset saved as csv in _data folder
df_d4 = df_d4.filter([DV, 'ZCTA']) # Keep selected columns
df_d4 = df_d4.rename(columns = {DV: 'count'}) # Rename multiple columns in place
df_d4.head() # Print first 5 observations
df_d4.info() # Get class, memory, and column info: names, data types, obs.

### Export to CSV
df_d4.to_csv(path_or_buf = '_data/' + DV_file + '.csv', index = False) # Clean in excel and select variable

### Append step 4 results to corresponding text file and check results
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('Data Step 4: ' + ds4 + '\n\n') # Step description
text_file.write('Reference: ' + reference + '\n') # Dataset description
text_file.write('Observations and variables: ' + str(df_d4.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_d4.head()) + '\n\n') # Result description and result dataframe
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file

## Shape Step 1: Import Zip Code Shapefile from URL and Extract
ss1 = 'Import Zip Code Geographies from Shapefile' # Step descriptive title
sd1 = 'CENSUS TIGER 2020 Shapefiles by Zip Code' # Step file description
sr1 = 'https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_zcta510_500k.zip' # Step download or reference url
sf1 = 'CENSUS_TIGER_2018_ZCTA' # Step file label

### Get Dataset as Zip file from URL address
file_name, headers = urllib.request.urlretrieve(sr1, directory + '_shape/' + sf1 + '.zip') # Get file from url and save at location
with ZipFile(directory + '_shape/' + sf1 + '.zip', 'r') as zip_1: 
    zip_1.extractall(directory + '_shape/' + sf1) # Extract all the contents of zip file in current directory
os.remove(directory + '_shape/' + sf1 + '.zip') # Delete original Zip folder

### Create Standard Zip Code Column Names
gdf_s1 = gp.read_file(directory + '_shape/' + sf1 + '/cb_2018_us_zcta510_500k.shp') # Import dataset saved as csv in _shape folder
gdf_s1['ZCTA'] = gdf_s1['ZCTA5CE10'].astype('str') # Change data type of column in data frame
gdf_s1['ZCTA'] = gdf_s1['ZCTA'].str.rjust(5, '0') # add leading zeros of character column using rjust() function
gdf_s1['ZCTA'] = 'ZCTA' + gdf_s1['ZCTA']
gdf_s1 = gdf_s1.filter(['ZCTA', 'geometry']) # Keep only selected columns
gdf_s1.info() # Get class, memory, and column info: names, data types, obs.

### Create centroids
gdf_s1['x'] = gdf_s1['geometry'].centroid.x # Save centroid coordinates as separate column
gdf_s1['y'] = gdf_s1['geometry'].centroid.y # Save centroid coordinates as separate column
gdf_s1['coordinates'] = list(zip(gdf_s1['x'], gdf_s1['y'])) # Save individual coordinates as column of paired list
gdf_s1 = gdf_s1.drop(columns = ['x', 'y']) # Drop Unwanted Columns
gdf_s1.head() # Get class, memory, and column info: names, data types, obs.
gdf_s1.info() # Get class, memory, and column info: names, data types, obs.

### Export to csv
gdf_s1.to_csv(path_or_buf = '_data/' + sf1 + '.csv', index = False) # Clean in excel and select variable

### Append step 1 results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('Shape Step 1: ' + ss1 + '\n\n') # Step description
text_file.write('Dataset: ' + sd1 + '\n') # Dataset description
text_file.write('URL: ' + sr1 + '\n') # Dataset description
text_file.write('Table: ' + sf1 + '\n') # Dataset description
text_file.write('Observations and variables: ' + str(gdf_s1.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(gdf_s1.head()) + '\n\n') # Print first 6 rows of dataframe in summary file
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file
text_file = open('summary.txt') # Write new corresponding text file
summary = text_file.read() # Close file
print(summary)
text_file.close() # Close file

## Shape Step 2: Import County Shapefile from URL and Extract
ss2 = 'Import County Geographies from Shapefile' # Step descriptive title
sd2 = 'CENSUS TIGER 2020 Shapefiles by County' # Step file description
sr2 = 'https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip' # Step download or reference url
sf2 = 'CENSUS_TIGER_2018_FIPS' # Step file label

### Get Dataset as Zip file from URL address
file_name, headers = urllib.request.urlretrieve(sr2, directory + '_shape/' + sf2 + '.zip') # Get file from url and save at location
with ZipFile(directory + '_shape/' + sf2 + '.zip', 'r') as zip_1: 
    zip_1.extractall(directory + '_shape/' + sf2) # Extract all the contents of zip file in current directory
os.remove(directory + '_shape/' + sf2 + '.zip') # Delete original Zip folder

### Create Standard FIPS Column Names
gdf_s2 = gp.read_file(directory + '_shape/' + sf2 + '/tl_2020_us_county.shp') # Import dataset saved as csv in _shape folder
gdf_s2['FIPS'] = gdf_s2['STATEFP'].astype('str') + gdf_s2['COUNTYFP'].astype('str') # Change data type of column in data frame
gdf_s2['FIPS'] = gdf_s2['FIPS'].str.rjust(5, '0') # add leading zeros of character column using rjust() function
gdf_s2['FIPS'] = 'FIPS' + gdf_s2['FIPS'] # Add character string
gdf_s2 = gdf_s2.filter(['FIPS', 'geometry']) # Keep only selected columns
gdf_s2.head() # Get class, memory, and column info: names, data types, obs.
gdf_s2.info() # Get class, memory, and column info: names, data types, obs.

### Create centroids and export
gdf_s2['x'] = gdf_s2['geometry'].centroid.x # Save centroid coordinates as separate column
gdf_s2['y'] = gdf_s2['geometry'].centroid.y # Save centroid coordinates as separate column
gdf_s2['coordinates'] = list(zip(gdf_s2['x'], gdf_s2['y'])) # Save individual coordinates as column of paired list
gdf_s2 = gdf_s2.drop(columns = ['x', 'y']) # Drop Unwanted Columns
gdf_s2.head() # Get class, memory, and column info: names, data types, obs.
gdf_s2.info() # Get class, memory, and column info: names, data types, obs.

### Export to csv
gdf_s2.to_csv(path_or_buf = '_data/' + sf2 + '.csv', index = False) # Clean in excel and select variable

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('Shape Step 2: ' + ss2 + '\n\n') # Step description
text_file.write('Dataset: ' + sd2 + '\n') # Dataset description
text_file.write('URL: ' + sr2 + '\n') # Dataset description
text_file.write('Table: ' + sf2 + '\n') # Dataset description
text_file.write('Observations and variables: ' + str(gdf_s2.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(gdf_s2.head()) + '\n\n') # Print first 6 rows of dataframe in summary file
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file
text_file = open('summary.txt') # Write new corresponding text file
summary = text_file.read() # Close file
print(summary)
text_file.close() # Close file

## Shape Step 3: Import State Shapefile from URL and Extract
ss3 = 'Import State Geographies from Shapefile' # Step descriptive title
sd3 = 'CENSUS TIGER 2020 Shapefiles by State' # Step file description
sr3 = 'https://www2.census.gov/geo/tiger/TIGER2020/STATE/tl_2020_us_state.zip' # Step download or reference url
sf3 = 'CENSUS_TIGER_2018_ST' # Step file label

### Get Dataset as Zip file from URL address
file_name, headers = urllib.request.urlretrieve(sr3, directory + '_shape/' + sf3 + '.zip') # Get file from url and save at location
with ZipFile(directory + '_shape/' + sf3 + '.zip', 'r') as zip_1: 
    zip_1.extractall(directory + '_shape/' + sf3) # Extract all the contents of zip file in current directory
os.remove(directory + '_shape/' + sf3 + '.zip') # Delete original Zip folder

### Create Standard FIPS Column Names
gdf_s3 = gp.read_file(directory + '_shape/' + sf3 + '/tl_2020_us_state.shp') # Import dataset saved as csv in _shape folder
gdf_s3['ST'] = gdf_s3['STUSPS'].astype('str')# Change data type of column in data frame
gdf_s3 = gdf_s3.filter(['ST', 'geometry']) # Keep only selected columns
gdf_s3 = gdf_s3[gdf_s3.ST.isin(['PR', 'VI', 'MP', 'GU', 'AS']) == False] # Drop rows by condition
gdf_s3.head() # Get class, memory, and column info: names, data types, obs.
gdf_s3.info() # Get class, memory, and column info: names, data types, obs.

### Create centroids and export
gdf_s3['x'] = gdf_s3['geometry'].centroid.x # Save centroid coordinates as separate column
gdf_s3['y'] = gdf_s3['geometry'].centroid.y # Save centroid coordinates as separate column
gdf_s3['coordinates'] = list(zip(gdf_s3['x'], gdf_s3['y'])) # Save individual coordinates as column of paired list
gdf_s3 = gdf_s3.drop(columns = ['x', 'y']) # Drop Unwanted Columns
gdf_s3.head() # Get class, memory, and column info: names, data types, obs.
gdf_s3.info() # Get class, memory, and column info: names, data types, obs.

### Export to csv
gdf_s3.to_csv(path_or_buf = '_data/' + sf3 + '.csv', index = False) # Clean in excel and select variable

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('Shape Step 3: ' + ss3 + '\n\n') # Step description
text_file.write('Dataset: ' + sd3 + '\n') # Dataset description
text_file.write('URL: ' + sr3 + '\n') # Dataset description
text_file.write('Table: ' + sf3 + '\n') # Dataset description
text_file.write('Observations and variables: ' + str(gdf_s3.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(gdf_s3.head()) + '\n\n') # Print first 6 rows of dataframe in summary file
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file
text_file = open('summary.txt') # Write new corresponding text file
summary = text_file.read() # Close file
print(summary)
text_file.close() # Close file

## Shape Step 4: Import State, County, Zip Code crosswalk label file from kaggle API
ss4 = 'Import State, County, Zip Code crosswalk label file' # Step descriptive title
sr4 = 'zipcodes-county-fips-crosswalk' # Kaggle dataset name
sd4 = 'County/ZIP Crosswalk from Kaggle, HUD, and ACS' # Step file description
sf4 = 'FIPS_ZCTA' # Step file label

## Data for Democracy crosswalk
sr4a = 'https://www.kaggle.com/danofer/zipcodes-county-fips-crosswalk?select=ZIP-COUNTY-FIPS_2017-06.csv'
os.popen('kaggle datasets download -d danofer/zipcodes-county-fips-crosswalk')
with ZipFile(directory + sr4 + '.zip', 'r') as zip_1: 
    zip_1.extractall(directory + '_data/' + sf4) # Extract all the contents of zip file in current directory
df_D4D = pd.read_csv('_data/' + sf4 + '/ZIP-COUNTY-FIPS_2017-06.csv') # Import dataset saved as csv in _data folder
df_D4D['STCOUNTYFP'] = df_D4D['STCOUNTYFP'].astype("str") # Change data type of column in data frame
df_D4D['STCOUNTYFP'] = df_D4D['STCOUNTYFP'].str.rjust(5, "0") # add leading zeros of character column using rjust() function
df_D4D["FIPS"] = "FIPS"+ df_D4D['STCOUNTYFP'] # Combine string with column
df_D4D["Name"] = df_D4D["COUNTYNAME"] # Add single column
df_D4D["ST"] = df_D4D["STATE"] # Add single column
df_D4D = df_D4D[df_D4D.ST != "PR"] # Remove territories
df_D4D = df_D4D[df_D4D.ST != "GU"] # Remove territories
df_D4D = df_D4D[df_D4D.ST != "VI"] # Remove territories
df_D4D = df_D4D.filter(["FIPS", "ST", "Name", "STCOUNTYFP"]) # Keep only selected columns
df_D4D = df_D4D.drop_duplicates(keep = "first", inplace = False) # Drop all dupliacted values
df_D4D.info() # Get class, memory, and column info: names, data types, obs.
os.remove(directory + sr4 + '.zip') # Delete original Zip folder
df_D4D.head() # Print first 5 observations

### HUD API Query (CSV)
sr4b = 'https://www.huduser.gov/portal/datasets/usps_crosswalk.html'
query_s4 = ("https://" + hud_key) # Save API as query
df_HUD = pd.read_csv(query_d4) # Create data frame from APi query
df_HUD = pd.read_csv("/home/drewc/GitHub/_dev_allocativ/hnb_2021/crosswalk/HUD/ZIP_COUNTY_032020.csv") # Import dataset saved as csv in _data folder
df_HUD['ZIP'] = df_HUD['ZIP'].astype("str") # Change data type of column in data frame
df_HUD['STCOUNTYFP'] = df_HUD['COUNTY'].astype("str") # Change data type of column in data frame
df_HUD['ZIP'] = df_HUD['ZIP'].str.rjust(5, "0") # add leading zeros of character column using rjust() function
df_HUD['STCOUNTYFP'] = df_HUD['STCOUNTYFP'].str.rjust(5, "0") # add leading zeros of character column using rjust() function
df_HUD["ZCTA"] = "ZCTA"+ df_HUD['ZIP'] # Combine string with column
df_HUD["FIPS"] = "FIPS"+ df_HUD['STCOUNTYFP'] # Combine string with column
df_HUD = df_HUD.filter(["FIPS", "ZCTA", "TOT_RATIO", "ZIP"]) # Keep only selected columns
df_HUD = df_HUD.sort_values(by = ["ZCTA", "TOT_RATIO"], ascending = False) # Select Zip codes with max ratio
df_HUD = df_HUD.drop_duplicates(subset = "ZCTA", keep = "first", inplace = False) # Drop all dupliacted values
df_HUD = df_HUD.drop(columns = ["TOT_RATIO"]) # Drop Unwanted Columns
df_HUD.info() # Get class, memory, and column info: names, data types, obs.
df_HUD.head() # Print first 5 observations

## American Community Survey population data
query = ('https://api.census.gov/data/2019/acs/acs5/profile?get=DP02_0001E'
    '&for=zip%20code%20tabulation%20area'
    '&key=' + key_census) # Save API query
df_ACS = pd.read_json(query) # Pull Data from API (JSON)
df_ACS.columns = df_ACS.iloc[0] # Save first row as column names
df_ACS = df_ACS.iloc[1:] # Remove first row
df_ACS = df_ACS.rename(columns = {'zip code tabulation area':'ZCTA', 'DP02_0001E':'population'})
df_ACS['ZCTA'] = df_ACS['ZCTA'].astype('str') # Change data type of column in data frame
df_ACS['ZCTA'] = 'ZCTA' + df_ACS['ZCTA'] # Add ZCTA label
df_ACS = df_ACS.drop(columns = 'state') # Drop unwanted columns
df_ACS.head() # Verify

## Join HUD, D4D, and ACS population data
df_s4 = pd.merge(df_HUD, df_D4D, on = "FIPS", how = "left") # Join by column while keeping only items that exist in both, select outer or left for other options
df_s4 = pd.merge(df_s4, df_ACS, on = "ZCTA", how = "left") # Join by column while keeping only items that exist in both, select outer or left for other options
df_s4.head() # Verify

## Clean Labels
states = {'ST':  ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MS', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'],
        'State': ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming']
        } # Create pandas dataframe by hand by creating arrays of same lenght with lables and saving as object
df_states = pd.DataFrame(states, columns = ['ST','State']) # Create data frame in pandas
df_s4 = pd.merge(df_s4, df_states, on = "ST", how = "left") # Join by column while keeping only items that exist in both, select outer or left for other options
df_s4["County"] = df_s4["Name"] # Add new column based on existing
df_s4['Name'] = df_s4['Name'].str.replace(" County","") # Strip all spaces from column in data frame
df_s4['Name'] = df_s4['Name'].str.replace(" Parish","") # Strip all spaces from column in data frame
df_s4['Name'] = df_s4['Name'].str.replace(" City","") # Strip all spaces from column in data frame
df_s4['Name'] = df_s4['Name'].str.replace(" Census Area","") # Strip all spaces from column in data frame
df_s4['Name'] = df_s4['Name'].str.replace(" Borough","") # Strip all spaces from column in data frame
df_s4['Name'] = df_s4['Name'].str.replace(" and","") # Strip all spaces from column in data frame
df_s4['NAME'] = df_s4['Name'].str.upper() # Change column to uppercase
df_s4['COUNTY'] = df_s4['County'].str.upper() # Change column to uppercase
df_s4['STATE'] = df_s4['State'].str.upper() # Change column to uppercase
df_s4 = df_s4.reindex(sorted(df_s4.columns), axis=1) # order columns alphabetically
df_s4 =  df_s4.rename(columns = {'COUNTY_L':'County', 'NAME_L':'Name', 'STATE_L':'State'}) # Rename multiple columns in place
df_s4 = df_s4.drop_duplicates(subset = ['ZCTA']) # Drop duplicate ZCTA values
df_s4['population'] = df_s4['population'].fillna(0).astype(np.int64) # Remove NA and change to int64 zeros
df_s4['population'] = df_s4['population'].replace(to_replace = 0, value = 1) # Rapleace all unpopulated Zip codes with value of 1
df_s4 = df_s4.dropna(subset = ['ST']) # Define in which columns to look for missing values
df_s4.info() # Get class, memory, and column info: names, data types, obs.
df_s4.head() # Print first 5 observations

## Write to CSV
df_s4.to_csv(path_or_buf = '_data/FIPS_ZCTA.csv', index = False) # Clean in excel and select variable

### Append step results to corresponding text file
text_file = open('summary.txt', 'a') # Write new corresponding text file
text_file.write('Shape Step 4: ' + ss4 + '\n\n') # Step description
text_file.write('Dataset: ' + sd4 + '\n') # Dataset description
text_file.write('URL: ' + sr4a + '\n') # Dataset description
text_file.write('URL: ' + sr4b + '\n') # Dataset description
text_file.write('Table: ' + sf4 + '\n') # Dataset description
text_file.write('Observations and variables: ' + str(df_s4.shape) + '\n\n') # Result description and result dataframe
text_file.write(str(df_s4.head()) + '\n\n') # Print first 6 rows of dataframe in summary file
text_file.write('####################' + '\n\n') # Add section break for end of step
text_file.close() # Close file