
#Display start time
cat("\n",paste("Start time is ", Sys.time()),"\n")

#clear all objects
rm(list=ls())

#Set memory limits
#memory.limit(size=2000)

#First - - Load all Library packages
require (sqldf)
require (foreign)

#########################################
##Run parameters - MODIFY AS Needed 

#Set the Working Directory Files
wdir_SoilUnionGrid = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/soils grid/Weld_Test", sep="")
wdir_Component = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/SSURGO tables", sep="")
wdir_outputcsv = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/soils grid/Weld_Test/Test Output", sep="")

#Set file name variables
#fname_SoilUnionGrid = "WELD_1k_Union.csv"
#fname_SoilUnionGrid = "out_union_python3_fromArc.csv"
fname_SoilUnionGrid = "out_union_python3.dbf"

#fname_Fishnet = "WELD_1k_Fishnet.csv"
fname_Fishnet = "WELD_1k_Fishnet.dbf"

fname_Component = "CO_component.csv"
fname_outputcsv = "test_output.csv"

## End of Run Parameters
######################################


#Set the working directory for SoilUnionGrid files
setwd(wdir_SoilUnionGrid)

#Read in the Soils Data Unioned with Grid layer csv file
#Weld_1k_Union <- read.csv(fname_SoilUnionGrid)
Weld_1k_Union <- read.dbf(fname_SoilUnionGrid, as.is = FALSE)

#Read in the 1k Fishnet layer csv file
#Weld_1k_Fishnet <- read.csv(fname_Fishnet)
Weld_1k_Fishnet <- read.dbf(fname_Fishnet)



#Set the working directory for component files
setwd(wdir_Component)

#Read in the Component csv file
CO_component <- read.csv(fname_Component)



#-------Run Queries-----------------------

Query_INTERM_Get_Major_Component = data.frame(sqldf("SELECT CO_component.mukey, Max(CO_component.comppct_r) AS MaxOfcomppct_r
FROM CO_component
GROUP BY CO_component.mukey"))

#Create Dataframe using SQL ForQuery_FINAL_Get_Major_Component
Query_FINAL_Get_Major_Component = data.frame(sqldf("SELECT CO_component.mukey, CO_component.compname, CO_component.comppct_r, CO_component.hydricrating, CO_component.majcompflag
FROM [Query_INTERM_Get_Major_Component] LEFT JOIN CO_component ON ([Query_INTERM_Get_Major_Component].MaxOfcomppct_r = CO_component.comppct_r) AND ([Query_INTERM_Get_Major_Component].mukey = CO_component.mukey)
WHERE (((CO_component.compname) Not Like '%Rock outcrop%') AND ((CO_component.hydricrating)= 'No') )
ORDER BY CO_component.mukey"))

#Create Dataframe using SQL For Query_FINAL2_Get_Major_Component
Query_FINAL2_Get_Major_Component = data.frame(sqldf("SELECT Query_FINAL_Get_Major_Component.mukey 
FROM Query_FINAL_Get_Major_Component 
GROUP BY Query_FINAL_Get_Major_Component.mukey"))

#Create Dataframe using SQL For Query_Weld_1k_Union_Valid
Query_Weld_1k_Union_Valid = data.frame(sqldf("SELECT Weld_1k_Union.* 
FROM Weld_1k_Union INNER JOIN Query_FINAL2_Get_Major_Component ON Weld_1k_Union.MUKEY = Query_FINAL2_Get_Major_Component.mukey"))

#Create Dataframe using SQL For Query_INTERM_Largest_Area
Query_INTERM_Largest_Area = data.frame(sqldf("SELECT d1.cell_id, d1.MUKEY, d1.SumOfArea_sqm
FROM (SELECT Cell_Id, MUKEY, Sum(Area_sqm) AS SumOfArea_sqm FROM Query_Weld_1k_Union_Valid GROUP BY Cell_Id, MUKEY)  AS d1 LEFT JOIN (SELECT Cell_Id, MUKEY, Sum(Area_sqm) AS SumOfArea_sqm FROM Query_Weld_1k_Union_Valid GROUP BY Cell_Id, MUKEY)  AS d2 ON (d1.SumOfArea_sqm < d2.SumOfArea_sqm) AND (d1.cell_id = d2.cell_id)
WHERE d2.cell_id is null"))

#Create Dataframe using SQL For Query_FINAL_LArea_With_PctArea
Query_FINAL_LArea_With_PctArea = data.frame(sqldf("
SELECT Weld_1k_Fishnet.cell_id AS Cell_ID, Weld_1k_Fishnet.Lat, Weld_1k_Fishnet.Lon, Query_INTERM_Largest_Area.MUKEY AS MuKey, Query_INTERM_Largest_Area.SumOfArea_sqm AS Mukey_Area_SqM, Weld_1k_Fishnet.TArea_sqm AS Tile_Area_SqM, ([SumOfArea_sqm]/[TArea_sqm])*100 AS Mukey_PctArea, (Case When [mukey] IS NULL Then 'No' Else (Case When ([SumOfArea_sqm]/[TArea_sqm])*100 < 1 Then 'No' Else 'Yes' End) End) AS ValidCell
FROM Weld_1k_Fishnet LEFT JOIN Query_INTERM_Largest_Area ON Weld_1k_Fishnet.Cell_ID = Query_INTERM_Largest_Area.cell_id
ORDER BY Weld_1k_Fishnet.Lat DESC , Weld_1k_Fishnet.Lon DESC;"))



#Set the working directory for output files
setwd(wdir_outputcsv)

#Write CSV output
write.csv(Query_FINAL_LArea_With_PctArea, fname_outputcsv, row.names=FALSE)

#Display end time
cat("\n",paste("End time is ", Sys.time()),"\n")

