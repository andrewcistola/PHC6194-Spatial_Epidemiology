library(rpostgis)
library(RPostgreSQL)
library(sp) #provides classes and methods for spatial data

#Part 1

#create a connection
#save the password
pw <- "vmuser"

#load the postgresql driver
drv<-dbDriver("PostgreSQL")

#create a connection to the postgres database
con<-dbConnect(drv,dbname="phc6194db",host="localhost",user="phc6194",password=pw)

#create a schema to house the data for this week
q<-"
DROP SCHEMA IF EXISTS wk3 CASCADE;
CREATE SCHEMA wk3;
"
dbSendQuery(con,q)

#points
q<-"
  CREATE TABLE wk3.points (
    id serial PRIMARY KEY,
    p geometry(POINT),
    pz geometry(POINTZ),
    pm geometry(POINTM),
    pzm geometry(POINTZM),
    p_srid geometry(POINT,4269)
  );
"
dbSendQuery(con,q) # unknown srid =0

q<-"
  INSERT INTO wk3.points (p,pz,pm,pzm,p_srid)
  VALUES (
    ST_GeomFromText('POINT(1 -1)'),
    ST_GeomFromText('POINT Z(1 -1 1)'),
    ST_GeomFromText('POINT M(1 -1 1)'),
    ST_GeomFromText('POINT ZM(1 -1 1 1)'),
    ST_GeomFromText('POINT(1 -1)',4269)
  );
"
dbSendQuery(con,q)

#retrieve spatial data from postgis, and plot it
p<-pgGetGeom(con,c("wk3","points"),geom="p",other.cols=F)
plot(p)

#linestrings
q<-"
  CREATE TABLE wk3.linestrings(
    id serial PRIMARY KEY,
    name varchar(20),
    ls geometry(LINESTRING)
  );
  INSERT INTO wk3.linestrings(name,ls)
  VALUES
    ('Open',ST_GeomFromText('LINESTRING(0 0,1 1,1 -1)')),
    ('Closed',ST_GeomFromText('LINESTRING(0 0,1 1,1 -1,0 0)'));
"
dbSendQuery(con,q)

ls1<-pgGetGeom(con,c("wk3","linestrings"),geom="ls",other.cols=F,clauses ="WHERE name='Open'")
plot(ls1)
ls2<-pgGetGeom(con,c("wk3","linestrings"),geom="ls",other.cols=F,clauses ="WHERE name='Closed'")
plot(ls2)

#polygons
q<-"
  CREATE TABLE wk3.polygons(
    id serial PRIMARY KEY,
    name varchar(20),
    polygon geometry(POLYGON)
  );
  INSERT INTO wk3.polygons(name,polygon)
  VALUES
  ('Triangle',ST_GeomFromText('POLYGON((0 0,1 1,1 -1,0 0))')),
  ('TwoHoles',ST_GeomFromText('POLYGON((-0.25 -1.25, -0.25 1.25, 2.5 1.25,2.5 -1.25,-0.25 -1.25),(2.25 0,1.25 1,1.25 -1,2.25 0),(1 -1,1 1,0 0,1 -1))'));
"
dbSendQuery(con,q)

polygon1<-pgGetGeom(con,c("wk3","polygons"),geom="polygon",other.cols=F,clauses ="WHERE name='Triangle'")
plot(polygon1,col='black')
polygon2<-pgGetGeom(con,c("wk3","polygons"),geom="polygon",other.cols=F,clauses ="WHERE name='TwoHoles'")
plot(polygon2,col='black')

#multipoints
q<-"
CREATE TABLE wk3.multipoints (
id serial PRIMARY KEY,
p geometry(MULTIPOINT),
pz geometry(MULTIPOINTZ),
pm geometry(MULTIPOINTM),
pzm geometry(MULTIPOINTZM)
);

INSERT INTO wk3.multipoints (p,pz,pm,pzm)
VALUES (
ST_GeomFromText('MULTIPOINT(1 -1,0 0,2 3)'),
ST_GeomFromText('MULTIPOINT Z(1 -1 1,0 0 0,2 3 1)'),
ST_GeomFromText('MULTIPOINT M(1 -1 1,0 0 1, 2 3 1)'),
ST_GeomFromText('MULTIPOINT ZM(1 -1 1 1, 0 0 1 2, 2 3 1 2)')
);
"
dbSendQuery(con,q)

#retrieve spatial data from postgis, and plot it
p<-pgGetGeom(con,c("wk3","multipoints"),geom="p",other.cols=F)
plot(p)

#multilinestring
q<-"
  CREATE TABLE wk3.multilinestrings(
    id serial PRIMARY KEY,
    name varchar(20),
    ls geometry(MULTILINESTRING)
  );
  INSERT INTO wk3.multilinestrings(name,ls)
  VALUES
    ('1',ST_GeomFromText('MULTILINESTRING((0 0,0 1,1 1),(-1 1,-1 -1))'));
"
dbSendQuery(con,q)

ls<-pgGetGeom(con,c("wk3","multilinestrings"),geom="ls",other.cols=F)
plot(ls)

#multipolygon
q<-"
  CREATE TABLE wk3.multipolygons(
    id serial PRIMARY KEY,
    name varchar(20),
    polygon geometry(MULTIPOLYGON)
  );
  INSERT INTO wk3.multipolygons(name,polygon)
  VALUES
  ('1',ST_GeomFromText('MULTIPOLYGON(((2.25 0,1.25 1,1.25 -1,2.25 0)),((1 -1,1 1,0 0,1 -1)))'));
"
dbSendQuery(con,q)

polygon<-pgGetGeom(con,c("wk3","multipolygons"),geom="polygon",other.cols=F)
plot(polygon,col='black')

#change the SRID of an existing geometry column
q<-"
ALTER TABLE wk3.multipolygons
ALTER COLUMN polygon TYPE geometry(MULTIPOLYGON,4326)
USING ST_SetSRID(polygon,4326)
"
dbSendQuery(con,q)

polygon<-pgGetGeom(con,c("wk3","multipolygons"),geom="polygon",other.cols=F)
plot(polygon,col='black')

#convert a geometry column to a geography column
q<-"
ALTER TABLE wk3.multipolygons
ALTER COLUMN polygon TYPE geography(MULTIPOLYGON,4326)
USING ST_Transform(polygon,4326)::geography;
"
dbSendQuery(con,q)

polygon<-pgGetGeom(con,c("wk3","multipolygons"),geom="polygon",other.cols=F)
plot(polygon,col='black')

#Use geography data type
q<-"
CREATE TABLE  wk3.geogs (
  id serial PRIMARY KEY,
  name varchar(20),
  my_point geography(POINT)
);
INSERT INTO wk3.geogs (name,my_point)
VALUES
    ('Home',ST_GeogFromText('POINT(0 0)')),
    ('Pizza 1',ST_GeogFromText('POINT(1 1)')),
    ('Pizza 2',ST_GeogFromText('POINT(1 -1)'));
"
dbSendQuery(con,q)

#how far am I from pizza
q<-"
SELECT h.name AS house, p.name AS pizza, ST_Distance(h.my_point,p.my_point) AS dist
FROM
  (SELECT name, my_point FROM wk3.geogs WHERE name='Home') AS h
  CROSS JOIN
  (SELECT name, my_point FROM wk3.geogs WHERE name LIKE 'Pizza%') AS P
;
"
dbGetQuery(con,q)



