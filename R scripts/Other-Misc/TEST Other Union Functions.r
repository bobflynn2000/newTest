#library(ncdf)
require(sp)
require(rgdal)
#require(maps)
#library(chron)
library(rgeos)

library (gpclib)

setwd("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/soils grid/R_Union_test")



#Test gpclib Note problems with loading package on Windows 
#install.packages("C:\Users\bflynn\Documents\R program files\Package downloads\gpclib_1.5-5.tar.gz", repos = NULL, type="source")
#p1 <- read.polyfile(system.file("poly-ex/ex-poly1.txt", package = "gpclib"))
#p2 <- read.polyfile(system.file("poly-ex/ex-poly2.txt", package = "gpclib"))
## Plot the union of the two polygons
#plot(union(p1, p2))


#poly1 <- readOGR(".", "mapunit_clip")
#poly2 <- readOGR(".", "fishnet_clip")

poly1 <- readOGR(".", "polygon1")
poly2 <- readOGR(".", "polygon2")

summary(poly1)
poly1$Id
poly1$Id[1]

#Get attr names
names(poly1)

#Try assigning one polygon 
poly1a = poly1[1,]
poly1a = poly1[poly1$Id == 55,]

#Fix poly error problem 
poly1 = gBuffer(poly1,width=0,byid=TRUE) 

gIsValid (poly1)

plot(poly1)

poly_union = gUnion(poly1, poly2)
plot(poly_union)

poly_intersect = gIntersection(poly1a, poly2)

plot(poly_intersect)
summary(poly_intersect)

plot (poly1)