setwd(paste(directory, 'WK9'))

#load the packages
library(lme4)
library(arm)
#read csv file
dfsbp<-read.csv("data/sbp.csv",header=T)

#1.1 empty model analysis
m1<-lmer(sbp~(1|id),data=dfsbp)
display(m1)

#1.2 varying intercept with individual-level predictor
m2<-lmer(sbp~bmi+(1|id),data=dfsbp)
display(m2)
#coefficients for first five groups
coef_m2<-coef(m2)
head(coef_m2[[1]])
#fixed-effects
fixef(m2)
#random-effects
head(ranef(m2)[[1]])
#standard errors
se.fixef(m2)
head(se.ranef(m2)[[1]])
#95% CI of the intercept for id=51
coef(m2)$id[51,1]+c(-1.96,1.96)*se.ranef(m2)$id[51]

#1.3 varying intercept with individual- and group-level predictors
m3<-lmer(sbp~bmi+age+(1|id),data=dfsbp)
display(m3)

#1.4 varying slopes model
m4<-lmer(sbp~bmi+(1+bmi|id),data=dfsbp)

dfsbp$bmi_scaled<-scale(dfsbp$bmi,center = T,scale = T) #center and scale to SD
m4<-lmer(sbp~bmi_scaled+(1+bmi_scaled|id),data=dfsbp)

m4<-lmer(sbp~bmi_scaled+(1+bmi_scaled|id),data=dfsbp,control = lmerControl(optimizer = "bobyqa",optCtrl = list(maxfun=2e5)))

display(m4)
head(coef(m4)[[1]])
fixef(m4)
head(ranef(m4)[[1]])
#add the age
m5<-lmer(sbp~bmi_scaled+age+bmi_scaled:age+(1+bmi_scaled|id),data=dfsbp)
display(m5)

#1.5 non-nested models
m6<-lmer(sbp~(1|id)+(1|am),data=dfsbp)
display(m6)

###############################################################
#Add a dichotomous variable ht to indicate hypertension status#
###############################################################
dfsbp$ht<-(dfsbp$sbp>140)*1

#2.1 empty model
m7<-glmer(ht~(1|id),family=binomial(link="logit"),data=dfsbp)
display(m7)
head(coef(m7)[[1]])
fixef(m7)
head(ranef(m7)[[1]])

#add bmi and race
m8<-glmer(ht~bmi+factor(race)+(1|id),family=binomial(link="logit"),data=dfsbp)
display(m8)
head(coef(m8)[[1]])
fixef(m8)
head(ranef(m8)[[1]])

#OR and 95% CI for BMI
exp(fixef(m8)[2])
exp(fixef(m8)[2]+c(-1.96,1.96)*se.fixef(m8)[2])

#2.2 Poisson model and GLMM
m9<-glmer(ex~bmi+(1|id),family=poisson(link="log"),data=dfsbp)
display(m9)
head(coef(m9)[[1]])
