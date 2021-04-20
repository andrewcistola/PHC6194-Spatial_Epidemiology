# allocativ 3001.2021.0002

# Map Step 1: Import Multi-Layer Data
mp1 = 'Map Step 1: Import and Clean Data'

### Import and Join Labels (W) with Predictors (X) and Outcomes (Y)
df_W = read.csv('_data/FIPS_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_X = read.csv('_data/_learn_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_Y = read.csv('_data/_spatial_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
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
head(sdf_WXYZ) #Verify
sdf_WXYZ # Show SpatialDataFrame

### Import and Join Labels (W2) with Predictors (X2) and Outcomes (Y2) for 2nd Layer
df_W2 = read.csv('_data/FIPS_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_W2$ZCTA <- df_W2$ZIP <- NULL # delete variables v3 and v5
df_W2a = aggregate(df_W2$population, by = list(FIPS = df_W2$FIPS), FUN = sum)
df_W2 = merge(df_W2, df_W2a, by = 'FIPS', how = 'inner') # Merge data frame into data slot in SpatialDataFrame
df_W2$population <- df_W2$x
df_W2$x <- NULL # delete variables v3 and v5
df_W2 = unique(df_W2)
df_X2 = read.csv('_data/_learn_FIPS.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_Y2 = read.csv('_data/_spatial_FIPS.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_WX2 = merge(df_W2, df_X2, by = 'FIPS', how = 'inner') # Merge data frame into data slot in SpatialDataFrame
df_WXY2 = merge(df_WX2, df_Y2, by = 'FIPS', how = 'inner') # Merge data frame into data slot in SpatialDataFrame
head(df_WXY2) # Verify

### Join with Shapes (Z2)
sdf_Z2 = readOGR(dsn = '_shape/CENSUS_TIGER_2018_FIPS', layer = 'tl_2020_us_county') # County shapefiles
sdf_Z2$FIPS = as.character(sdf_Z2$GEOID) # Convert numeric to character
sdf_Z2$FIPS = paste('FIPS', sdf_Z2$FIPS, sep = '') # Add character string to each value in column
library(sp) # Reimport sp library for merge() function
sdf_WXYZ2 = merge(sdf_Z2, df_WXY2, by = 'FIPS') # Merge data frame into data slot in SpatialDataFrame
sdf_WXYZ2 = sdf_WXYZ2[which(sdf_WXYZ2$ST == ST & sdf_WXYZ2$population >= 0), ]
head(sdf_WXYZ2) #Verify
sdf_WXYZ2 # Show SpatialDataFrame

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(mp1, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c('Selected States: ', states, '\n'), file = 'summary.txt', append = TRUE)
cat(c('Observations: ', nrow(df_WXY), '\n\n'), file = 'summary.txt', append = TRUE)
print(sdf_WXYZ)
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat(c('Observations (Layer 2): ', nrow(df_WXY2), '\n\n'), file = 'summary.txt', append = TRUE)
print(sdf_WXYZ2)
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()

## Map Step 2: Make State Maps
mp2 = 'Map Step 2: Make State Maps'

### Define State Layer
state = 'Florida' # State abbreviation for map focus

### Define ZCTA Layer
sdf <- sdf_WXYZ # Subset spatial data frame by variable above
data = sdf@data # Data slot from SpatialPolygonDataFrame using variable above
ZCTA = fortify(sdf, region = 'ZCTA') # Create fortified data object containing SpatialPolygons from SpatialPolygonDataFrame and variables above
names(ZCTA)[names(ZCTA) == 'id'] <- 'ZCTA' # Rename column in base R
fort = merge(ZCTA, data, by = 'ZCTA')
head(fort)

### Define County Layer
sdf_2 <- sdf_WXYZ2 # Subset spatial data frame by variable above
data_2 = sdf_2@data # Data slot from SpatialPolygonDataFrame using variable above
FIPS = fortify(sdf_2, region = 'FIPS') # Create fortified data object containing SpatialPolygons from SpatialPolygonDataFrame and variables above
names(FIPS)[names(FIPS) == 'id'] <- 'FIPS' # Rename column in base R
fort_2 = merge(FIPS, data_2, by = 'FIPS')
head(fort_2)

### Create Maps (traditional)
low = 'blue3' # Standard map colorscheme
mid = 'lightyellow' # Standard map colorscheme
high = 'red3' # Standard map colorscheme
na = 'white' # Standard map colorscheme
breaks = 9 # Standard map colorscheme
scheme = 'trad'

#### Crude Rate
rate = 'crude' # Column label for outcome of interest
col_rate = fort$crude # Column in SpatialPolygonDataFrame where outcome is located
median = median(col_rate, na.rm = TRUE)
desc_rate = 'per 1000'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort, 
            aes(fill = crude,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Standardized Mortality Ratio
rate = 'standardized' # Column label for outcome of interest
col_rate = fort$SMR # Column in SpatialPolygonDataFrame where outcome is located
desc_rate = 'Crude counts / Expected counts'
median = median(col_rate, na.rm = TRUE)
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort, 
            aes(fill = SMR,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Local Empirical Bayes Smoothed
rate = 'smoothed' # Column label for outcome of interest
col_rate = fort$bayes # Column in SpatialPolygonDataFrame where outcome is located
desc_rate = 'smoothed by population'
median = median(col_rate, na.rm = TRUE)
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort, 
            aes(fill = bayes,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Log transformed crude rate
rate = 'log' # Column label for outcome of interest
col_rate = fort$crude # Column in SpatialPolygonDataFrame where outcome is located
median = log(median(col_rate, na.rm = TRUE))
desc_rate = 'log per 1000'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort, 
            aes(fill = crude,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            trans = rate,
            breaks = waiver(),
            n.breaks = breaks,
            midpoint = median,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Local Health index
rate = 'health' # Column label for outcome of interest
col_rate = fort$health # Column in SpatialPolygonDataFrame where outcome is located
median = median(col_rate, na.rm = TRUE)
desc_rate = 'aggregate health index'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort, 
            aes(fill = health,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            breaks = waiver(),
            n.breaks = breaks,
            midpoint = median,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Local SDOH index
rate = 'social' # Column label for outcome of interest
col_rate = fort$social # Column in SpatialPolygonDataFrame where outcome is located
median = median(col_rate, na.rm = TRUE)
desc_rate = 'aggregate SDOH index'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort, 
            aes(fill = social,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            breaks = waiver(),
            n.breaks = breaks,
            midpoint = median,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Crude Rate (County)
rate = 'crude' # Column label for outcome of interest
col_rate = fort_2$crude # Column in SpatialPolygonDataFrame where outcome is located
median = median(col_rate, na.rm = TRUE)
desc_rate = 'per 1000'
layer = 'FIPS'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort_2, 
            aes(fill = crude,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_', layer, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Log transformed Crude Rate (County)
rate = 'log' # Column label for outcome of interest
col_rate = fort_2$crude # Column in SpatialPolygonDataFrame where outcome is located
median = log(median(col_rate, na.rm = TRUE))
desc_rate = 'log per 1000'
layer = 'FIPS'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort_2, 
            aes(fill = crude,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            trans = rate,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_', layer, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Standardized Mortality Ratio (County)
rate = 'standardized' # Column label for outcome of interest
col_rate = fort_2$SMR # Column in SpatialPolygonDataFrame where outcome is located
desc_rate = 'Crude counts / Expected counts'
median = median(col_rate, na.rm = TRUE)
layer = 'FIPS'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort_2, 
            aes(fill = SMR,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_', layer, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Local Empirical Bayes Smoothed (County)
rate = 'smoothed' # Column label for outcome of interest
col_rate = fort_2$bayes # Column in SpatialPolygonDataFrame where outcome is located
desc_rate = 'smoothed by population'
median = median(col_rate, na.rm = TRUE)
layer = 'FIPS'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort_2, 
            aes(fill = bayes,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_', layer, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### LISA Quadrants
rate = 'LISA' # Column label for outcome of interest
col_rate = fort_2$LISA # Column in SpatialPolygonDataFrame where outcome is located
median = median(col_rate, na.rm = TRUE)
desc_rate = 'hot/cold spots'
layer = 'FIPS'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort_2, 
            aes(fill = LISA,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_', layer, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Weighted Coefficients (County)
rate = 'GWR' # Column label for outcome of interest
col_rate = fort_2$GWR # Column in SpatialPolygonDataFrame where outcome is located
median = median(col_rate, na.rm = TRUE)
desc_rate = 'Impact of local health'
layer = 'FIPS'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort_2, 
            aes(fill = GWR,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_', layer, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

##### Gini Index (County)
rate = 'gini' # Column label for outcome of interest
col_rate = fort_2$gini # Column in SpatialPolygonDataFrame where outcome is located
median = median(col_rate, na.rm = TRUE)
desc_rate = 'level of unequal distribution among Zip Codes'
layer = 'FIPS'
base = ggplot() + 
        geom_polygon(
            data = fort_2, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = 'cyan',
            colour = NA,
            size = 0.1,
            alpha = 0.1,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        labs(
            title = paste(outcome, 'in', State, sep = " "),
            subtitle = paste('2019 ', rate, ' rate | ', author, ' | ', day, sep = ''),
            caption = paste(reference, 'Accessed:', day, fill = ' '),
            fill = desc_rate) +
        north(
            fort_2,
            scale = 0.1,
            symbol = 3, 
            location = 'bottomleft') +
        theme(
            text = element_text(family = 'Bookman'),
            plot.background = element_blank(),
            plot.title = element_text(size = 20),
            plot.subtitle = element_text(size = 10),
            plot.caption = element_text(size = 6),
            legend.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank()) 
layer1 = base +
        geom_polygon(
            data = fort_2, 
            aes(fill = gini,
                x = long, 
                y = lat, 
                group = group),
                alpha = 0.9,
                colour = 'darkslategray',
                size = 0.1) +
        geom_path() +
        coord_equal() +
        scale_fill_gradient2(
            low = low,
            mid = mid,
            high = high,
            na.value = na,
            midpoint = median,
            breaks = waiver(),
            n.breaks = breaks,
            guide = 'legend') +
        theme(
            legend.position = c(0.05, 0.25),
            legend.justification = c('left', 'bottom'),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
top = layer1 +
        geom_polygon(
            data = fort, 
            aes(
                x = long, 
                y = lat, 
                group = group),
            fill = NA,
            colour = 'gray10',
            size = 0.1,
            alpha = 0.9,
            show.legend = FALSE) + 
        geom_path() +
        coord_equal() +
        theme(
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title = element_blank(), 
            axis.text = element_blank(), 
            axis.ticks = element_blank())
ggsave(paste('_fig/', ST, '_', rate, '_', scheme, '_', layer, '_map.png', sep = ''), dpi = 1000) # Export ggplot to png file with variables above

### Create Maps (soft)
low = 'dodgerblue4' # Standard map colorscheme
mid = 'seashell' # Standard map colorscheme
high = 'tomato4' # Standard map colorscheme
na = 'white' # Standard map colorscheme
breaks = 9 # Standard map colorscheme
scheme = 'soft'

### Create Maps (bright)
low = 'turquoise2' # Standard map colorscheme
mid = 'snow' # Standard map colorscheme
high = 'deeppink2' # Standard map colorscheme
na = 'white' # Standard map colorscheme
breaks = 9 # Standard map colorscheme
scheme = 'bright'

### Create Maps (alternate)
low = 'chartreuse3' # Standard map colorscheme
mid = 'ivory' # Standard map colorscheme
high = 'magenta3' # Standard map colorscheme
na = 'white' # Standard map colorscheme
breaks = 9 # Standard map colorscheme
scheme = 'alternate'