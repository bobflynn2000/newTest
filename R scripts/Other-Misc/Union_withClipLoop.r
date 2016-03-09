#Display start time
cat("\n",paste("Start time is ", Sys.time()),"\n")

#Load library packages
require(rgdal)
require(sp)
require(maps)
library(rgeos)
library(maptools)
library(raster)

#clear all objects
rm(list=ls())

#########################################
##Run parameters - MODIFY AS Needed 


#setwd("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/soils grid/R_Union_test")
setwd("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/soils grid/Weld_test")



## End of Run Parameters
######################################


#Mapunit_poly <- readOGR(".", "Weld_mapunit_poly_utm")
#Fishnet_poly <- readOGR(".", "Weld_1k_fishnet")

#Mapunit_poly = readShapePoly("Weld_mapunit_poly_utm")
Mapunit_poly = readShapePoly("Temp_SOILS_CLIPPED")
#Fishnet_poly = readShapePoly("Weld_1k_fishnet")
Fishnet_poly = readShapePoly("Weld_1k_fishnet_TESTonepoly")

#Fix poly error problem 
#Mapunit_poly = gBuffer(Mapunit_poly,width=0,byid=TRUE)

for(i in 1:nrow(Fishnet_poly)) {
	#Get each tile grid 
	Clipper_Tile_poly <- Fishnet_poly[i,]
	#Clipper_Tile_poly <- Fishnet_poly[100,]

	#Test by displaying with plot
	#plot(Clipper_Tile_poly)
	#readline("Press <return to continue") 

	# Perform clip and calculate area
	# combine is.na() with over() to do the containment test; note that we
	# need to "demote" Clipper_Tile_poly to a SpatialPolygons object first
	#inside.Clipper_Tile_poly <- !is.na(over(Mapunit_poly, as(Clipper_Tile_poly, "SpatialPolygons")))

	#Create new data frame with clip values only and clear old DF
	#Clipped_polys = Mapunit_poly[inside.Clipper_Tile_poly, ]

	#Perform intersect instead
	#Clipped_polys = gIntersection(Clipper_Tile_poly, Mapunit_poly) 
	 

	#Try Rasterizing poly and perform crop
 	#r <- raster(ncol=100, nrow=100)
	#proj4string(r)<-proj4string(Fishnet_poly)
	#Clip_Tile_raster <- rasterize(Clipper_Tile_poly, r, Clipper_Tile_poly$Cell_ID)
	#plot(Clipper_Tile_raster)	
	#readline("Press <return to continue")
	#Clipped_polys = crop(Clipper_Tile_raster,Clipper_Tile_poly)


	#Try crop with poly to poly
	Clipped_polys = crop(Mapunit_poly,Clipper_Tile_poly)

	#Test by displaying clip result
	plot(Clipped_polys)

	#Display start time
	cat("\n",paste("Pause, time is ", Sys.time()),"\n")
	
	#Pause for user confirmation
	readline("Press <return to continue") 

}