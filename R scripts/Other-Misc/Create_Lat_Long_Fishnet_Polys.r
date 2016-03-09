#Display start time
cat("\n",paste("Start time is ", Sys.time()),"\n")

#Load library packages
library(geosphere)
library(rgdal)
library(sp)

#clear all objects
rm(list=ls())

#########################################
##Run parameters - MODIFY AS Needed 


#setwd("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/soils grid/R_Union_test")
setwd("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/fishnet")

fname_outputcsv = "Fishnet_1k_latlong_data.csv"

#Numcols = 2060
#Numrows = 2000

#montana
# Startcol = 1
# Endcol = 950
# Startrow = 1
# Endrow = 525

# Startcol = 1
# Endcol = 950
# Startrow = 1
# Endrow = 250

Startcol = 1
Endcol = 950
Startrow = 251
Endrow = 525


BaseOrigLong = -116.066
BaseOrigLat = 49.06
#BaseOrigLat = 31.8


## End of Run Parameters
######################################


#Initialize Polygons object list
lsPs1 = list()

#Initialize Counter
ID_Count = 0

#Calculate New Origin using base origin and start values. Move orig x rows and y cols
CbasePoint = c(BaseOrigLong,BaseOrigLat)
OrigLong =  destPoint(CbasePoint,90,(Startcol-1)*1000)[1]
OrigLat = destPoint(CbasePoint,180,(Startrow-1)*1000)[2]

# Loop for number of rows

for (Row in Startrow:Endrow) {

	
	#Report progress
	cat("\n",paste("Starting row = ", Row, " System time is ", Sys.time()))
	flush.console()

	#Set Current base row lat/long point
	if (ID_Count == 0) 
	{
		#If first, set to origin
		CbasePoint = c(OrigLong,OrigLat) 
	} else {
		#If not first, Move to 1000km south of last cbase point
		CbasePoint <- destPoint(CbasePoint,180,1000)
	}

	#Set Current base row point to current point for row processing
	CurPoint = CbasePoint


	# Loop for number of columns
	for (Col in Startcol:Endcol) {
		

		#Increment ID
		ID_Count = ID_Count + 1

		#Report progress
		#cat("\n",paste("Starting ID_Count = ", ID_Count, " System time is ", Sys.time()))
		#flush.console()
		
		#Get points to south, southheast, and east
		SPoint = destPoint(CurPoint,180,1000)
		SEPoint = destPoint(SPoint,90,1000)
		EPoint = destPoint(CurPoint,90,1000)
		allPoints = rbind(CurPoint,SPoint,SEPoint,EPoint)

#     NPoint = destPoint(CurPoint,0,1000.0)
#     NEPoint = destPoint(NPoint,90,1000.0)
#     EPoint = destPoint(CurPoint,90,1000.0)
#     allPoints = rbind(CurPoint,NPoint,NEPoint,EPoint)

		#Create the polygon using current point and points to north and east
		#c1 = cbind(c(curPoint(1),NPoint[1],   , y1)
		r1 = rbind(allPoints, allPoints[1, ])  # join
		P1 = Polygon(r1)
		#lsPs1[ID_Count] = Polygons(list(P1), ID = ID_Count)
		lsPs1[Col-Startcol+1] = Polygons(list(P1), ID = ID_Count)
		#Ps1 = Polygons(list(P1), ID = ID_Count)
		
		#lsPs1[1] = Polygons(list(P1), ID = ID_Count)
		#lsPs1[2] = Polygons(list(P1), ID = ID_Count)

		#If first, Just assign one polygon to spatial polys
		#if (ID_Count == 1) 
		#{
		#	SPs = SpatialPolygons(list(Ps1))
		#
		#} else {
		#	#If not first, append the new poly to existing spatial polys
		#	SPs = SpatialPolygons(c(slot(SPs,"polygons"), list(Ps1)))
		#
		#}


		#PointsDF = rbind(PointsDF, data.frame(ID=ID_Count, Long=CurPoint[1], Lat=CurPoint[2]))
		
		#Set New Point that's 1000Km to east of current point
		CurPoint <- destPoint(CurPoint,90,1000)

	} # End Loop for Cols


	#If first row, Just assign rows polygon to new spatial polys
	if (Row == Startrow) 
	{
		SPs = SpatialPolygons(lsPs1)
	} else {
		#if not first col, load last col of polygons to exiting Spatial Polygons
		SPs = SpatialPolygons(c(slot(SPs,"polygons"), lsPs1))
	}

	#Clear and Initialize Polygons object list
	rm(lsPs1)
	lsPs1 = list()


} # End Loop for Rows


#Create Spatial Polygons
#SPs = SpatialPolygons(lsPs1)

#Create Spatial data frame
SPs.data <- as(SPs, "SpatialPolygons")
df <- data.frame(FID=row.names(SPs.data), row.names=row.names(SPs.data))
SPDF = SpatialPolygonsDataFrame(SPs, data=df)
proj4string(SPDF) <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

#Write shape file
writeOGR(SPDF, "test_polys", "test_polys_mn2", driver="ESRI Shapefile", overwrite_layer=TRUE )		


#Display end time
cat("\n",paste("End time is ", Sys.time()),"\n")
		
