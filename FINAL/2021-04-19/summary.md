####################

Title: Finding Equity- Ecological Determinants Associated with Public Health OutcomesEstimated Poor Mental Health Status
Author(s): Alyssa Berger, MPH; Andrew S. Cistola, MPH

Local Path: /home/drewc/GitHub/_dev_PHC6194/FINAL/2021-04-19/
Time Run: 2021-04-19 13:11:13.138484

####################

Data Step 1: Pull and Clean Datasource from API

Dataset: CDC PLACES 2020 Release by Zip Code
URL: https://www.cdc.gov/places/index.html
Table: CDC_PLACES_2019_ZCTA
Observations and variables: (32410, 28)

           D1_1  D1_2  D1_3  D1_4  D1_5  D1_6  D1_7  D1_8  D1_9  D1_10  D1_11  D1_12  D1_13  D1_14  D1_15  D1_16  D1_17  D1_18  D1_19  D1_20  D1_21  D1_22  D1_23  D1_24  D1_25  D1_26  D1_27  D1_28
ZCTA                                                                                                                                                                                                
ZCTA0       1.0   2.0   3.0   4.0   5.0   6.0   7.0   8.0   9.0   10.0   11.0   12.0   13.0   14.0   15.0   16.0   17.0   18.0   19.0   20.0   21.0   22.0   23.0   24.0   25.0   26.0   27.0   28.0
ZCTA01086   6.9   3.9  36.4   6.1  11.6   0.8  12.1  68.7   0.6   71.8   58.0    NaN    1.7    NaN    NaN   10.5   79.7    0.8    7.5    0.6   12.6    NaN   19.3   16.8    4.7   31.9    0.3    NaN
ZCTA04469  15.8   6.8  23.7   9.4  13.1   0.8  14.2  64.6   1.1   65.7   52.7   67.3    3.3    NaN    NaN   18.4   53.6    1.5    9.7    0.9   17.7   80.0   24.7   24.1    8.3   36.0    0.5    NaN
ZCTA06269  11.1   5.5  20.9   9.5  15.3   0.8  13.4  61.2   1.1   71.0   55.5   59.0    3.2    NaN    NaN   16.1   68.0    1.7    7.7    0.9   17.6   81.8   22.7   22.0    7.8   35.6    0.6    NaN
ZCTA08240  10.0   3.1  27.7   6.5  12.2   0.8  10.6  69.3   0.5   74.4   64.3    NaN    1.6    NaN    NaN    9.8   79.0    0.9    7.8    0.5   14.0    NaN   18.0   15.6    4.4   35.8    0.3    NaN

         index                               Description                Label
Feature                                                                      
D1_0         0                CDC_PLACES_2019_ZCTA_zcta5                zcta5
D1_1         1    CDC_PLACES_2019_ZCTA_access2_crudeprev    access2_crudeprev
D1_2         2  CDC_PLACES_2019_ZCTA_arthritis_crudeprev  arthritis_crudeprev
D1_3         3      CDC_PLACES_2019_ZCTA_binge_crudeprev      binge_crudeprev
D1_4         4     CDC_PLACES_2019_ZCTA_bphigh_crudeprev     bphigh_crudeprev

####################

Data Step 2: Import Second Dataset from API

Dataset: CENSUS ACS 2020 Release by Zip Code
URL: https://www.census.gov/programs-surveys/acs/
Table: CENSUS_ACS_2019_ZCTA
Observations and variables: (33120, 366)

        ZCTA  D2_T1_4  D2_T1_5  D2_T1_6  D2_T1_7  D2_T1_8  D2_T1_9  D2_T1_10  D2_T1_11  D2_T1_12  D2_T1_13  ...  D2_T4_70  D2_T4_71  D2_T4_72  D2_T4_73  D2_T4_74  D2_T4_75  D2_T4_76  D2_T4_77  D2_T4_78  D2_T4_79  D2_T4_80
0  ZCTA25245     58.5      6.8      0.0      0.0     15.6      0.0      15.6       4.4      25.9       0.0  ...     100.0       0.0       0.0       0.0       0.0       0.0       0.0       0.0       0.0      46.6      53.4
1  ZCTA25268     70.9     15.3      4.0      0.8     15.0      0.0       6.2       3.4      10.2       0.0  ...      99.3       0.0       0.0       0.0       0.0       0.0       0.7       0.0       0.7      51.7      48.3
2  ZCTA25286     49.6     24.8      4.2      0.0     21.5      0.0      21.5       8.3      24.6       2.3  ...      94.0       0.0       0.0       0.0       0.0       0.0       5.7       0.0       5.7      54.9      45.1
3  ZCTA25303     42.6     16.4      6.6      3.4     21.1      0.0      16.9       4.7      29.7       4.2  ...      82.9       9.2       1.4       3.4       0.0       0.0       1.8       0.0       1.8      50.0      50.0
4  ZCTA25311     30.0      9.6      8.1      3.0     24.9      0.6      21.7       4.6      37.0       8.8  ...      76.1      15.2       0.4       0.8       0.0       0.0       6.1       0.0       6.1      48.3      51.7

[5 rows x 366 columns]

                                     Description  Feature                     Label
0                    CENSUS_ACS_2019_ZCTA_GEO_ID  D2_T1_0                    GEO_ID
1                     CENSUS_ACS_2019_ZCTA_state  D2_T1_1                     state
2  CENSUS_ACS_2019_ZCTA_zip code tabulation area  D2_T1_2  zip code tabulation area
3                      CENSUS_ACS_2019_ZCTA_NAME  D2_T1_3                      NAME
4               CENSUS_ACS_2019_ZCTA_DP02_0002PE  D2_T1_4               DP02_0002PE

####################

Data Step 3: Import 3rd Dataset from URL and Extract

Dataset: Dataset: HRSA Area health Resource File
URL: https://data.hrsa.gov/DataDownload/AHRF/AHRF_2019-2020.ZIP
Table: HRSA_AHRF_2019_FIPS
Observations and variables: (3230, 1802)

        FIPS   AHRF0    AHRF1    AHRF2     AHRF3    AHRF4     AHRF5    AHRF6     AHRF7     AHRF8  ...  AHRF1791  AHRF1792    AHRF1793     AHRF1794     AHRF1795  AHRF1796  AHRF1797  AHRF1798  AHRF1799  AHRF1800
0  FIPS01001  143.50   222.75   360.75   3535.75   5425.5  10440.75  1826.00   2646.25   3945.25  ...       0.0       0.0   55.666667  1827.333333  1883.000000     773.8    5214.4    5988.2       0.0       0.0
1  FIPS01003  753.50  1082.50  1581.00  12663.00  18423.5  32668.75  8449.75  12215.00  17916.75  ...       0.0       0.0  257.666667  3694.333333  3952.000000    1646.4   18424.4   20070.8       0.0       0.0
2  FIPS01005  107.25   142.50   187.50   2788.50   3596.0   4849.50  1330.25   1754.50   2293.25  ...       0.0       0.0   51.000000   532.333333   583.333333     202.2    1814.2    2016.4       0.0       0.0
3  FIPS01007   64.00    93.75   138.75   1738.50   2487.0   3995.50   924.00   1264.50   1784.50  ...       0.0       0.0   59.333333   254.000000   313.333333      97.4    1151.8    1249.2       0.0       0.0
4  FIPS01009  266.00   378.75   574.00   4408.25   6264.0  11023.75  3094.50   4177.25   6052.75  ...       0.0       0.0   88.666667   697.333333   786.333333     282.0    4045.8    4327.6       0.0       0.0

[5 rows x 1802 columns]

    Code                            Label
0  AHRF0  # <19 no HlthIns <=138% Poverty
1  AHRF1  # <19 no HlthIns <=200% Poverty
2  AHRF2  # <19 no HlthIns <=400% Poverty
3  AHRF3   # <19 w/HlthIns <=138% Poverty
4  AHRF4   # <19 w/HlthIns <=200% Poverty

####################

Shape Step 1: Import Zip Code Geographies from Shapefile

Dataset: CENSUS TIGER 2020 Shapefiles by Zip Code
URL: https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_zcta510_500k.zip
Table: CENSUS_TIGER_2018_ZCTA
Observations and variables: (33144, 3)

        ZCTA                                           geometry                               coordinates
0  ZCTA36083  MULTIPOLYGON (((-85.63225 32.28098, -85.62439 ...  (-85.68244274220686, 32.388409979501596)
1  ZCTA35441  MULTIPOLYGON (((-87.83287 32.84437, -87.83184 ...    (-87.7386096018864, 32.85373564403455)
2  ZCTA35051  POLYGON ((-86.74384 33.25002, -86.73802 33.251...   (-86.61971303654754, 33.20546701153693)
3  ZCTA35121  POLYGON ((-86.58527 33.94743, -86.58033 33.948...   (-86.45527191805489, 33.94124559458578)
4  ZCTA35058  MULTIPOLYGON (((-86.87884 34.21196, -86.87649 ...   (-86.73787658126403, 34.23133826715403)

####################

Shape Step 2: Import County Geographies from Shapefile

Dataset: CENSUS TIGER 2020 Shapefiles by County
URL: https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip
Table: CENSUS_TIGER_2018_FIPS
Observations and variables: (3234, 3)

        FIPS                                           geometry                               coordinates
0  FIPS31039  POLYGON ((-97.01952 42.00410, -97.01952 42.004...   (-96.78740067156328, 41.91640371079448)
1  FIPS53069  POLYGON ((-123.43639 46.23820, -123.44759 46.2...  (-123.43346991362158, 46.29113381398982)
2  FIPS35011  POLYGON ((-104.56739 33.99757, -104.56772 33.9...  (-104.41195788796497, 34.34241351170314)
3  FIPS31109  POLYGON ((-96.91075 40.78494, -96.91075 40.790...   (-96.68775550398634, 40.78417354489708)
4  FIPS31129  POLYGON ((-98.27367 40.08940, -98.27367 40.089...    (-98.04718498967358, 40.1763796295172)

####################

Shape Step 3: Import County Geographies from Shapefile

Dataset: CENSUS TIGER 2020 Shapefiles by State
URL: https://www2.census.gov/geo/tiger/TIGER2020/STATE/tl_2020_us_state.zip
Table: CENSUS_TIGER_2018_ST
Observations and variables: (51, 3)

   ST                                           geometry                              coordinates
0  WV  POLYGON ((-81.74725 39.09538, -81.74635 39.096...  (-80.61370690003079, 38.64256702558467)
1  FL  MULTIPOLYGON (((-86.39964 30.22696, -86.40262 ...  (-82.54411004543114, 28.42368639073513)
2  IL  POLYGON ((-91.18529 40.63780, -91.17510 40.643...  (-89.14863407344605, 40.12420150697562)
3  MN  POLYGON ((-96.78438 46.63050, -96.78434 46.630...  (-94.19831452017695, 46.34937232504576)
4  MD  POLYGON ((-77.45881 39.22027, -77.45866 39.220...    (-76.687177335728, 38.94649395935605)

####################

Shape Step 4: Import State, County, Zip Code crosswalk label file

Dataset: County/ZIP Crosswalk from Kaggle, HUD, and ACS
URL: https://www.kaggle.com/danofer/zipcodes-county-fips-crosswalk?select=ZIP-COUNTY-FIPS_2017-06.csv
URL: https://www.huduser.gov/portal/datasets/usps_crosswalk.html
Table: FIPS_ZCTA
Observations and variables: (39273, 12)

                              COUNTY                             County       FIPS                   NAME                   Name  ST   STATE STCOUNTYFP   State       ZCTA    ZIP  population
0          WRANGELL CITY AND BOROUGH          Wrangell City and Borough  FIPS02275               WRANGELL               Wrangell  AK  ALASKA      02275  Alaska  ZCTA99929  99929        1027
1          KETCHIKAN GATEWAY BOROUGH          Ketchikan Gateway Borough  FIPS02130      KETCHIKAN GATEWAY      Ketchikan Gateway  AK  ALASKA      02130  Alaska  ZCTA99928  99928           1
2  PRINCE OF WALES-HYDER CENSUS AREA  Prince of Wales-Hyder Census Area  FIPS02198  PRINCE OF WALES-HYDER  Prince of Wales-Hyder  AK  ALASKA      02198  Alaska  ZCTA99927  99927           1
3  PRINCE OF WALES-HYDER CENSUS AREA  Prince of Wales-Hyder Census Area  FIPS02198  PRINCE OF WALES-HYDER  Prince of Wales-Hyder  AK  ALASKA      02198  Alaska  ZCTA99926  99926         487
4  PRINCE OF WALES-HYDER CENSUS AREA  Prince of Wales-Hyder Census Area  FIPS02198  PRINCE OF WALES-HYDER  Prince of Wales-Hyder  AK  ALASKA      02198  Alaska  ZCTA99925  99925         317

####################

Spatial Step 1: Import and Clean Data 

Selected States:  FL 
Zip Code Observations:  32334 

class       : SpatialPolygonsDataFrame 
features    : 969 
extent      : -87.62587, -80.03136, 24.5231, 31.00089  (xmin, xmax, ymin, ymax)
crs         : +proj=longlat +datum=NAD83 +no_defs 
variables   : 413
names       :      ZCTA, ZCTA5CE10,     AFFGEOID10, GEOID10,  ALAND10, AWATER10,            COUNTY,            County,      FIPS,       NAME,       Name, ST,   STATE, STCOUNTYFP,   State, ... 
min values  : ZCTA32003,     32003, 8600000US32003,   32003,  1006507,        0,    ALACHUA COUNTY,    Alachua County, FIPS12001,    ALACHUA,    Alachua, FL, FLORIDA,      12001, Florida, ... 
max values  : ZCTA34997,     34997, 8600000US34997,   34997, 99204437, 99681360, WASHINGTON COUNTY, Washington County, FIPS12133, WASHINGTON, Washington, FL, FLORIDA,      12133, Florida, ... 

#################### 

Spatial Step 2: Create Spatially Adjusted Outcomes 

Object of class SpatialPolygonsDataFrame
Coordinates:
        min       max
x -87.62587 -80.03136
y  24.52310  31.00089
Is projected: FALSE 
proj4string : [+proj=longlat +datum=NAD83 +no_defs]
Data attributes:
     count          crude            log             SMR            binary     
 Min.   :   0   Min.   :  0.0   Min.   :0.000   Min.   :0.000   Min.   :0.000  
 1st Qu.: 436   1st Qu.:128.0   1st Qu.:4.852   1st Qu.:0.888   1st Qu.:0.000  
 Median :1033   Median :149.0   Median :5.004   Median :1.034   Median :1.000  
 Mean   :1150   Mean   :146.8   Mean   :4.930   Mean   :1.019   Mean   :0.547  
 3rd Qu.:1672   3rd Qu.:167.0   3rd Qu.:5.118   3rd Qu.:1.157   3rd Qu.:1.000  
 Max.   :4534   Max.   :364.0   Max.   :5.897   Max.   :2.524   Max.   :1.000  
     bayes             scale        
 Min.   :0.07359   Min.   :-2.8646  
 1st Qu.:0.12908   1st Qu.:-0.7653  
 Median :0.14936   Median : 0.0406  
 Mean   :0.14803   Mean   : 0.0000  
 3rd Qu.:0.16606   3rd Qu.: 0.7168  
 Max.   :0.24535   Max.   : 4.0548  

count = Observed counts from Raw Data 
crude = Observed counts per 1000 residents from American Community Survey 
log = Transformed crude rates 
SMR = Ratio of observed counts to expected counts based on global population rate 
binary = Binary variable representing SMR above 1 

bayes = Local Empirical Bayes smoothed observed counts 

scale = Standard Scaled bayes rate 

#################### 

Spatial Step 3: Test for Spatial Autocorrelation 

Morans I and LISA weights using Queens Neighbors and Local Empirical Bayes smoothed counts  (Null = No Autocorrelation)
	Moran I test under randomisation

data:  Y  
weights: queen_W  n reduced by no-neighbour observations
  

Moran I statistic standard deviate = 27.255, p-value < 2.2e-16
alternative hypothesis: greater
sample estimates:
Moran I statistic       Expectation          Variance 
     0.5771101281     -0.0010341262      0.0004499595 


Geographic weighted regression 

  feature importance  variance      weight
1   D1_13 0.03519899 0.2529569 0.008903826
2   D1_16 0.21628018 0.1993310 0.043111351
3   D1_17 0.11094424 0.2149624 0.023848838
4   D1_18 0.02673441 0.2585582 0.006912401
5   D1_20 0.03359417 0.2377350 0.007986510
6   D1_21 0.05933519 0.2585305 0.015339958


	Spearman's rank correlation rho

data:  sdf_WXYZ$crude and sdf_WXYZ$health
S = 116135984, p-value = 1.559e-13
alternative hypothesis: true rho is not equal to 0
sample estimates:
      rho 
0.2341439 


Create composite indices from social variables
    feature  importance   variance       weight
1 D2_T1_100 0.018637402 0.05222475 0.0009733337
2 D2_T1_101 0.016034537 0.05120347 0.0008210239
3 D2_T1_103 0.016939330 0.04136792 0.0007007449
4 D2_T1_104 0.001876410 0.08633556 0.0001620009
5 D2_T1_105 0.019624877 0.10036321 0.0019696157
6  D2_T1_12 0.008818976 0.06738505 0.0005942672


	Spearman's rank correlation rho

data:  sdf_WXYZ$crude and sdf_WXYZ$social
S = 150894417, p-value = 0.8782
alternative hypothesis: true rho is not equal to 0
sample estimates:
        rho 
0.004930184 


   ***********************************************************************
   *                       Package   GWmodel                             *
   ***********************************************************************
   Program starts at: 2021-04-19 15:02:35 
   Call:
   gwr.basic(formula = bayes ~ 0 + social + health, data = sdf_WXYZ, 
    regression.points = RP, bw = fixed, kernel = "gaussian", 
    longlat = T, dMat = DM1)

   Dependent (y) variable:  bayes
   Independent variables:  social health
   Number of data points: 969
   ***********************************************************************
   *                    Results of Global Regression                     *
   ***********************************************************************

   Call:
    lm(formula = formula, data = data)

   Residuals:
      Min        1Q    Median        3Q       Max 
-0.110478 -0.016733  0.005593  0.024386  0.126238 

   Coefficients:
           Estimate Std. Error t value Pr(>|t|)    
   social 0.0051715  0.0003369   15.35   <2e-16 ***
   health 0.0214720  0.0006798   31.59   <2e-16 ***

   ---Significance stars
   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
   Residual standard error: 0.03088 on 967 degrees of freedom
   Multiple R-squared: 0.9578
   Adjusted R-squared: 0.9577 
   F-statistic: 1.097e+04 on 2 and 967 DF,  p-value: < 2.2e-16 
   ***Extra Diagnostic information
   Residual sum of squares: 0.9219345
   Sigma(hat): 0.03087712
   AIC:  -3985.959
   AICc:  -3985.934
   BIC:  -4919.701
   ***********************************************************************
   *          Results of Geographically Weighted Regression              *
   ***********************************************************************

   *********************Model calibration information*********************
   Kernel function: gaussian 
   Fixed bandwidth: 839.1383 
   Regression points: A seperate set of regression points is used.
   Distance metric: A distance matrix is specified for this model calibration.

   ****************Summary of GWR coefficient estimates:******************
               Min.   1st Qu.    Median   3rd Qu.   Max.
   social 0.0051715 0.0051715 0.0051715 0.0051715 0.0052
   health 0.0214720 0.0214720 0.0214720 0.0214720 0.0215

   ***********************************************************************
   Program stops at: 2021-04-19 15:02:35 

     crude             SMR             bayes             LISA         
 Min.   :     0   Min.   :0.8543   Min.   :0.1236   Min.   :-0.11111  
 1st Qu.:  5631   1st Qu.:0.9813   1st Qu.:0.1465   1st Qu.: 0.00000  
 Median : 20863   Median :1.0744   Median :0.1554   Median : 0.05556  
 Mean   : 53433   Mean   :1.0827   Mean   :0.1575   Mean   : 0.28104  
 3rd Qu.: 53186   3rd Qu.:1.1873   3rd Qu.:0.1717   3rd Qu.: 0.50000  
 Max.   :437700   Max.   :1.3509   Max.   :0.1891   Max.   : 1.00000  
      GWR             gini        
 Min.   :18.38   Min.   :0.00000  
 1st Qu.:18.90   1st Qu.:0.03220  
 Median :19.45   Median :0.05718  
 Mean   :19.70   Mean   :0.07135  
 3rd Qu.:20.12   3rd Qu.:0.09988  
 Max.   :22.87   Max.   :0.26038  

crude = crude rate per popualtion by County
SMR = Mean zip code SMR by County
bayes = Mean zip code bayes by County
LISA = Morans I and LISA weights using Queens Neighbors and Local Empirical Bayes smoothed counts 
GWR = Weighted Coefficients of health index using  Geographic weighted regression 
gini = Gini index of crude hospitalization rate among zip codes within counties 

#################### 

Model Step 1: Raw Data Processing and Feature Engineering

Target labels: Estimated Poor Mental Health Status
Target processing: nonNA

           crude
count  969.00000
mean   146.76161
std     31.37335
min      0.00000
25%    128.00000
50%    149.00000
75%    167.00000
max    364.00000

Features labels: ACS Percent Estimates
Feature processing: 75% nonNA, Median Imputed NA, Standard Scaled

Rows, Columns: (969, 365)

####################

Learn Step 2: Identify Predictors with Open Models

Models: Principal Component Analysis, Random Forests, Recursive feature Elimination

Values: Eigenvectors, Gini Impurity, Boolean
Thresholds: Mean, Mean, Cross Validation

     Feature     MaxEV      Gini  RFE
0   D2_T4_25  0.210860  0.004864    1
1   D2_T4_26  0.210850  0.004057    1
2   D2_T4_79  0.205998  0.006818    1
3   D2_T4_80  0.205988  0.006208    1
4    D2_T4_5  0.200350  0.005239    1
5   D2_T2_39  0.192170  0.002903    1
6   D2_T1_54  0.182097  0.003589    1
7   D2_T1_53  0.177174  0.003056    1
8   D2_T1_62  0.132856  0.038483    1
9   D2_T1_17  0.121708  0.005185    1
10  D2_T4_24  0.118089  0.004756    1
11  D2_T1_25  0.117429  0.018407    1
12  D2_T1_46  0.117190  0.012466    1
13  D2_T2_87  0.116755  0.005443    1
14  D2_T1_47  0.114413  0.078462    1
15  D2_T1_44  0.109276  0.017849    1
16  D2_T2_90  0.109059  0.010761    1
17  D2_T2_81  0.108828  0.011185    1
18  D2_T2_84  0.108472  0.142982    1
19  D2_T1_45  0.107227  0.034949    1
20  D2_T1_19  0.106374  0.003687    1

####################

Layer Step 1: Raw Data Processing and Feature Engineering (2nd Geographic Layer)

Target labels: Estimated Poor Mental Health Status
Target processing: nonNA

               crude        SMR      bayes       LISA        GWR       gini
count      67.000000  67.000000  67.000000  67.000000  67.000000  67.000000
mean    53432.809568   1.082730   0.157454   0.281042  19.704086   0.071349
std     86189.418643   0.127957   0.017064   0.368414   1.039968   0.053313
min         0.000000   0.854261   0.123638  -0.111111  18.376553   0.000000
25%      5630.780217   0.981261   0.146467   0.000000  18.899048   0.032198
50%     20862.837348   1.074371   0.155393   0.055556  19.445734   0.057176
75%     53186.345705   1.187328   0.171682   0.500000  20.123827   0.099884
max    437700.364756   1.350918   0.189054   1.000000  22.868148   0.260377

Features labels: AHRF Population Rates
Feature processing: 75% nonNA, Median Imputed NA, Standard Scaled

Rows, Columns: (67, 1733)

####################

Layer Step 2: Identify 2nd Layer Predictors

Models: Support Vector Machines

Values: Coefficients

             crude          SMR         bayes         LISA           GWR          gini         rank
count  1657.000000  1657.000000  1.657000e+03  1657.000000  1.657000e+03  1.657000e+03  1657.000000
mean      0.043389     0.001816  2.303743e-04     0.004653  1.878352e-02  7.439984e-04     0.069617
std       0.048226     0.002957  3.942110e-04     0.007281  3.228867e-02  1.036170e-03     0.065486
min       0.000033     0.000001  2.759548e-08     0.000014  2.995259e-07  1.292117e-07     0.001823
50%       0.029961     0.000902  1.035164e-04     0.002485  8.862733e-03  4.132879e-04     0.047977
75%       0.047043     0.001940  2.425661e-04     0.005496  1.897428e-02  8.686645e-04     0.083800
90%       0.094604     0.004293  5.344070e-04     0.010277  4.194480e-02  1.689746e-03     0.144689
95%       0.127887     0.006521  8.317276e-04     0.015735  6.986767e-02  2.508899e-03     0.192673
97.5%     0.176409     0.009179  1.387622e-03     0.021909  1.095423e-01  3.469645e-03     0.262932
max       0.481313     0.035541  4.020792e-03     0.104717  4.012154e-01  1.003450e-02     0.547850

County Features

0      AHRF101
1     AHRF1451
2     AHRF1421
3     AHRF1634
4      AHRF540
5     AHRF1746
6      AHRF919
7     AHRF1029
9      AHRF845
10     AHRF729
dtype: object

####################

Map Step 1: Import and Clean Data 

Observations:  969 

class       : SpatialPolygonsDataFrame 
features    : 969 
extent      : -87.62587, -80.03136, 24.5231, 31.00089  (xmin, xmax, ymin, ymax)
crs         : +proj=longlat +datum=NAD83 +no_defs 
variables   : 47
names       :      ZCTA, ZCTA5CE10,     AFFGEOID10, GEOID10,  ALAND10, AWATER10,            COUNTY,            County,      FIPS,       NAME,       Name, ST,   STATE, STCOUNTYFP,   State, ... 
min values  : ZCTA32003,     32003, 8600000US32003,   32003,  1006507,        0,    ALACHUA COUNTY,    Alachua County, FIPS12001,    ALACHUA,    Alachua, FL, FLORIDA,      12001, Florida, ... 
max values  : ZCTA34997,     34997, 8600000US34997,   34997, 99204437, 99681360, WASHINGTON COUNTY, Washington County, FIPS12133, WASHINGTON, Washington, FL, FLORIDA,      12133, Florida, ... 

Observations (Layer 2):  67 

class       : SpatialPolygonsDataFrame 
features    : 67 
extent      : -87.6349, -79.97431, 24.39631, 31.00097  (xmin, xmax, ymin, ymax)
crs         : +proj=longlat +datum=NAD83 +no_defs 
variables   : 43
names       :      FIPS, STATEFP, COUNTYFP, COUNTYNS, GEOID,     NAME.x,          NAMELSAD, LSAD, CLASSFP, MTFCC, CSAFP, CBSAFP, METDIVFP, FUNCSTAT,      ALAND, ... 
min values  : FIPS12001,      12,      001, 00293656, 12001,    Alachua,    Alachua County,   06,      H1, G4020,   163,  11580,    22744,        A, 1224975810, ... 
max values  : FIPS12133,      12,      133, 00308551, 12133, Washington, Washington County,   06,      H6, G4020,   426,  48100,    48424,        C,  905705571, ... 

#################### 

Model Step 1: Raw Data Processing and Feature Engineering

Zip Code model for Florida

   Outcome Descriptives: count    969.00000
mean     146.76161
std       31.37335
min        0.00000
25%      128.00000
50%      149.00000
75%      167.00000
max      364.00000
Name: crude, dtype: float64

   N Observations, N Predictors: (969, 22)

Index(['ZCTA', 'D2_T4_25', 'D2_T4_26', 'D2_T4_79', 'D2_T4_80', 'D2_T4_5',
       'D2_T2_39', 'D2_T1_54', 'D2_T1_53', 'D2_T1_62', 'D2_T1_17', 'D2_T4_24',
       'D2_T1_25', 'D2_T1_46', 'D2_T2_87', 'D2_T1_47', 'D2_T1_44', 'D2_T2_90',
       'D2_T2_81', 'D2_T2_84', 'D2_T1_45', 'D2_T1_19'],
      dtype='object')

County model for Florida

   Outcome Descriptives: count        67.000000
mean      53432.809568
std       86189.418643
min           0.000000
25%        5630.780217
50%       20862.837348
75%       53186.345705
max      437700.364756
Name: crude, dtype: float64

   N Observations, N Predictors: (3230, 11)

Index(['FIPS', 'AHRF101', 'AHRF1451', 'AHRF1421', 'AHRF1634', 'AHRF540',
       'AHRF1746', 'AHRF919', 'AHRF1029', 'AHRF845', 'AHRF729'],
      dtype='object')

####################

Model Step 2: Create Informative Preidction Model

Models: OLS Regression Model

Zip Code model

                                 OLS Regression Results                                
=======================================================================================
Dep. Variable:                  bayes   R-squared (uncentered):                   0.022
Model:                            OLS   Adj. R-squared (uncentered):              0.001
Method:                 Least Squares   F-statistic:                              1.056
Date:                Mon, 19 Apr 2021   Prob (F-statistic):                       0.392
Time:                        17:32:17   Log-Likelihood:                          473.23
No. Observations:                 969   AIC:                                     -906.5
Df Residuals:                     949   BIC:                                     -808.9
Df Model:                          20                                                  
Covariance Type:            nonrobust                                                  
==============================================================================
                 coef    std err          t      P>|t|      [0.025      0.975]
------------------------------------------------------------------------------
D2_T4_25      -0.2683      5.409     -0.050      0.960     -10.883      10.346
D2_T4_26      -0.2685      5.404     -0.050      0.960     -10.874      10.337
D2_T4_79      -0.2648      5.324     -0.050      0.960     -10.712      10.183
D2_T4_80      -0.2638      5.326     -0.050      0.961     -10.716      10.189
D2_T4_5        0.0018      0.017      0.106      0.915      -0.031       0.034
D2_T2_39       0.0019      0.006      0.343      0.732      -0.009       0.013
D2_T1_54       0.0104      0.042      0.249      0.804      -0.071       0.092
D2_T1_53       0.0079      0.042      0.187      0.851      -0.075       0.091
D2_T1_62       0.0055      0.008      0.720      0.472      -0.009       0.020
D2_T1_17      -0.0092      0.016     -0.584      0.559      -0.040       0.022
D2_T4_24       0.0042      0.017      0.246      0.806      -0.029       0.037
D2_T1_25      -0.0039      0.013     -0.310      0.757      -0.029       0.021
D2_T1_46      -0.0038      0.009     -0.419      0.675      -0.022       0.014
D2_T2_87      -0.0048      0.032     -0.151      0.880      -0.068       0.058
D2_T1_47      -0.1037      1.415     -0.073      0.942      -2.880       2.673
D2_T1_44       0.0527      0.802      0.066      0.948      -1.521       1.626
D2_T2_90       0.0082      0.028      0.297      0.767      -0.046       0.062
D2_T2_81      -0.0063      0.023     -0.275      0.783      -0.051       0.039
D2_T2_84       0.0062      0.039      0.157      0.875      -0.071       0.083
D2_T1_45       0.0453      0.693      0.065      0.948      -1.314       1.404
D2_T1_19       0.0021      0.013      0.168      0.866      -0.023       0.027
==============================================================================
Omnibus:                      138.080   Durbin-Watson:                   0.011
Prob(Omnibus):                  0.000   Jarque-Bera (JB):             1562.400
Skew:                          -0.161   Prob(JB):                         0.00
Kurtosis:                       9.212   Cond. No.                     1.22e+16
==============================================================================

Warnings:
[1] Standard Errors assume that the covariance matrix of the errors is correctly specified.
[2] The smallest eigenvalue is 4.67e-29. This might indicate that there are
strong multicollinearity problems or that the design matrix is singular.

County model

                                 OLS Regression Results                                
=======================================================================================
Dep. Variable:                  bayes   R-squared (uncentered):                   0.979
Model:                            OLS   Adj. R-squared (uncentered):              0.975
Method:                 Least Squares   F-statistic:                              266.8
Date:                Mon, 19 Apr 2021   Prob (F-statistic):                    4.83e-44
Time:                        17:32:17   Log-Likelihood:                          157.95
No. Observations:                  67   AIC:                                     -295.9
Df Residuals:                      57   BIC:                                     -273.9
Df Model:                          10                                                  
Covariance Type:            nonrobust                                                  
==============================================================================
                 coef    std err          t      P>|t|      [0.025      0.975]
------------------------------------------------------------------------------
AHRF101        0.0108      0.019      0.560      0.577      -0.028       0.050
AHRF1451      -0.0190      0.019     -0.986      0.328      -0.057       0.020
AHRF1421       0.0046      0.014      0.328      0.744      -0.023       0.033
AHRF1634       0.0015      0.007      0.217      0.829      -0.012       0.016
AHRF540       -0.0004      0.005     -0.066      0.947      -0.011       0.010
AHRF1746       0.0230      0.002      9.427      0.000       0.018       0.028
AHRF919        0.0110      0.009      1.296      0.200      -0.006       0.028
AHRF1029       0.0063      0.026      0.242      0.809      -0.046       0.059
AHRF845        0.0178      0.006      3.171      0.002       0.007       0.029
AHRF729        0.0042      0.007      0.585      0.561      -0.010       0.018
==============================================================================
Omnibus:                        1.112   Durbin-Watson:                   1.326
Prob(Omnibus):                  0.573   Jarque-Bera (JB):                0.733
Skew:                          -0.252   Prob(JB):                        0.693
Kurtosis:                       3.087   Cond. No.                         48.2
==============================================================================

Warnings:
[1] Standard Errors assume that the covariance matrix of the errors is correctly specified.

####################

Model Step 3: Predict Categorical targets with Artificial Neural Networks

Target labels: Top quartile of Estimated Poor Mental Health Status
Target processing: train, test random 50-50 split

Multi-Layer Perceptron
Layers: Dense, Dense, Activation
Functions: ReLU, ReLU, Sigmoid
All features: AUC = 0.8982718459904772, Epochs = 100
Selected Zip Code Features: AUC = 0.8708465662671174, Epochs = 100

####################

Stats Step 1: Import and Clean Data 

Selected States:  Florida 
Zip Code Observations:  969 
County Observations:  67 

       ZCTA          COUNTY          County      FIPS     NAME     Name ST
1 ZCTA32003     CLAY COUNTY     Clay County FIPS12019     CLAY     Clay FL
2 ZCTA32008 SUWANNEE COUNTY Suwannee County FIPS12121 SUWANNEE Suwannee FL
3 ZCTA32009   NASSAU COUNTY   Nassau County FIPS12089   NASSAU   Nassau FL
4 ZCTA32011   NASSAU COUNTY   Nassau County FIPS12089   NASSAU   Nassau FL
5 ZCTA32024 COLUMBIA COUNTY Columbia County FIPS12023 COLUMBIA Columbia FL
6 ZCTA32025 COLUMBIA COUNTY Columbia County FIPS12023 COLUMBIA Columbia FL
    STATE STCOUNTYFP   State   ZIP population    D2_T4_25    D2_T4_26
1 FLORIDA      12019 Florida 32003      10428 -0.12608428  0.12606211
2 FLORIDA      12121 Florida 32008       1949 -0.04707777  0.04705928
3 FLORIDA      12089 Florida 32009       1238  0.31635219 -0.31635378
4 FLORIDA      12089 Florida 32011       5374 -0.20509080  0.20506495
5 FLORIDA      12023 Florida 32024       6996 -0.29989861  0.29986836
6 FLORIDA      12023 Florida 32025       7756  1.40664206 -1.40659296
     D2_T4_79    D2_T4_80      D2_T4_5   D2_T2_39   D2_T1_54   D2_T1_53
1 -0.08009420  0.08007456 -0.004571386  0.2504145  0.2924404 -0.3107411
2 -0.03340604  0.03338849  0.131726233  0.1704596 -1.0016737  1.0468782
3  0.30897377 -0.30897604 -0.191980611 -0.1836263 -1.2798478  1.3538182
4 -0.12678236  0.12676064  0.216912245  0.3189473 -0.7718778  0.8461866
5 -0.20459595  0.20457076  0.250986649  1.0271193 -0.2034351  0.3031389
6  1.36723866 -1.36719367 -1.265324359  0.8215210  1.5260818 -1.4204473
    D2_T1_62    D2_T1_17    D2_T4_24   D2_T1_25    D2_T1_46      D2_T2_87
1 -0.2855446 -0.29677727 -0.33522426  1.1879470  1.16792965 -1.1064484817
2  1.4119566  0.08466161  0.05602453 -0.2187177 -0.49210248  0.0004509123
3  2.3765882 -0.85853270 -0.91810512  0.2809173  0.57769600 -0.8967201754
4  1.5184419 -0.62966938 -0.49491765  0.7344321 -0.14779952 -0.6287340064
5  1.3994289 -0.17194273 -0.21545423  0.3500975 -0.08631685 -0.6986434418
6  1.4307481 -0.46322332 -0.53484099 -1.3102281 -0.47980594  0.0820119202
    D2_T1_47   D2_T1_44   D2_T2_90    D2_T2_81    D2_T2_84   D2_T1_45
1  1.0967060  1.3465547 -0.9556261 -0.90334070 -1.13884179  0.6810849
2 -1.2029307 -1.2144896 -0.4521466 -0.39520916 -0.26131957 -1.0515110
3 -0.9992486 -0.8436597 -1.1959231 -1.07684903 -1.09603583 -1.0649419
4 -0.9138335 -0.9827209 -0.4178185 -0.32084844 -0.55025982 -0.7291675
5 -0.6904402 -0.6350678 -0.7954281 -0.75461927 -0.64657323 -0.6888746
6 -0.8612704 -0.8552481 -0.1546361  0.05095512 -0.03658827 -0.7694605
     D2_T1_19 count crude      log       SMR binary     bayes      scale
1  0.84276084  1345   129 4.859812 0.8951157      0 0.1319411 -0.6526764
2 -0.39233085   327   168 5.123964 1.1643776      1 0.1709114  0.9150608
3  0.54781357   193   156 5.049856 1.0819186      1 0.1665223  0.7355475
4  0.56624778   860   160 5.075174 1.1106027      1 0.1623874  0.5670762
5  0.03165585  1133   162 5.087596 1.1239268      1 0.1650389  0.6750357
6 -0.66884392  1287   166 5.111988 1.1515921      1 0.1657145  0.7025865
    health    social
1 6.036195  8.329167
2 5.153833 12.755133
3 3.122535  7.482960
4 4.202415  5.608201
5 5.801121  9.993551
6 4.978401 14.277930

       FIPS          COUNTY          County     NAME     Name ST   STATE
1 FIPS12001  ALACHUA COUNTY  Alachua County  ALACHUA  Alachua FL FLORIDA
2 FIPS12003    BAKER COUNTY    Baker County    BAKER    Baker FL FLORIDA
3 FIPS12005      BAY COUNTY      Bay County      BAY      Bay FL FLORIDA
4 FIPS12007 BRADFORD COUNTY Bradford County BRADFORD Bradford FL FLORIDA
5 FIPS12009  BREVARD COUNTY  Brevard County  BREVARD  Brevard FL FLORIDA
6 FIPS12011  BROWARD COUNTY  Broward County  BROWARD  Broward FL FLORIDA
  STCOUNTYFP   State population AHRF101 AHRF1451 AHRF1421 AHRF1634 AHRF540
1      12001 Florida      98503       0        0        1        0       0
2      12003 Florida       8523       0        0        0        1       0
3      12005 Florida      72103       0        0        0        0       0
4      12007 Florida       8034       0        0        0        0       0
5      12009 Florida     230624       0        0        0        1       0
6      12011 Florida     690080       0        0        0        0       1
  AHRF1746 AHRF919 AHRF1029 AHRF845 AHRF729      crude       SMR     bayes
1     4.20       0        0       2     2.0  33470.722 1.1098780 0.1616379
2     4.82       0        0       2     0.0   6741.754 1.2090561 0.1746108
3     4.94       0        0       2     0.0  28933.015 1.1483648 0.1676176
4     4.32       1        0       2     0.0   2399.796 0.9761902 0.1759148
5     5.14       0        0       2     0.0 111081.810 1.0148658 0.1447094
6     4.54       0        0       2     1.5 372108.151 0.9200067 0.1329202
       LISA      GWR       gini
1 0.3333333 19.58535 0.09252827
2 0.6666667 19.33690 0.01657106
3 0.4166667 18.64984 0.06444165
4 0.6000000 19.50408 0.24807966
5 0.0000000 20.37519 0.08369920
6 0.0000000 18.97574 0.09170789

#################### 

Stats Step 2: Test for OLS Assumptions 

OLS Assumption 0: Sampling (Random sample, observations > predictors, predictor is independent) 


Call:
lm(formula = F, data = D)

Residuals:
     Min       1Q   Median       3Q      Max 
-172.495   -6.177    0.749    7.817   88.406 

Coefficients: (1 not defined because of singularities)
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)   146.7616     0.5955 246.440  < 2e-16 ***
D2_T4_25    -3762.6001  1316.4309  -2.858 0.004354 ** 
D2_T4_26    -3766.5409  1315.8720  -2.862 0.004297 ** 
D2_T4_79       -4.4450     4.0320  -1.102 0.270557    
D2_T4_80            NA         NA      NA       NA    
D2_T4_5        11.1858     2.0479   5.462 6.01e-08 ***
D2_T2_39        5.4110     0.7001   7.729 2.76e-14 ***
D2_T1_54      -15.2722     5.1459  -2.968 0.003074 ** 
D2_T1_53      -15.6982     5.2016  -3.018 0.002613 ** 
D2_T1_62        5.4406     0.9371   5.806 8.72e-09 ***
D2_T1_17      -20.6784     1.9549 -10.578  < 2e-16 ***
D2_T4_24       13.2803     2.0945   6.341 3.54e-10 ***
D2_T1_25       -7.5403     1.5699  -4.803 1.82e-06 ***
D2_T1_46       -9.2242     1.1178  -8.252 5.16e-16 ***
D2_T2_87       -5.6184     3.9529  -1.421 0.155548    
D2_T1_47      454.4293   174.8248   2.599 0.009485 ** 
D2_T1_44     -263.5728    99.0727  -2.660 0.007937 ** 
D2_T2_90        6.7772     3.4147   1.985 0.047465 *  
D2_T2_81       -7.4533     2.8372  -2.627 0.008753 ** 
D2_T2_84        8.9315     4.8589   1.838 0.066350 .  
D2_T1_45     -227.4969    85.5644  -2.659 0.007975 ** 
D2_T1_19        6.0295     1.5641   3.855 0.000124 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 18.54 on 948 degrees of freedom
Multiple R-squared:  0.6581,	Adjusted R-squared:  0.6509 
F-statistic: 91.23 on 20 and 948 DF,  p-value: < 2.2e-16

OLS Assumption 1: Specification (Relationship between predictor and outcome is linear) 

	Rainbow test

data:  OLS
Rain = 2.3211, df1 = 485, df2 = 462, p-value < 2.2e-16

Significant = Non-linearity

OLS Assumption 2:  Normality (Errors are normal with a mean = 0) 

	Robust Jarque Bera Test

data:  resid(OLS)
X-squared = 146579, df = 2, p-value < 2.2e-16

Signficiant = Non-normal


	Anderson-Darling test of goodness-of-fit
	Null hypothesis: uniform distribution

data:  resid(OLS)
An = Inf, p-value = 6.192e-07

Signficiant = Non-normal

OLS Assumption 3: No Autocorrelation (Error terms are not correlated with each other) 

	Durbin-Watson test

data:  OLS
DW = 1.881, p-value = 0.7606
alternative hypothesis: true autocorrelation is greater than 0

Signficiant = Autocorrelation

OLS Assumption 4: Homoskedasticity (Error is even across observations) 

	studentized Breusch-Pagan test

data:  OLS
BP = 205.46, df = 20, p-value < 2.2e-16

Signficiant = Homoscedastic


	Goldfeld-Quandt test

data:  OLS
GQ = 0.78748, df1 = 463, df2 = 462, p-value = 0.9948
alternative hypothesis: variance increases from segment 1 to 2

Significant = Heteroscedastic



#################### 

Stats Step 3: Create Generalized Linear Models 

Generalized model for DV = scale, regression = linear 

Call:
glm(formula = F, family = gaussian(), data = D)

Deviance Residuals: 
     Min        1Q    Median        3Q       Max  
-3.00027  -0.23962  -0.03244   0.21965   2.13765  

Coefficients: (1 not defined because of singularities)
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)  3.511e-15  1.506e-02   0.000 1.000000    
D2_T4_25    -2.285e+01  3.329e+01  -0.686 0.492686    
D2_T4_26    -2.286e+01  3.328e+01  -0.687 0.492319    
D2_T4_79    -4.107e-02  1.020e-01  -0.403 0.687221    
D2_T4_80            NA         NA      NA       NA    
D2_T4_5      7.113e-02  5.179e-02   1.373 0.169953    
D2_T2_39     7.772e-02  1.771e-02   4.390 1.26e-05 ***
D2_T1_54     4.161e-01  1.301e-01   3.198 0.001431 ** 
D2_T1_53     3.153e-01  1.315e-01   2.397 0.016736 *  
D2_T1_62     2.228e-01  2.370e-02   9.403  < 2e-16 ***
D2_T1_17    -3.723e-01  4.944e-02  -7.532 1.17e-13 ***
D2_T4_24     1.773e-01  5.297e-02   3.347 0.000848 ***
D2_T1_25    -1.554e-01  3.970e-02  -3.914 9.74e-05 ***
D2_T1_46    -1.570e-01  2.827e-02  -5.553 3.64e-08 ***
D2_T2_87    -1.953e-01  9.996e-02  -1.954 0.051048 .  
D2_T1_47    -3.988e+00  4.421e+00  -0.902 0.367307    
D2_T1_44     2.019e+00  2.505e+00   0.806 0.420551    
D2_T2_90     3.238e-01  8.635e-02   3.749 0.000188 ***
D2_T2_81    -2.450e-01  7.175e-02  -3.414 0.000667 ***
D2_T2_84     2.505e-01  1.229e-01   2.038 0.041798 *  
D2_T1_45     1.743e+00  2.164e+00   0.805 0.420746    
D2_T1_19     8.328e-02  3.955e-02   2.106 0.035506 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for gaussian family taken to be 0.2197829)

    Null deviance: 968.00  on 968  degrees of freedom
Residual deviance: 208.35  on 948  degrees of freedom
AIC: 1304.5

Number of Fisher Scoring iterations: 2

Generalized model for DV = log, regression = linear 

Call:
glm(formula = F, family = gaussian(), data = D)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-4.7953  -0.0907   0.0276   0.1456   1.4399  

Coefficients: (1 not defined because of singularities)
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)    4.92998    0.01393 354.012  < 2e-16 ***
D2_T4_25    -103.02806   30.78395  -3.347 0.000850 ***
D2_T4_26    -103.13377   30.77088  -3.352 0.000835 ***
D2_T4_79      -0.07608    0.09429  -0.807 0.419919    
D2_T4_80            NA         NA      NA       NA    
D2_T4_5        0.26707    0.04789   5.577 3.19e-08 ***
D2_T2_39       0.08341    0.01637   5.095 4.22e-07 ***
D2_T1_54      -0.18254    0.12033  -1.517 0.129615    
D2_T1_53      -0.07952    0.12164  -0.654 0.513419    
D2_T1_62       0.05079    0.02191   2.318 0.020675 *  
D2_T1_17      -0.44304    0.04571  -9.692  < 2e-16 ***
D2_T4_24       0.38170    0.04898   7.793 1.71e-14 ***
D2_T1_25      -0.10043    0.03671  -2.736 0.006343 ** 
D2_T1_46      -0.16730    0.02614  -6.401 2.43e-10 ***
D2_T2_87       0.13291    0.09244   1.438 0.150793    
D2_T1_47      13.26565    4.08817   3.245 0.001216 ** 
D2_T1_44      -7.53831    2.31675  -3.254 0.001179 ** 
D2_T2_90       0.29363    0.07985   3.677 0.000249 ***
D2_T2_81      -0.13107    0.06635  -1.976 0.048498 *  
D2_T2_84      -0.30903    0.11362  -2.720 0.006652 ** 
D2_T1_45      -6.49547    2.00087  -3.246 0.001210 ** 
D2_T1_19       0.05214    0.03657   1.426 0.154313    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for gaussian family taken to be 0.1879221)

    Null deviance: 280.53  on 968  degrees of freedom
Residual deviance: 178.15  on 948  degrees of freedom
AIC: 1152.8

Number of Fisher Scoring iterations: 2

Generalized model for DV = binary, regression = logistic 

Call:
glm(formula = F, family = binomial(), data = D)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-4.1214  -0.2816   0.0364   0.3485   3.5514  

Coefficients: (1 not defined because of singularities)
              Estimate Std. Error z value Pr(>|z|)    
(Intercept)     0.4334     0.5691   0.761  0.44636    
D2_T4_25       36.0445 33884.2900   0.001  0.99915    
D2_T4_26       35.4499 33885.8649   0.001  0.99917    
D2_T4_79        0.1520     0.8532   0.178  0.85864    
D2_T4_80            NA         NA      NA       NA    
D2_T4_5         1.9037     0.4759   4.000 6.33e-05 ***
D2_T2_39        0.9201     0.1863   4.938 7.89e-07 ***
D2_T1_54       -2.1789     0.9633  -2.262  0.02370 *  
D2_T1_53       -2.8787     0.9737  -2.957  0.00311 ** 
D2_T1_62        0.9664     0.2046   4.724 2.31e-06 ***
D2_T1_17       -3.2534     0.4797  -6.783 1.18e-11 ***
D2_T4_24        2.1545     0.5218   4.129 3.64e-05 ***
D2_T1_25       -0.6770     0.3965  -1.708  0.08772 .  
D2_T1_46       -1.2080     0.2727  -4.430 9.42e-06 ***
D2_T2_87       -1.1970     0.8033  -1.490  0.13621    
D2_T1_47       36.4784    33.7345   1.081  0.27955    
D2_T1_44      -22.6221    19.1374  -1.182  0.23717    
D2_T2_90        1.5153     0.6484   2.337  0.01944 *  
D2_T2_81       -1.4661     0.5510  -2.661  0.00779 ** 
D2_T2_84        1.0075     1.0206   0.987  0.32357    
D2_T1_45      -18.6921    16.4944  -1.133  0.25711    
D2_T1_19        0.3950     0.4084   0.967  0.33341    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 1334.8  on 968  degrees of freedom
Residual deviance:  505.3  on 948  degrees of freedom
AIC: 547.3

Number of Fisher Scoring iterations: 12

Generalized model for DV = crude, regression = poisson 

Call:
glm(formula = F, family = poisson(), data = D)

Deviance Residuals: 
     Min        1Q    Median        3Q       Max  
-18.8515   -0.5172    0.0631    0.6638    6.9945  

Coefficients: (1 not defined because of singularities)
              Estimate Std. Error  z value Pr(>|z|)    
(Intercept)   4.973766   0.002692 1847.861  < 2e-16 ***
D2_T4_25    -22.161497   5.498600   -4.030 5.57e-05 ***
D2_T4_26    -22.187634   5.496132   -4.037 5.41e-05 ***
D2_T4_79     -0.030103   0.017437   -1.726   0.0843 .  
D2_T4_80            NA         NA       NA       NA    
D2_T4_5       0.077978   0.008762    8.899  < 2e-16 ***
D2_T2_39      0.035278   0.002970   11.878  < 2e-16 ***
D2_T1_54     -0.104890   0.023216   -4.518 6.24e-06 ***
D2_T1_53     -0.100049   0.023377   -4.280 1.87e-05 ***
D2_T1_62      0.031991   0.004084    7.833 4.77e-15 ***
D2_T1_17     -0.138217   0.008844  -15.628  < 2e-16 ***
D2_T4_24      0.081118   0.009670    8.389  < 2e-16 ***
D2_T1_25     -0.059511   0.006873   -8.659  < 2e-16 ***
D2_T1_46     -0.055504   0.004790  -11.588  < 2e-16 ***
D2_T2_87     -0.016900   0.016318   -1.036   0.3004    
D2_T1_47      3.241526   0.781832    4.146 3.38e-05 ***
D2_T1_44     -1.882906   0.443070   -4.250 2.14e-05 ***
D2_T2_90      0.067463   0.014141    4.771 1.83e-06 ***
D2_T2_81     -0.062723   0.012008   -5.223 1.76e-07 ***
D2_T2_84      0.023851   0.019698    1.211   0.2260    
D2_T1_45     -1.627547   0.382626   -4.254 2.10e-05 ***
D2_T1_19      0.042049   0.006809    6.175 6.60e-10 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for poisson family taken to be 1)

    Null deviance: 7902  on 968  degrees of freedom
Residual deviance: 3636  on 948  degrees of freedom
AIC: 10219

Number of Fisher Scoring iterations: 5

Generalized model for DV = crude, regression = negbinomial 

Call:
glm.nb(formula = F, data = D, init.theta = 46.35240214, link = log)

Deviance Residuals: 
     Min        1Q    Median        3Q       Max  
-12.0287   -0.2752    0.0296    0.3404    3.6887  

Coefficients: (1 not defined because of singularities)
              Estimate Std. Error z value Pr(>|z|)    
(Intercept)   4.973032   0.005434 915.145  < 2e-16 ***
D2_T4_25    -29.016431  11.806999  -2.458 0.013988 *  
D2_T4_26    -29.038630  11.801903  -2.461 0.013874 *  
D2_T4_79     -0.025613   0.036520  -0.701 0.483082    
D2_T4_80            NA         NA      NA       NA    
D2_T4_5       0.100952   0.018528   5.449 5.08e-08 ***
D2_T2_39      0.040336   0.006320   6.382 1.74e-10 ***
D2_T1_54     -0.104907   0.047174  -2.224 0.026160 *  
D2_T1_53     -0.092962   0.047625  -1.952 0.050944 .  
D2_T1_62      0.031521   0.008514   3.702 0.000214 ***
D2_T1_17     -0.165651   0.017972  -9.217  < 2e-16 ***
D2_T4_24      0.100033   0.019333   5.174 2.29e-07 ***
D2_T1_25     -0.073748   0.014315  -5.152 2.58e-07 ***
D2_T1_46     -0.066948   0.010142  -6.601 4.09e-11 ***
D2_T2_87      0.002707   0.035406   0.076 0.939066    
D2_T1_47      3.765062   1.595980   2.359 0.018320 *  
D2_T1_44     -2.181414   0.904428  -2.412 0.015868 *  
D2_T2_90      0.093608   0.030668   3.052 0.002271 ** 
D2_T2_81     -0.072135   0.025537  -2.825 0.004733 ** 
D2_T2_84     -0.015687   0.043496  -0.361 0.718358    
D2_T1_45     -1.882516   0.781118  -2.410 0.015951 *  
D2_T1_19      0.057771   0.014247   4.055 5.01e-05 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for Negative Binomial(46.3524) family taken to be 1)

    Null deviance: 2520.7  on 968  degrees of freedom
Residual deviance: 1447.7  on 948  degrees of freedom
AIC: 9401.4

Number of Fisher Scoring iterations: 1


              Theta:  46.35 
          Std. Err.:  3.55 

 2 x log-likelihood:  -9357.413 


#################### 

Stats Step 4: Hierarchical Linear Models 

Fixed-Effects Regression for County Variables 
DV =  crude 
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1183.8

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-10.9993  -0.2092   0.0464   0.3223   3.6032 

Random effects:
 Groups   Name        Variance Std.Dev.
 FIPS     (Intercept) 0.01336  0.1156  
 Residual             0.17808  0.4220  
Number of obs: 969, groups:  FIPS, 67

Fixed effects:
              Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)    4.94473    0.02265   26.62915 218.301  < 2e-16 ***
D2_T4_25    -107.63177   30.92968  900.57438  -3.480 0.000526 ***
D2_T4_26    -107.76986   30.91669  900.57525  -3.486 0.000514 ***
D2_T4_79      -0.09934    0.09393  935.92196  -1.058 0.290519    
D2_T4_5        0.27362    0.04719  923.34273   5.799 9.17e-09 ***
D2_T2_39       0.08955    0.01678  855.53405   5.337 1.21e-07 ***
D2_T1_54      -0.27330    0.12030  943.64296  -2.272 0.023315 *  
D2_T1_53      -0.16031    0.12107  937.96352  -1.324 0.185798    
D2_T1_62       0.05257    0.02347  525.34241   2.239 0.025543 *  
D2_T1_17      -0.43688    0.04611  947.40246  -9.475  < 2e-16 ***
D2_T4_24       0.37322    0.04880  942.06558   7.647 5.06e-14 ***
D2_T1_25      -0.10695    0.03646  939.86023  -2.934 0.003432 ** 
D2_T1_46      -0.19353    0.02683  929.73290  -7.214 1.13e-12 ***
D2_T2_87       0.11518    0.09152  936.50893   1.259 0.208509    
D2_T1_47      11.93549    4.03085  919.78278   2.961 0.003145 ** 
D2_T1_44      -6.77056    2.28413  919.66197  -2.964 0.003113 ** 
D2_T2_90       0.23734    0.07967  943.74432   2.979 0.002966 ** 
D2_T2_81      -0.08413    0.06657  947.92462  -1.264 0.206624    
D2_T2_84      -0.28483    0.11219  928.33897  -2.539 0.011283 *  
D2_T1_45      -5.82402    1.97290  919.87917  -2.952 0.003237 ** 
D2_T1_19       0.04323    0.03676  946.32762   1.176 0.239940    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1196

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.0618  -0.2093   0.0636   0.3358   3.3217 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF101  (Intercept) 0.0000   0.0000  
 Residual             0.1879   0.4335  
Number of obs: 969, groups:  AHRF101, 2

Fixed effects:
              Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)    4.92998    0.01393  948.00000 354.012  < 2e-16 ***
D2_T4_25    -103.02806   30.78395  948.00000  -3.347 0.000850 ***
D2_T4_26    -103.13377   30.77088  948.00000  -3.352 0.000835 ***
D2_T4_79      -0.07608    0.09429  948.00000  -0.807 0.419919    
D2_T4_5        0.26707    0.04789  948.00000   5.577 3.19e-08 ***
D2_T2_39       0.08341    0.01637  948.00000   5.095 4.22e-07 ***
D2_T1_54      -0.18254    0.12033  948.00000  -1.517 0.129615    
D2_T1_53      -0.07952    0.12164  948.00000  -0.654 0.513419    
D2_T1_62       0.05079    0.02191  948.00000   2.318 0.020675 *  
D2_T1_17      -0.44304    0.04571  948.00000  -9.692  < 2e-16 ***
D2_T4_24       0.38170    0.04898  948.00000   7.793 1.71e-14 ***
D2_T1_25      -0.10043    0.03671  948.00000  -2.736 0.006343 ** 
D2_T1_46      -0.16730    0.02614  948.00000  -6.401 2.43e-10 ***
D2_T2_87       0.13291    0.09244  948.00000   1.438 0.150793    
D2_T1_47      13.26565    4.08817  948.00000   3.245 0.001216 ** 
D2_T1_44      -7.53831    2.31675  948.00000  -3.254 0.001179 ** 
D2_T2_90       0.29363    0.07985  948.00000   3.677 0.000249 ***
D2_T2_81      -0.13107    0.06635  948.00000  -1.976 0.048498 *  
D2_T2_84      -0.30903    0.11362  948.00000  -2.720 0.006652 ** 
D2_T1_45      -6.49547    2.00087  948.00000  -3.246 0.001210 ** 
D2_T1_19       0.05214    0.03657  948.00000   1.426 0.154313    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
optimizer (nloptwrap) convergence code: 0 (OK)
boundary (singular) fit: see ?isSingular

Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1196

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.0618  -0.2093   0.0636   0.3358   3.3217 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF1451 (Intercept) 0.0000   0.0000  
 Residual             0.1879   0.4335  
Number of obs: 969, groups:  AHRF1451, 3

Fixed effects:
              Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)    4.92998    0.01393  948.00000 354.012  < 2e-16 ***
D2_T4_25    -103.02806   30.78395  948.00000  -3.347 0.000850 ***
D2_T4_26    -103.13377   30.77088  948.00000  -3.352 0.000835 ***
D2_T4_79      -0.07608    0.09429  948.00000  -0.807 0.419919    
D2_T4_5        0.26707    0.04789  948.00000   5.577 3.19e-08 ***
D2_T2_39       0.08341    0.01637  948.00000   5.095 4.22e-07 ***
D2_T1_54      -0.18254    0.12033  948.00000  -1.517 0.129615    
D2_T1_53      -0.07952    0.12164  948.00000  -0.654 0.513419    
D2_T1_62       0.05079    0.02191  948.00000   2.318 0.020675 *  
D2_T1_17      -0.44304    0.04571  948.00000  -9.692  < 2e-16 ***
D2_T4_24       0.38170    0.04898  948.00000   7.793 1.71e-14 ***
D2_T1_25      -0.10043    0.03671  948.00000  -2.736 0.006343 ** 
D2_T1_46      -0.16730    0.02614  948.00000  -6.401 2.43e-10 ***
D2_T2_87       0.13291    0.09244  948.00000   1.438 0.150793    
D2_T1_47      13.26565    4.08817  948.00000   3.245 0.001216 ** 
D2_T1_44      -7.53831    2.31675  948.00000  -3.254 0.001179 ** 
D2_T2_90       0.29363    0.07985  948.00000   3.677 0.000249 ***
D2_T2_81      -0.13107    0.06635  948.00000  -1.976 0.048498 *  
D2_T2_84      -0.30903    0.11362  948.00000  -2.720 0.006652 ** 
D2_T1_45      -6.49547    2.00087  948.00000  -3.246 0.001210 ** 
D2_T1_19       0.05214    0.03657  948.00000   1.426 0.154313    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
optimizer (nloptwrap) convergence code: 0 (OK)
boundary (singular) fit: see ?isSingular

Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1192.7

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.0965  -0.2182   0.0673   0.3339   3.3616 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF919  (Intercept) 0.0113   0.1063  
 Residual             0.1869   0.4323  
Number of obs: 969, groups:  AHRF919, 2

Fixed effects:
             Estimate Std. Error        df t value Pr(>|t|)    
(Intercept)   4.86994    0.08081   0.90595  60.261 0.015300 *  
D2_T4_25    -98.09492   30.77533 947.99258  -3.187 0.001482 ** 
D2_T4_26    -98.19722   30.76244 947.99292  -3.192 0.001459 ** 
D2_T4_79     -0.06862    0.09409 947.38917  -0.729 0.465953    
D2_T4_5       0.26718    0.04776 947.00101   5.595 2.90e-08 ***
D2_T2_39      0.08738    0.01642 946.93602   5.322 1.28e-07 ***
D2_T1_54     -0.19933    0.12023 947.89630  -1.658 0.097664 .  
D2_T1_53     -0.09514    0.12150 947.81860  -0.783 0.433796    
D2_T1_62      0.06569    0.02280 788.43947   2.880 0.004078 ** 
D2_T1_17     -0.44376    0.04559 947.01904  -9.734  < 2e-16 ***
D2_T4_24      0.38873    0.04894 947.92092   7.943 5.57e-15 ***
D2_T1_25     -0.09846    0.03662 947.19119  -2.689 0.007303 ** 
D2_T1_46     -0.17283    0.02618 947.69487  -6.602 6.75e-11 ***
D2_T2_87      0.11158    0.09265 947.28932   1.204 0.228776    
D2_T1_47     13.32334    4.07704 947.01768   3.268 0.001122 ** 
D2_T1_44     -7.56706    2.31043 947.01456  -3.275 0.001094 ** 
D2_T2_90      0.28453    0.07973 947.70127   3.569 0.000377 ***
D2_T2_81     -0.12432    0.06623 947.59193  -1.877 0.060820 .  
D2_T2_84     -0.28420    0.11383 947.57215  -2.497 0.012704 *  
D2_T1_45     -6.52553    1.99543 947.01952  -3.270 0.001113 ** 
D2_T1_19      0.05468    0.03649 947.30729   1.498 0.134379    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1188.5

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.2213  -0.2127   0.0668   0.3276   3.3043 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF1634 (Intercept) 0.005324 0.07297 
 Residual             0.185968 0.43124 
Number of obs: 969, groups:  AHRF1634, 2

Fixed effects:
             Estimate Std. Error        df t value Pr(>|t|)    
(Intercept)   4.92851    0.05343   0.94936  92.251  0.00860 ** 
D2_T4_25    -95.15994   30.72474 947.86522  -3.097  0.00201 ** 
D2_T4_26    -95.27259   30.71160 947.86480  -3.102  0.00198 ** 
D2_T4_79     -0.07580    0.09380 947.00025  -0.808  0.41920    
D2_T4_5       0.27229    0.04767 947.21641   5.712 1.49e-08 ***
D2_T2_39      0.08873    0.01637 947.99990   5.419 7.59e-08 ***
D2_T1_54     -0.21689    0.12020 947.95161  -1.804  0.07148 .  
D2_T1_53     -0.10834    0.12135 947.78678  -0.893  0.37220    
D2_T1_62      0.05599    0.02186 947.78898   2.561  0.01058 *  
D2_T1_17     -0.46018    0.04580 947.88620 -10.048  < 2e-16 ***
D2_T4_24      0.38842    0.04877 947.33037   7.964 4.74e-15 ***
D2_T1_25     -0.10850    0.03661 947.71317  -2.964  0.00312 ** 
D2_T1_46     -0.16793    0.02600 947.01263  -6.458 1.69e-10 ***
D2_T2_87      0.11657    0.09210 947.51090   1.266  0.20594    
D2_T1_47     13.20433    4.06691 947.00414   3.247  0.00121 ** 
D2_T1_44     -7.48717    2.30473 947.00917  -3.249  0.00120 ** 
D2_T2_90      0.27799    0.07959 947.60160   3.493  0.00050 ***
D2_T2_81     -0.11764    0.06614 947.63206  -1.779  0.07560 .  
D2_T2_84     -0.28872    0.11321 947.52010  -2.550  0.01092 *  
D2_T1_45     -6.46344    1.99047 947.00474  -3.247  0.00121 ** 
D2_T1_19      0.04640    0.03643 947.41777   1.274  0.20308    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1185.7

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.2780  -0.2010   0.0622   0.3280   3.3007 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF540  (Intercept) 0.006289 0.0793  
 Residual             0.184715 0.4298  
Number of obs: 969, groups:  AHRF540, 5

Fixed effects:
              Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)    4.88897    0.04075    3.68576 119.962 9.34e-08 ***
D2_T4_25    -105.71294   30.53600  944.61855  -3.462 0.000560 ***
D2_T4_26    -105.85007   30.52315  944.62224  -3.468 0.000548 ***
D2_T4_79      -0.10834    0.09389  946.11994  -1.154 0.248866    
D2_T4_5        0.27151    0.04751  944.62620   5.714 1.48e-08 ***
D2_T2_39       0.08216    0.01626  945.65042   5.052 5.26e-07 ***
D2_T1_54      -0.22837    0.12018  947.79562  -1.900 0.057697 .  
D2_T1_53      -0.11502    0.12128  947.96333  -0.948 0.343190    
D2_T1_62       0.03766    0.02214  933.86884   1.701 0.089291 .  
D2_T1_17      -0.44234    0.04577  947.13646  -9.665  < 2e-16 ***
D2_T4_24       0.36874    0.04892  947.51688   7.538 1.12e-13 ***
D2_T1_25      -0.10983    0.03652  946.60992  -3.007 0.002705 ** 
D2_T1_46      -0.18380    0.02649  918.25525  -6.937 7.53e-12 ***
D2_T2_87       0.13171    0.09179  945.48027   1.435 0.151649    
D2_T1_47      12.31153    4.06340  945.84914   3.030 0.002513 ** 
D2_T1_44      -6.98573    2.30284  945.85369  -3.034 0.002483 ** 
D2_T2_90       0.25607    0.07985  947.38060   3.207 0.001387 ** 
D2_T2_81      -0.09973    0.06642  945.80316  -1.501 0.133565    
D2_T2_84      -0.30352    0.11273  944.63414  -2.692 0.007218 ** 
D2_T1_45      -6.01274    1.98889  945.88324  -3.023 0.002569 ** 
D2_T1_19       0.04399    0.03649  947.85338   1.206 0.228242    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1192.7

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.0965  -0.2182   0.0673   0.3339   3.3616 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF919  (Intercept) 0.0113   0.1063  
 Residual             0.1869   0.4323  
Number of obs: 969, groups:  AHRF919, 2

Fixed effects:
             Estimate Std. Error        df t value Pr(>|t|)    
(Intercept)   4.86994    0.08081   0.90595  60.261 0.015300 *  
D2_T4_25    -98.09492   30.77533 947.99258  -3.187 0.001482 ** 
D2_T4_26    -98.19722   30.76244 947.99292  -3.192 0.001459 ** 
D2_T4_79     -0.06862    0.09409 947.38917  -0.729 0.465953    
D2_T4_5       0.26718    0.04776 947.00101   5.595 2.90e-08 ***
D2_T2_39      0.08738    0.01642 946.93602   5.322 1.28e-07 ***
D2_T1_54     -0.19933    0.12023 947.89630  -1.658 0.097664 .  
D2_T1_53     -0.09514    0.12150 947.81860  -0.783 0.433796    
D2_T1_62      0.06569    0.02280 788.43947   2.880 0.004078 ** 
D2_T1_17     -0.44376    0.04559 947.01904  -9.734  < 2e-16 ***
D2_T4_24      0.38873    0.04894 947.92092   7.943 5.57e-15 ***
D2_T1_25     -0.09846    0.03662 947.19119  -2.689 0.007303 ** 
D2_T1_46     -0.17283    0.02618 947.69487  -6.602 6.75e-11 ***
D2_T2_87      0.11158    0.09265 947.28932   1.204 0.228776    
D2_T1_47     13.32334    4.07704 947.01768   3.268 0.001122 ** 
D2_T1_44     -7.56706    2.31043 947.01456  -3.275 0.001094 ** 
D2_T2_90      0.28453    0.07973 947.70127   3.569 0.000377 ***
D2_T2_81     -0.12432    0.06623 947.59193  -1.877 0.060820 .  
D2_T2_84     -0.28420    0.11383 947.57215  -2.497 0.012704 *  
D2_T1_45     -6.52553    1.99543 947.01952  -3.270 0.001113 ** 
D2_T1_19      0.05468    0.03649 947.30729   1.498 0.134379    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1172

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.2496  -0.2200   0.0482   0.3342   3.9145 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF1029 (Intercept) 0.6558   0.8098  
 Residual             0.1826   0.4273  
Number of obs: 969, groups:  AHRF1029, 2

Fixed effects:
              Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)    4.37202    0.58247    0.99524   7.506 0.085059 .  
D2_T4_25    -106.62823   30.34936  947.10749  -3.513 0.000463 ***
D2_T4_26    -106.72550   30.33645  947.10737  -3.518 0.000455 ***
D2_T4_79      -0.06743    0.09295  947.02149  -0.725 0.468353    
D2_T4_5        0.26779    0.04720  947.00170   5.673 1.86e-08 ***
D2_T2_39       0.08170    0.01614  947.02714   5.062 4.98e-07 ***
D2_T1_54      -0.20282    0.11867  947.07011  -1.709 0.087755 .  
D2_T1_53      -0.10147    0.11996  947.08017  -0.846 0.397848    
D2_T1_62       0.06028    0.02167  947.41383   2.781 0.005523 ** 
D2_T1_17      -0.45163    0.04509  947.08991 -10.017  < 2e-16 ***
D2_T4_24       0.39105    0.04831  947.09260   8.095 1.75e-15 ***
D2_T1_25      -0.10321    0.03619  947.01477  -2.852 0.004440 ** 
D2_T1_46      -0.17033    0.02577  947.04187  -6.610 6.41e-11 ***
D2_T2_87       0.12726    0.09111  947.00951   1.397 0.162821    
D2_T1_47      11.93003    4.03739  947.24928   2.955 0.003205 ** 
D2_T1_44      -6.78310    2.28795  947.24825  -2.965 0.003106 ** 
D2_T2_90       0.29183    0.07870  947.00132   3.708 0.000221 ***
D2_T2_81      -0.12758    0.06540  947.00702  -1.951 0.051372 .  
D2_T2_84      -0.30608    0.11199  947.00195  -2.733 0.006393 ** 
D2_T1_45      -5.84426    1.97599  947.24752  -2.958 0.003177 ** 
D2_T1_19       0.06420    0.03612  947.25383   1.777 0.075848 .  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1196

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.0618  -0.2093   0.0636   0.3358   3.3217 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF845  (Intercept) 0.0000   0.0000  
 Residual             0.1879   0.4335  
Number of obs: 969, groups:  AHRF845, 3

Fixed effects:
              Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)    4.92998    0.01393  948.00000 354.012  < 2e-16 ***
D2_T4_25    -103.02806   30.78395  948.00000  -3.347 0.000850 ***
D2_T4_26    -103.13377   30.77088  948.00000  -3.352 0.000835 ***
D2_T4_79      -0.07608    0.09429  948.00000  -0.807 0.419919    
D2_T4_5        0.26707    0.04789  948.00000   5.577 3.19e-08 ***
D2_T2_39       0.08341    0.01637  948.00000   5.095 4.22e-07 ***
D2_T1_54      -0.18254    0.12033  948.00000  -1.517 0.129615    
D2_T1_53      -0.07952    0.12164  948.00000  -0.654 0.513419    
D2_T1_62       0.05079    0.02191  948.00000   2.318 0.020675 *  
D2_T1_17      -0.44304    0.04571  948.00000  -9.692  < 2e-16 ***
D2_T4_24       0.38170    0.04898  948.00000   7.793 1.71e-14 ***
D2_T1_25      -0.10043    0.03671  948.00000  -2.736 0.006343 ** 
D2_T1_46      -0.16730    0.02614  948.00000  -6.401 2.43e-10 ***
D2_T2_87       0.13291    0.09244  948.00000   1.438 0.150793    
D2_T1_47      13.26565    4.08817  948.00000   3.245 0.001216 ** 
D2_T1_44      -7.53831    2.31675  948.00000  -3.254 0.001179 ** 
D2_T2_90       0.29363    0.07985  948.00000   3.677 0.000249 ***
D2_T2_81      -0.13107    0.06635  948.00000  -1.976 0.048498 *  
D2_T2_84      -0.30903    0.11362  948.00000  -2.720 0.006652 ** 
D2_T1_45      -6.49547    2.00087  948.00000  -3.246 0.001210 ** 
D2_T1_19       0.05214    0.03657  948.00000   1.426 0.154313    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
optimizer (nloptwrap) convergence code: 0 (OK)
boundary (singular) fit: see ?isSingular

Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1194.9

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.0540  -0.2095   0.0600   0.3241   3.3174 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF1746 (Intercept) 0.001234 0.03512 
 Residual             0.187200 0.43267 
Number of obs: 969, groups:  AHRF1746, 4

Fixed effects:
              Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)    4.93470    0.02265    2.23619 217.853 6.95e-06 ***
D2_T4_25    -100.44263   30.76899  947.78257  -3.264 0.001136 ** 
D2_T4_26    -100.56107   30.75593  947.78105  -3.270 0.001116 ** 
D2_T4_79      -0.08481    0.09446  947.05146  -0.898 0.369547    
D2_T4_5        0.27015    0.04786  947.55338   5.645 2.18e-08 ***
D2_T2_39       0.08375    0.01650  918.46334   5.076 4.67e-07 ***
D2_T1_54      -0.18562    0.12016  945.90148  -1.545 0.122733    
D2_T1_53      -0.08082    0.12142  944.93163  -0.666 0.505783    
D2_T1_62       0.04554    0.02210  889.92392   2.060 0.039644 *  
D2_T1_17      -0.44421    0.04598  916.27558  -9.660  < 2e-16 ***
D2_T4_24       0.37945    0.04909  944.14742   7.730 2.75e-14 ***
D2_T1_25      -0.10188    0.03669  947.74802  -2.777 0.005603 ** 
D2_T1_46      -0.16799    0.02613  947.88107  -6.428 2.04e-10 ***
D2_T2_87       0.13353    0.09233  946.35914   1.446 0.148426    
D2_T1_47      13.37240    4.08127  945.33993   3.277 0.001089 ** 
D2_T1_44      -7.59869    2.31280  945.27901  -3.285 0.001056 ** 
D2_T2_90       0.28925    0.07988  947.97583   3.621 0.000309 ***
D2_T2_81      -0.12775    0.06644  946.92835  -1.923 0.054794 .  
D2_T2_84      -0.30993    0.11344  945.47887  -2.732 0.006410 ** 
D2_T1_45      -6.54409    1.99747  945.31068  -3.276 0.001090 ** 
D2_T1_19       0.05032    0.03653  946.59589   1.377 0.168740    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: F
   Data: 
D2[c(colnames(column_to_rownames(df_X, var = "ZCTA")), Y, colnames(df_X2))]

REML criterion at convergence: 1195.8

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-11.0915  -0.2038   0.0617   0.3329   3.3174 

Random effects:
 Groups   Name        Variance  Std.Dev.
 AHRF729  (Intercept) 0.0003874 0.01968 
 Residual             0.1876796 0.43322 
Number of obs: 969, groups:  AHRF729, 5

Fixed effects:
              Estimate Std. Error         df t value Pr(>|t|)    
(Intercept)    4.92472    0.01771    2.69586 278.072 4.35e-07 ***
D2_T4_25    -103.39017   30.76860  946.91347  -3.360 0.000810 ***
D2_T4_26    -103.50014   30.75561  946.92443  -3.365 0.000795 ***
D2_T4_79      -0.08048    0.09440  939.15499  -0.853 0.394095    
D2_T4_5        0.26712    0.04786  946.84400   5.581 3.12e-08 ***
D2_T2_39       0.08316    0.01637  947.99538   5.080 4.55e-07 ***
D2_T1_54      -0.18835    0.12049  935.83862  -1.563 0.118326    
D2_T1_53      -0.08350    0.12173  943.09528  -0.686 0.492929    
D2_T1_62       0.04838    0.02201  860.05378   2.198 0.028199 *  
D2_T1_17      -0.44185    0.04576  938.88994  -9.655  < 2e-16 ***
D2_T4_24       0.37883    0.04904  938.04606   7.724 2.88e-14 ***
D2_T1_25      -0.10025    0.03669  946.65631  -2.732 0.006410 ** 
D2_T1_46      -0.16869    0.02619  928.66990  -6.442 1.89e-10 ***
D2_T2_87       0.13598    0.09250  944.25682   1.470 0.141893    
D2_T1_47      13.22123    4.08633  947.09200   3.235 0.001256 ** 
D2_T1_44      -7.51235    2.31570  947.07242  -3.244 0.001219 ** 
D2_T2_90       0.29339    0.07983  947.88686   3.675 0.000251 ***
D2_T2_81      -0.13078    0.06634  947.99676  -1.971 0.048971 *  
D2_T2_84      -0.31171    0.11369  944.85019  -2.742 0.006228 ** 
D2_T1_45      -6.47119    1.99997  947.09758  -3.236 0.001256 ** 
D2_T1_19       0.04964    0.03665  922.29714   1.354 0.175976    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
fit warnings:
fixed-effect model matrix is rank deficient so dropping 1 column / coefficient

One Way ANOVA for MLE 
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF101)
              npar  logLik  AIC        LRT Df Pr(>Chisq)
<none>          23 -598.01 1242                         
(1 | AHRF101)   22 -598.01 1240 -9.002e-09  1          1
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF1451)
               npar  logLik  AIC        LRT Df Pr(>Chisq)
<none>           23 -598.01 1242                         
(1 | AHRF1451)   22 -598.01 1240 -9.002e-09  1          1
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF919)
              npar  logLik    AIC    LRT Df Pr(>Chisq)  
<none>          23 -596.33 1238.7                       
(1 | AHRF919)   22 -598.01 1240.0 3.3793  1    0.06602 .
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF1634)
               npar  logLik    AIC    LRT Df Pr(>Chisq)   
<none>           23 -594.26 1234.5                        
(1 | AHRF1634)   22 -598.01 1240.0 7.5165  1   0.006114 **
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF540)
              npar  logLik    AIC    LRT Df Pr(>Chisq)   
<none>          23 -592.85 1231.7                        
(1 | AHRF540)   22 -598.01 1240.0 10.337  1   0.001304 **
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF919)
              npar  logLik    AIC    LRT Df Pr(>Chisq)  
<none>          23 -596.33 1238.7                       
(1 | AHRF919)   22 -598.01 1240.0 3.3793  1    0.06602 .
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF1029)
               npar  logLik  AIC    LRT Df Pr(>Chisq)    
<none>           23 -585.98 1218                         
(1 | AHRF1029)   22 -598.01 1240 24.075  1  9.267e-07 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF845)
              npar  logLik  AIC        LRT Df Pr(>Chisq)
<none>          23 -598.01 1242                         
(1 | AHRF845)   22 -598.01 1240 -9.002e-09  1          1
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF1746)
               npar  logLik    AIC    LRT Df Pr(>Chisq)
<none>           23 -597.45 1240.9                     
(1 | AHRF1746)   22 -598.01 1240.0 1.1198  1       0.29
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_25 + D2_T4_26 + D2_T4_79 + D2_T4_80 + D2_T4_5 + D2_T2_39 + D2_T1_54 + D2_T1_53 + D2_T1_62 + D2_T1_17 + D2_T4_24 + D2_T1_25 + D2_T1_46 + D2_T2_87 + D2_T1_47 + D2_T1_44 + D2_T2_90 + D2_T2_81 + D2_T2_84 + D2_T1_45 + D2_T1_19 + (1 | AHRF729)
              npar  logLik    AIC     LRT Df Pr(>Chisq)
<none>          23 -597.88 1241.8                      
(1 | AHRF729)   22 -598.01 1240.0 0.27646  1      0.599

#####################

Final Step: Create final Model 

Linear mixed model fit by REML ['lmerModLmerTest']
Formula: log ~ (1 | AHRF1029) + D2_T4_5 + D2_T2_39 + D2_T1_17 + D2_T1_46 +  
    D2_T2_90
   Data: D2
REML criterion at convergence: 1267.292
Random effects:
 Groups   Name        Std.Dev.
 AHRF1029 (Intercept) 0.7220  
 Residual             0.4567  
Number of obs: 969, groups:  AHRF1029, 2
Fixed Effects:
(Intercept)      D2_T4_5     D2_T2_39     D2_T1_17     D2_T1_46     D2_T2_90  
    4.43597      0.24960      0.09274     -0.07531     -0.15860      0.02957  
Linear mixed model fit by REML. t-tests use Satterthwaite's method [
lmerModLmerTest]
Formula: log ~ (1 | AHRF1029) + D2_T4_5 + D2_T2_39 + D2_T1_17 + D2_T1_46 +  
    D2_T2_90
   Data: D2

REML criterion at convergence: 1267.3

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-10.7678  -0.1368   0.0644   0.2879   3.2171 

Random effects:
 Groups   Name        Variance Std.Dev.
 AHRF1029 (Intercept) 0.5213   0.7220  
 Residual             0.2086   0.4567  
Number of obs: 969, groups:  AHRF1029, 2

Fixed effects:
             Estimate Std. Error        df t value Pr(>|t|)    
(Intercept)   4.43597    0.52265   0.99097   8.487    0.076 .  
D2_T4_5       0.24960    0.01577 962.06318  15.830  < 2e-16 ***
D2_T2_39      0.09274    0.01534 962.04535   6.046 2.12e-09 ***
D2_T1_17     -0.07531    0.01536 962.09498  -4.903 1.11e-06 ***
D2_T1_46     -0.15860    0.01818 962.02902  -8.724  < 2e-16 ***
D2_T2_90      0.02957    0.01803 962.04244   1.640    0.101    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Correlation of Fixed Effects:
         (Intr) D2_T4_ D2_T2_3 D2_T1_1 D2_T1_4
D2_T4_5   0.005                               
D2_T2_39 -0.005  0.232                        
D2_T1_17 -0.007 -0.124  0.141                 
D2_T1_46  0.004 -0.237 -0.026   0.019         
D2_T2_90 -0.004 -0.106  0.035   0.183   0.552 
ANOVA-like table for random-effects: Single term deletions

Model:
log ~ D2_T4_5 + D2_T2_39 + D2_T1_17 + D2_T1_46 + D2_T2_90 + (1 | AHRF1029)
               npar  logLik    AIC    LRT Df Pr(>Chisq)    
<none>            8 -633.65 1283.3                         
(1 | AHRF1029)    7 -641.94 1297.9 16.593  1  4.632e-05 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
Type III Analysis of Variance Table with Satterthwaite's method
         Sum Sq Mean Sq NumDF  DenDF  F value    Pr(>F)    
D2_T4_5  52.277  52.277     1 962.06 250.5951 < 2.2e-16 ***
D2_T2_39  7.626   7.626     1 962.05  36.5542 2.122e-09 ***
D2_T1_17  5.015   5.015     1 962.09  24.0391 1.108e-06 ***
D2_T1_46 15.879  15.879     1 962.03  76.1167 < 2.2e-16 ***
D2_T2_90  0.561   0.561     1 962.04   2.6904    0.1013    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# Intraclass Correlation Coefficient

     Adjusted ICC: 0.714
  Conditional ICC: 0.645


#################### 

