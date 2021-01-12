#R crash course
#Adpated from https://billpetti.github.io/Crash_course_in_R/

#setup a working directory
setwd("/home/vmuser/Desktop/PHC6194SPR2021/WK1")

#assign objects
foo <- "hello world!"
foo

#case-sensitive
myvar <- 1
Myvar
myvar

#Comments
#foo2 <- "hello world!"
foo2

#data structures
#vector
x <- c(1,2,3,4,5)
x 
firstNames <- c("Shinji","Aska","Rey","Misato")
firstNames
#access different parts of the vector
firstNames[3]
#explore the structure of a vector
str(firstNames)

#factors
gender <- c("f","f","f","m","m","m")
gender <- as.factor(gender)
str(gender)

#lists - a sequence of elements of different types
myList <- list(x=x,firstNames=firstNames,gender=gender)
myList
#access specific elements within the list
myList[[1]]
myList$x
myList[["x"]]

#data frames
franchise <- c("Mets", "Nationals", "Marlins", "Phillies", "Braves")
city <- c("New York", "Washington, DC", "Miami", "Philadelphia", "Atlanta")
teams <- data.frame(franchise, city)
teams
#names of variables
colnames(teams)

#functions
x <- c(1, 2, 3, 4, 5)
x

our.mean <- function(x){
  return(sum(x) / length(x))
}

x
mean(x) #built-in mean 
our.mean(x) #self-defined mean
mean(x) == our.mean(x) #check whether these two values are equivalent

# a more complex function
our.summary <- function(x) {
  mean <- mean(x)
  median <- median(x)
  standard_deviation <- sd(x)
  foo <- cbind(mean, median, standard_deviation)
  return(foo)
}

our.summary(x)

#packages
install.packages("ggplot2") #install
library(ggplot2) #load
detach("package:ggplot2") #unload

#read data
dat1 <- read.csv("dat1.csv",header = TRUE, na.strings="NA")
str(dat1)
dat1 <- read.csv("dat1.csv",header = TRUE, na.strings="NA",stringsAsFactors = FALSE)
str(dat1)
head(dat1)

#write data
write.csv(dat1,"dat2.csv",row.names = F)

#data manipulation
data(iris) #load the built-in data "iris"
head(iris)
head(iris$Sepal.Length)
#an easier way to access more than one variables
head(with(iris,Sepal.Length/Sepal.Width))

iris$sepal_length_width_ratio <- with(iris, Sepal.Length / Sepal.Width)
head(iris)
iris$sepal_length_width_ratio <- round(iris$sepal_length_width_ratio, 2)
head(iris)

#categorize a variable into tertiles
iris$sepal_length_width_ratioG<-cut(iris$sepal_length_width_ratio,breaks=quantile(iris$sepal_length_width_ratio,probs=c(0,0.33,0.67,1)),include.lowest = T)
str(iris)

#convert factor into numeric
iris$sepal_length_width_ratioG<-as.numeric(iris$sepal_length_width_ratioG)
str(iris)

#quick summary of a variable
summary(iris$sepal_length_width_ratio)

#subsetting data
unique(iris$Species)

sub_virginica <- subset(iris, Species == "virginica")
head(sub_virginica)
unique(sub_virginica$Species)

ex_virginica <- subset(iris, Species != "virginica")
unique(ex_virginica$Species)

sub_virginica2 <- subset(iris, Species != "virginica" & sepal_length_width_ratio >= 2)
head(sub_virginica2)

#select specific variables
head(iris[,c(1,3)])

#select specific cases
iris[c(1:6),]

#basic descriptive and summary statistics
data(airquality)
summary(airquality)

#dplyr package
if (!require(dplyr)) {
  install.packages(dplyr)
}

with(iris,table(Species,Petal.Width))
table(iris$Species,iris$Petal.Width)

with(iris, table(Species, Petal.Width)) %>% prop.table()

with(iris, table(Species, Petal.Width)) %>% prop.table(margin = 1)  #row frequencies

with(iris, table(Species, Petal.Width)) %>% prop.table(margin = 2)  #column frequencies

cross_column<-with(iris, table(Species, Petal.Width)) %>% prop.table(margin = 2) %>% as.data.frame.matrix() 

#basic statistics and modeling
dat2<-read.csv("survey_sample_data.csv",header = T, stringsAsFactors = F)
str(dat2)

#correlation
cor(dat2$Q1,dat2$Q2,use="pairwise.complete.obs")
cor(dat2[,c(2:19)], use = "pairwise.complete.obs")
round(cor(dat2[,c(2:19)], use = "pairwise.complete.obs"),3)

#linear regression
head(iris)

iris_lm <-lm(Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width+ factor(Species),data=iris)

summary(iris_lm)

iris_lm$coefficients
confint(iris_lm)

#visualization
#histogram
hist(dat2$Q2)

hist(dat2$Q2, main = "Frequency of Responses to Q2", xlab = "Response Value",breaks = c(0.0, 1.0, 2.0, 3.0, 4.0, 5.0))

#scatterplots
plot(Sepal.Length~Sepal.Width,data=iris)

#boxplots
boxplot(iris$sepal_length_width_ratio)

#use ggplot2 to enhance visualizations
if (!require(ggplot2)) {
  install.packages(ggplot2)
}

#better scatterplots for iris
ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point()

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species)) #different color by species

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio)) #differnet size proportional to sepal length width ratio

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio,alpha=.3)) #add some transparency

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio,alpha=.3))+stat_smooth() #add a trend line

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio,alpha=.3)) +stat_smooth() +facet_wrap(~Species) #separate plots by species

#density plots for dat2
if (!require(reshape2)) {
  install.packages(reshape2)
}

dat2_melt<-melt(dat2[,c(2:19)])
ggplot(dat2_melt,aes(value))+geom_density()+facet_wrap(~variable)

#boxplots
ggplot(iris,aes(y=sepal_length_width_ratio,x=Species))+geom_boxplot()

#customize
ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio,alpha=.3)) +stat_smooth() +facet_wrap(~Species) 

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio,alpha=.3)) +stat_smooth() +facet_wrap(~Species) + ggtitle("Sepal Length versus Sepal Width") + xlab("Sepal Width")+ylab("Sepal Length") #add title and labels

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio,alpha=.3)) +stat_smooth() +facet_wrap(~Species) + ggtitle("Sepal Length versus Sepal Width") + xlab("Sepal Width")+ylab("Sepal Length") + theme(axis.title=element_text(face="bold",size=14),plot.title=element_text(face="bold",size=16)) #resize and bold

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio,alpha=.3)) +stat_smooth() +facet_wrap(~Species) + ggtitle("Sepal Length versus Sepal Width") + xlab("Sepal Width")+ylab("Sepal Length") + theme(axis.title=element_text(face="bold",size=14),plot.title=element_text(face="bold",size=16))+ theme(panel.background=element_blank()) #remove the shading

ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))+geom_point(aes(color=Species,size=sepal_length_width_ratio,alpha=.3)) +stat_smooth() +facet_wrap(~Species) + ggtitle("Sepal Length versus Sepal Width") + xlab("Sepal Width")+ylab("Sepal Length") + theme(axis.title=element_text(face="bold",size=14),plot.title=element_text(face="bold",size=16))+ theme(panel.background=element_blank()) + scale_color_brewer(palette="Greens") #use custom coclr palettes

#correlation heatmap
dat2_cor_melt<-melt(cor(dat2[,c(2:19)],use="pairwise.complete.obs"))
dat2_cor_melt$value<-round(dat2_cor_melt$value,2)
head(dat2_cor_melt)

ggplot(dat2_cor_melt, aes(Var1, Var2)) + geom_tile(aes(fill = value)) + geom_text(aes(label=value), size = 3, fontface = "bold") + scale_fill_gradient2(low = "#67a9cf", high = "#ef8a62") +theme_minimal() +theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),  panel.border = element_blank(),panel.background = element_blank(), axis.title = element_blank(), axis.text = element_text(size = 12, face = "bold"))

#remove 1d
dat2_cor_melt<-dat2_cor_melt[dat2_cor_melt$value!=1,]

ggplot(dat2_cor_melt, aes(Var1, Var2)) + geom_tile(aes(fill = value)) + geom_text(aes(label=value), size = 3, fontface = "bold") + scale_fill_gradient2(low = "#67a9cf", high = "#ef8a62") +theme_minimal() +theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),  panel.border = element_blank(),panel.background = element_blank(), axis.title = element_blank(), axis.text = element_text(size = 12, face = "bold"))

#remove the labels
ggplot(dat2_cor_melt, aes(Var1, Var2)) + geom_tile(aes(fill = value)) + scale_fill_gradient2(low = "#67a9cf", high = "#ef8a62") +theme_minimal() +theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),  panel.border = element_blank(),panel.background = element_blank(), axis.title = element_blank(), axis.text = element_text(size = 12, face = "bold"))
  
