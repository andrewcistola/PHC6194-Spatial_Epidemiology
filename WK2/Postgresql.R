#load the package that will allow us to connect to postgresql
library("RPostgreSQL")

#Part 1

#create a connection
#save the password
pw <- "vmuser"

#load the postgresql driver
drv<-dbDriver("PostgreSQL")

#create a connection to the postgres database
con<-dbConnect(drv,dbname="phc6194db",host="localhost",user="phc6194",password=pw)

#query testtbl
#SELECT and FROM
q<-"SELECT * FROM testtbl;"
#run the sql query and save the results as a dataframe
dat<-dbGetQuery(con,q)
dat

#LIMIT
q<-"SELECT * FROM testtbl LIMIT 2;"
dbGetQuery(con,q)

#WHERE
q<-"SELECT * FROM testtbl WHERE date IS NOT NULL;"
dbGetQuery(con,q)

#LIKE
q<-"SELECT * FROM testtbl WHERE author LIKE '_uthor 5';"
dbGetQuery(con,q)

#ILIKE
q<-"SELECT * FROM testtbl WHERE author ILIKE '_UTHOR 5';"
dbGetQuery(con,q)

#IN
q<-"SELECT * FROM testtbl WHERE id IN (1,2,3,4);"
dbGetQuery(con,q)

#BETWEEN
q<-"SELECT * FROM testtbl WHERE date BETWEEN '2018-01-01' AND '2018-02-01';"
dbGetQuery(con,q)

#AND
q<-"SELECT * FROM testtbl WHERE date IS NULL AND id>5;"
dbGetQuery(con,q)

#OR
q<-"SELECT * FROM testtbl WHERE date IS NULL OR id>5;"
dbGetQuery(con,q)

#ORDER BY
q<-"SELECT * FROM testtbl ORDER BY date DESC;"
dbGetQuery(con,q)

#export R dataframe to postgresql
q<-"SELECT * FROM testtbl WHERE date IS NOT NULL ORDER BY date DESC;"
dat<-dbGetQuery(con,q)
dat

dbWriteTable(con,'testtbl2',dat,row.names=F,append=T)

#check
q<-"SELECT * FROM testtbl2;"
dbGetQuery(con,q)



#Part 2

#create some tables
q<-"
    CREATE TABLE subject(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    gender INT NOT NULL,
    age INT NOT NULL,
    race INT NOT NULL,
    county_id INT NOT NULL,
    state_id INT NOT NULL
    );
"
dbSendQuery(con,q) #this function execute the query

q<-"
    CREATE TABLE county(
    id INT NOT NULL,
    state_id INT NOT NULL,
    name VARCHAR(20) NOT NULL,
    income INT NOT NULL,
    PRIMARY KEY (id,state_id)
    );
"
dbSendQuery(con,q)

q<-"
    CREATE TABLE state(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    policy INT NOT NULL,
    date DATE
    );
"
dbSendQuery(con,q)

#insert some data
q<-"
    INSERT INTO subject(name,gender,age,race,county_id,state_id)
    VALUES  ('John',1,5,1,1,1),
            ('Mary',0,7,2,2,1),
            ('Mike',1,6,3,1,2),
            ('Linda',0,5,1,2,2),
            ('Lucas',1,4,1,1,3),
            ('Aiden',1,10,4,2,3);
"
dbSendQuery(con,q)

q<-"
    INSERT INTO county(id,state_id,name,income)
    VALUES  (1,1,'Alachua',78987),
            (2,1,'Orange',87689),
            (1,2,'Newton',56765),
            (2,2,'Burke',67890),
            (1,3,'Glenn',98678),
            (2,3,'Kings',87908);
"
dbSendQuery(con,q)

q<-"
     INSERT INTO state(name,policy,date)
     VALUES  ('Florida',1,'2002-11-23'),
             ('Georgia',0,NULL),
             ('California',1,'2004-12-23');
"
dbSendQuery(con,q)

#check
q<-"SELECT * FROM subject;"
dbGetQuery(con,q)
q<-"SELECT * FROM county;"
dbGetQuery(con,q)
q<-"SELECT * FROM state;"
dbGetQuery(con,q)

#JOIN
q<-"
        SELECT subject.name, state.name as state_name, state.policy
        FROM subject
        JOIN state ON subject.state_id=state.id
        ;
"
dbGetQuery(con,q)

q<-"
        SELECT subject.name, state.name as state_name, county.income
        FROM subject
        JOIN state ON subject.state_id=state.id 
        JOIN county ON subject.state_id=county.state_id 
                   AND subject.county_id=county.id;
"
dbGetQuery(con,q)

#Aggregate Functions
q<-"
        SELECT COUNT(id) as n
        FROM subject
        ;
"
dbGetQuery(con,q)

q<-"
        SELECT COUNT(id) as n, state_id
        FROM subject
        GROUP BY state_id
        ;
"
dbGetQuery(con,q)

#DISTINCT
q<-"
        SELECT COUNT(DISTINCT state_id) as nstate
        FROM subject
        ;
"
dbGetQuery(con,q)

#HAVING
q<-"
        SELECT MAX(income) as maxIncome, state_id
        FROM county
        GROUP BY state_id
        HAVING MAX(income)>90000
        ;
"
dbGetQuery(con,q)

#CASE
q<-"
        SELECT name,
               gender,
               CASE WHEN age BETWEEN 1 AND 4 THEN 1
               WHEN age BETWEEN 5 AND 8 THEN 2
               WHEN age > 8 THEN 3
               ELSE NULL
               END AS recodeage
        FROM subject
        ;
"
dbGetQuery(con,q)

#let's work on some real data
#NHIS 2015 family file and household file (https://www.cdc.gov/nchs/nhis/nhis_2015_data_release.htm)

#create a temp file
temp<-tempfile()

#download the file into the tempfile
download.file("ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/2015/familyxx.zip",temp)

#unzip the file and import as a dataframe family
family<-read.csv(unz(temp,"familyxx.csv"),header = T)

#remove the temp file
unlink(temp)

#do the same for the household file
temp<-tempfile()
download.file("ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/2015/househld.zip",temp)
household<-read.csv(unz(temp,"househld.csv"),header = T)
unlink(temp)

#check the downloaded data
head(family)
str(family)
head(household)
str(household)

#Export the data to postgresql database
#lower case for colnames
colnames(family)<-tolower(colnames(family))
colnames(household)<-tolower(colnames(household))

dbWriteTable(con,'family',family,row.names=F,overwrite=T)
dbWriteTable(con,'household',household,row.names=F,overwrite=T)

#check the exported data
q<-"
    SELECT *
    FROM family
    LIMIT 10
;
"
dbGetQuery(con,q)

q<-"
    SELECT *
    FROM household
    LIMIT 10
;
"
dbGetQuery(con,q)

#some simple queries
#which quarter was the interview conducted? show frequencies
q<-"
        SELECT intv_qrt, COUNT(intv_qrt) AS n_intv
        FROM household
        GROUP BY intv_qrt
        ORDER BY intv_qrt
        ;
"
dbGetQuery(con,q)

#what is the maximum number of families within a household?
q<-"
        SELECT COUNT(fmx) AS max_n_fam
        FROM family
        GROUP BY hhx
        ;
"
dbWriteTable(con,'temp',dbGetQuery(con,q),row.names=F,append=T)

q<-"
        SELECT MAX(max_n_fam) 
        FROM temp
        ;
"
dbGetQuery(con,q)

# get 1) the highest education level (family.fm_educ1) within a household, and 2) the housing type (household.livqrt) for each household
  
q<-"
        DROP TABLE IF EXISTS temp2;
        SELECT hhx,fmx,
               CASE WHEN fm_educ1 BETWEEN 97 AND 99 THEN NULL
               ELSE fm_educ1
               END AS recode_fm_educ1
        FROM family;
"
dbWriteTable(con,'temp2',dbGetQuery(con,q),row.names=F,append=F)

q<-"
        DROP TABLE IF EXISTS temp3;
        SELECT MAX(recode_fm_educ1) AS maxeduc, hhx
        FROM temp2
        GROUP BY temp2.hhx;
"
dbWriteTable(con,'temp3',dbGetQuery(con,q),row.names=F,append=F)

q<-"
        SELECT temp3.hhx,temp3.maxeduc,household.livqrt
        FROM temp3
        LEFT JOIN household ON temp3.hhx=household.hhx
        ORDER BY temp3.hhx
        LIMIT 10
        ;
"
dbGetQuery(con,q)

#use multiple qureies
q<-"
SELECT b.hhx,b.maxeduc,household.livqrt
FROM
(SELECT MAX(a.recode_fm_educ1) AS maxeduc, a.hhx
FROM
(SELECT 
       hhx,
       fmx,
       CASE WHEN fm_educ1 BETWEEN 97 AND 99 THEN NULL
       ELSE fm_educ1
       END AS recode_fm_educ1
FROM family) as a
GROUP BY a.hhx) as b
LEFT JOIN household ON b.hhx=household.hhx
LIMIT 10
;
"
dbGetQuery(con,q)

#close the connection
dbDisconnect(con)
dbUnloadDriver(drv)
