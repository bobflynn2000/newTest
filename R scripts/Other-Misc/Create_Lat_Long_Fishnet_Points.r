#Display start time
cat("\n",paste("Start time is ", Sys.time()),"\n")

#Load library packages
library(geosphere)

#clear all objects
rm(list=ls())

#########################################
##Run parameters - MODIFY AS Needed 


#setwd("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/soils grid/R_Union_test")
setwd("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/fishnet")

fname_outputcsv = "Fishnet_1k_latlong_data.csv"

Numcols = 2060
Numrows = 2000
#Numcols = 10
#Numrows = 10


OrigLong = -116.066
OrigLat = 31.8

## End of Run Parameters
######################################

#Initialize arrays
arrayID = c(rep(1,Numrows * Numcols))
arrayLon = c(rep(1.1,Numrows * Numcols))
arrayLat = c(rep(1.1,Numrows * Numcols))

#Initialize empty data frame
#PointsDF = data.frame(ID = integer(0), Long = numeric(0), Lat = numeric(0))

#Initialize Counter
ID_Count = 0

# Loop for number of columns
for (Col in 1:Numcols) {

	#Set Current base column lat/long point
	if (ID_Count == 0) 
	{
		#If first, set to origin
		CbasePoint = c(OrigLong,OrigLat) 
	} else {
		#If not first, Move to 1000km west of last cbase point
		CbasePoint <- destPoint(CbasePoint,90,1000)
	}

	#Set Current base column point to current point for row processing
	CurPoint = CbasePoint


	# Loop for number of rows
	for (Row in 1:Numrows) {
		
		#Increment ID
		ID_Count = ID_Count + 1

		#Add current point to arrays
		arrayID[ID_Count] = ID_Count
		arrayLon[ID_Count] = CurPoint[1]
		arrayLat[ID_Count] = CurPoint[2]

		#PointsDF = rbind(PointsDF, data.frame(ID=ID_Count, Long=CurPoint[1], Lat=CurPoint[2]))
		
		#Set New Point that's 1000Km to north of current point
		CurPoint <- destPoint(CurPoint,0,1000)

	} # End Loop for Rows

} # End Loop for Columns

#Create Points Dataframe using arrarys
PointsDF = data.frame(ID=arrayID, Long=arrayLon, Lat=arrayLat)
		

#Write the dataframe to CSV file
write.csv(PointsDF, fname_outputcsv, row.names=FALSE)
		
#Display end time
cat("\n",paste("End time is ", Sys.time()),"\n")
		
