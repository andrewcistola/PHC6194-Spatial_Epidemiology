# allocativ v3.0.21

## Stats Step 1: Import and Clean Data
st1 = 'Stats Step 1: Import and Clean Data'

### Import and Join Labels (W) with Predictors (X) and Outcomes (Y)
df_W = read.csv('_data/FIPS_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_X = read.csv('_data/_learn_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_Y = read.csv('_data/_spatial_ZCTA.csv', stringsAsFactors = FALSE) # Import dataset from _data folder
df_WX = merge(df_W, df_X, by = 'ZCTA', how = 'inner') # Merge data frame into data slot in SpatialDataFrame
df_WXY = merge(df_WX, df_Y, by = 'ZCTA', all.x = TRUE) # Merge data frame into data slot in SpatialDataFrame
head(df_WXY) # Verify

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

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(st1, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c('Selected States: ', State, '\n'), file = 'summary.txt', append = TRUE)
cat(c('Zip Code Observations: ', nrow(df_WXY), '\n'), file = 'summary.txt', append = TRUE)
cat(c('County Observations: ', nrow(df_WXY2), '\n\n'), file = 'summary.txt', append = TRUE)
head(df_WXY)
cat(c('\n'), file = 'summary.txt', append = TRUE)
head(df_WXY2)
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()

## Stats Step 2: Test for OLS Assumptions
st2 = 'Stats Step 2: Test for OLS Assumptions'
ID = 'ZCTA'
Y = 'crude'

### OLS Assumption 0: Sampling (Observations are a random sample, there are more observations than variables, IV is a result of DV)
oa0 =  'OLS Assumption 0: Sampling (Random sample, observations > predictors, predictor is independent)'
X = colnames(column_to_rownames(df_X, var = ID))
D = column_to_rownames(df_WXY[c(Y, colnames(df_X))], var = ID)
F = as.formula(paste(Y, ' ~ ', paste(X, collapse = ' + '), sep = ''))
OLS = lm(F, data = D) # Identitiy link [Y = DV*1] (aka: Linear) with gaussian error (aka: Linear regression)

### OLS Assumption 1: Specification (Relationship between predictor and outcome is linear)
oa1 = 'OLS Assumption 1: Specification (Relationship between predictor and outcome is linear)'
utt = raintest(OLS) # Utt's Rainbox Test

### OLS Assumption 2: Normality (Errors are normal with a mean = 0)
oa2 = 'OLS Assumption 2:  Normality (Errors are normal with a mean = 0)'
jb = JarqueBeraTest(resid(OLS)) # Jarque Bera Test
ad = AndersonDarlingTest(resid(OLS)) # Anderson-Darling Test
png(paste('_fig/', ST, '_QQ_', ID, '_plot.png', sep = ''))
qqnorm(resid(OLS))
qqline(resid(OLS))
dev.off()

### OLS Assumption 3: No Autocorrelation (Error terms are not correlated among observations)
oa3 = 'OLS Assumption 3: No Autocorrelation (Error terms are not correlated with each other)'
dw = DurbinWatsonTest(OLS) # Drubin-Watson Test

### OLS Assumption 4: Homoskedasticity (Error terms have constant variance across observations)
oa4 = 'OLS Assumption 4: Homoskedasticity (Error is even across observations)'
bp = bptest(OLS) # Breusch-Pagan Test
gq = gqtest(OLS) # Goldfield Quant Test
png(paste('_fig/', ST, '_residuals_', ID, '_plot.png', sep = ''))
plot(resid(OLS))
abline(0,0)
dev.off()

### OLS Assumption 5: No Colinearity (Predictors are not correlated with each other)
oa5 = 'OLS Assumption 5: No Colinearity (Predictors are not correlated with each other)'
plot = ggplot(subset(melt(round(cor(data[X], use = "pairwise.complete.obs"), 3)), value < 1), 
                aes(Var1, 
                    Var2)) + 
            geom_tile(aes(
                fill = value)) + 
            geom_text(aes(
                label = value),
                size = 1) + 
            scale_fill_gradient2(
                low = low,
                mid = mid,
                high = high) +
            labs(
                title = paste('Correlation Matrix |', outcome, 'in', state, '(', Y, 'rate)', sep = " "),
                fill = 'predictor\ncorrelation') +
            theme_minimal() +
            theme(
                text = element_text(family = 'Bookman'),
                plot.title = element_text(size = 12),
                panel.grid.major = element_blank(), 
                panel.grid.minor = element_blank(),
                panel.border = element_blank(),
                panel.background = element_blank(),
                axis.title = element_blank(),
                axis.text = element_text(size = 8),
                axis.text.x = element_text(angle = 90))
ggsave(paste('_fig/', ST, '_correlation_', ID, '_plot.png', sep = ''), plot = plot) # Save ggplot as jpeg

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(st2, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c(oa0, '\n\n'), file = 'summary.txt', append = TRUE)
summary(OLS)
cat(c(oa1, '\n'), file = 'summary.txt', append = TRUE)
print(utt)
cat(c('Significant = Non-linearity\n\n'), file = 'summary.txt', append = TRUE)
cat(c(oa2, '\n'), file = 'summary.txt', append = TRUE)
print(jb)
cat(c('Signficiant = Non-normal\n\n'), file = 'summary.txt', append = TRUE)
print(ad)
cat(c('Signficiant = Non-normal\n\n'), file = 'summary.txt', append = TRUE)
cat(c(oa3, '\n'), file = 'summary.txt', append = TRUE)
print(dw)
cat(c('Signficiant = Autocorrelation\n\n'), file = 'summary.txt', append = TRUE)
cat(c(oa4, '\n'), file = 'summary.txt', append = TRUE)
print(bp)
cat(c('Signficiant = Homoscedastic\n\n'), file = 'summary.txt', append = TRUE)
print(gq)
cat(c('Significant = Heteroscedastic\n\n'), file = 'summary.txt', append = TRUE)
cat(c('\n\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()

## Stats Step 3: Create Generalized Models
st3 = 'Stats Step 3: Create Generalized Linear Models'
ID = 'ZCTA'
X = colnames(column_to_rownames(df_X, var = ID))

### Create Linear Regression Model
Y = 'scale'
glm = 'linear'
glm0 = paste('DV = ', Y, ', regression = ', glm, sep = '')
D = column_to_rownames(df_WXY[c(Y, colnames(df_X))], var = ID)
F = as.formula(paste(Y, ' ~ ', paste(X, collapse = ' + '), sep = ''))
GLM0 = glm(F, data = D, family = gaussian()) # Identitiy link [Y = DV*1] (aka: Linear) with gaussian error (aka: Linear regression)

### Create Linear Regression Model
Y = 'log'
glm = 'linear'
glm1 = paste('DV = ', Y, ', regression = ', glm, sep = '')
D = column_to_rownames(df_WXY[c(Y, colnames(df_X))], var = ID)
F = as.formula(paste(Y, ' ~ ', paste(X, collapse = ' + '), sep = ''))
GLM1 = glm(F, data = D, family = gaussian()) # Identitiy link [Y = DV*1] (aka: Linear) with gaussian error (aka: Linear regression)

### Create Logistic Regression Model
Y = 'binary'
glm = 'logistic'
glm2 = paste('DV = ', Y, ', regression = ', glm, sep = '')
D = column_to_rownames(df_WXY[c(Y, colnames(df_X))], var = ID)
F = as.formula(paste(Y, ' ~ ', paste(X, collapse = ' + '), sep = ''))
GLM2 = glm(F, data = D, family = binomial()) # Logit link [Y = logit(DV)?] (aka: Logistic) with binomial? error (aka: Logistic regression)

### Create Poisson Regression Model
Y = 'crude'
glm = 'poisson'
glm3 = paste('DV = ', Y, ', regression = ', glm, sep = '')
D = column_to_rownames(df_WXY[c(Y, colnames(df_X))], var = ID)
F = as.formula(paste(Y, ' ~ ', paste(X, collapse = ' + '), sep = ''))
GLM3 = glm(F, data = D, family = poisson()) # Log link [Y = ln(DV)] (aka: Log-Linear) with poisson error (aka: Poisson regression)

### Create Negative Binomial Regression Model
Y = 'crude'
glm = 'negbinomial'
glm4 = paste('DV = ', Y, ', regression = ', glm, sep = '')
D = column_to_rownames(df_WXY[c(Y, colnames(df_X))], var = ID)
F = as.formula(paste(Y, ' ~ ', paste(X, collapse = ' + '), sep = ''))
GLM4 = glm.nb(F, data = D) # Log link [Y = ln(DV)] (aka: Log-Linear) with gamma error (aka: Negative binomial regression)

### F-test for overdispersion
t0 = 'overdispersion'
ovd0 = 1 - pchisq(deviance(GLM0), df.residual(GLM0)) # Chi-Sq on null deviance to residual deviance
ovd1 = 1 - pchisq(deviance(GLM1), df.residual(GLM1)) # Chi-Sq on null deviance to residual deviance
ovd2 = 1 - pchisq(deviance(GLM2), df.residual(GLM2)) # Chi-Sq on null deviance to residual deviance
ovd3 = 1 - pchisq(deviance(GLM3), df.residual(GLM3)) # Chi-Sq on null deviance to residual deviance
ovd4 = 1 - pchisq(deviance(GLM4), df.residual(GLM4)) # Chi-Sq on null deviance to residual deviance

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(st3, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c('Generalized model for', glm0, '\n'), file = 'summary.txt', append = TRUE)
summary(GLM0)
cat(c('Generalized model for', glm1, '\n'), file = 'summary.txt', append = TRUE)
summary(GLM1)
cat(c('Generalized model for', glm2, '\n'), file = 'summary.txt', append = TRUE)
summary(GLM2)
cat(c('Generalized model for', glm3, '\n'), file = 'summary.txt', append = TRUE)
summary(GLM3)
cat(c('Generalized model for', glm4, '\n'), file = 'summary.txt', append = TRUE)
summary(GLM4)
cat(c('\n\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()

## Stats Step 4: Hierarchical Linear Models
st4 = 'Stats Step 4: Hierarchical Linear Models'

### Mixed-Effects Regression for County Variable
mx1 = 'Fixed-Effects Regression for County Variables'
ID2 = 'FIPS'
Y = 'log'
df_WXY2$AHRF1746 = as.integer(cut(df_WXY2$AHRF1746, quantile(df_WXY2$AHRF1746, probs=0:4/4, na.rm = TRUE), include.lowest=TRUE))
df_WXY2$AHRF729 = as.integer(cut(df_WXY2$AHRF729, quantile(df_WXY2$AHRF729, probs=0:4/4, na.rm = TRUE), include.lowest=TRUE))
X2 = colnames(column_to_rownames(df_X2, var = ID2))
D2 = column_to_rownames(merge(df_WXY[c(ID2, Y, colnames(df_X))], df_WXY2[c(colnames(df_X2))], by  = ID2, how = 'left'), var = ID)

#### Random Intercept by County
F = as.formula(paste(Y, ' ~ (1|', ID2, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix0 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 1
H = 'AHRF101'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix1 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 2
H = 'AHRF1451'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix2 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 3
H = 'AHRF919'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix3 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 4
H = 'AHRF1634'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix4 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 5
H = 'AHRF540'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix5 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 6
H = 'AHRF919'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix6 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 7
H = 'AHRF1029'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix7 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 8
H = 'AHRF845'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix8 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 9
H = 'AHRF1746'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix9 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

#### County Variable 10
H = 'AHRF729'
F = as.formula(paste(Y, ' ~ (1|', H, ') + ' , paste(X, collapse = ' + '), sep = ''))
fix10 = lmer(F, data = D2[c(colnames(column_to_rownames(df_X, var = 'ZCTA')), Y, colnames(df_X2))]) # Poisson regression varying intercept with individual-level predictor

### One Way ANOVA for MLE
mx2 = 'One Way ANOVA for MLE'
hlm0 = ranova(fix0)
hlm1 = ranova(fix1)
hlm2 = ranova(fix2)
hlm3 = ranova(fix3)
hlm4 = ranova(fix4)
hlm5 = ranova(fix5)
hlm6 = ranova(fix6)
hlm7 = ranova(fix7)
hlm8 = ranova(fix8)
hlm9 = ranova(fix9)
hlm10 = ranova(fix10)

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(st4, '\n\n'), file = 'summary.txt', append = TRUE)
cat(c(mx1, '\n'), file = 'summary.txt', append = TRUE)
cat(c('DV = ', Y, '\n'), file = 'summary.txt', append = TRUE)
summary(fix0)
summary(fix1)
summary(fix2)
summary(fix3)
summary(fix4)
summary(fix5)
summary(fix6)
summary(fix7)
summary(fix8)
summary(fix9)
summary(fix10)
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat(c(mx2, '\n'), file = 'summary.txt', append = TRUE)
print(hlm1)
print(hlm2)
print(hlm3)
print(hlm4)
print(hlm5)
print(hlm6)
print(hlm7)
print(hlm8)
print(hlm9)
print(hlm10)
cat(c('\n'), file = 'summary.txt', append = TRUE)
cat(c('\n\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()

## FINAL STEP: Create final Model
final = 'Final Step: Create final Model'
FINAL = lmer(log ~ (1|AHRF1029) + 
                        D2_T4_5 + 
                        D2_T2_39 +  
                        D2_T1_17 +  
                        D2_T1_46 + 
                        D2_T2_90, 
                        data = D2) # Varying intercept with individual-level predictor

### Export features and labels
Feature = c('D3_1029', 'D2_T4_5', 'D2_T2_39', 'D2_T1_17', 'D2_T1_46', 'D2_T2_90')
df_select = as.data.frame(Feature)
df_labels = read.csv('_label/CENSUS_ACS_2019_ZCTA.csv') # Import dataset from _data folder
df_labels2 = read.csv('_label/HRSA_AHRF_2019_FIPS.csv') # Import dataset from _data folder
df_labels = rbind(df_labels, df_labels2)
df_select = merge(df_select, df_labels, by = 'Feature')
head(df_select)
write.csv(df_select, paste('_data/_stats_FINAL.csv', sep = ''), row.names = FALSE) # Clean in excel and select variable

### Export to Summary File
sink(file = 'summary.txt', append = TRUE, type = 'output')
cat(c(final, '\n\n'), file = 'summary.txt', append = TRUE)
print(FINAL)
summary(FINAL)
print(ranova(FINAL))
print(anova(FINAL))
icc(FINAL)
cat(c('\n\n'), file = 'summary.txt', append = TRUE)
cat(c('####################', '\n\n'), file = 'summary.txt', append = TRUE)
sink()

