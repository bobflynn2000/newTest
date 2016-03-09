
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
wdir_SoilUnionGrid = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Union_output", sep="")

wdir_FishnetGrid = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Fishnet", sep="")

#wdir_Component = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/SSURGO tables", sep="")
wdir_validmu = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/SSURGO tables", sep="")
wdir_outputcsv = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Final_output", sep="")

#Set file name variables

#fname_SoilUnionGrid = "Union_output_table_MT.dbf"
#fname_SoilUnionGrid = "Union_3layers_GValleyCnty_MT.dbf"
fname_SoilUnionGrid = "Union_3layers_output_MT.csv"

#fname_Fishnet = "WELD_1k_Fishnet.csv"
fname_Fishnet = "Fishnet_Arcmap_Montana_clip_sort.dbf"
#fname_Fishnet = "Fishnet_Arcmap_Montana_GoldenValleyCntyt.dbf"

#fname_Component = "MT_component.csv"
fname_outputcsv = "final_output_MT.csv"
fname_validmu = "valid_daycent_mukeys.csv"

## End of Run Parameters
######################################


#Set the working directory for SoilUnionGrid files
setwd(wdir_SoilUnionGrid)

#Read in the Soils Data Unioned with Grid layer csv file
#Weld_1k_Union <- read.csv(fname_SoilUnionGrid)
#Tb_Unioned_Layers <- read.dbf(fname_SoilUnionGrid, as.is = FALSE)
Tb_Unioned_Layers <- read.csv(fname_SoilUnionGrid)


#Set the working directory for Fishnet grid
setwd(wdir_FishnetGrid)

#Read in the 1k Fishnet layer csv file
#Weld_1k_Fishnet <- read.csv(fname_Fishnet)
Tb_FishnetGrid <- read.dbf(fname_Fishnet)

#Set the working directory for validmu files
setwd(wdir_validmu)

#Read in the Valid MUkey csv file
Tb_DCValid_Mukeys <- read.csv(fname_validmu)


#-------Run Queries-----------------------

Q1_Get_Valid_MUKEY  = data.frame(sqldf("SELECT Tb_Unioned_Layers.*
  FROM Tb_Unioned_Layers INNER JOIN Tb_DCValid_Mukeys ON Tb_Unioned_Layers.MUKEY = Tb_DCValid_Mukeys.mukey"))


Q2_SumArea_CellID_Mukey = data.frame(sqldf("SELECT Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY, Sum(Q1_Get_Valid_MUKEY.Area_SqM) AS SumCellMukey_Area
FROM Q1_Get_Valid_MUKEY
GROUP BY Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY"))


Q3_SumArea_CellID_Mukey_Wetland = data.frame(sqldf("SELECT Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY, Q1_Get_Valid_MUKEY.FID_CONUS_wet_poly, Sum(Q1_Get_Valid_MUKEY.Area_SqM) AS Sum_Wetland_Area
FROM Q1_Get_Valid_MUKEY
GROUP BY Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY, Q1_Get_Valid_MUKEY.FID_CONUS_wet_poly
HAVING (((Q1_Get_Valid_MUKEY.FID_CONUS_wet_poly)<>-1))"))

Q4_Get_Pct_Wetland = data.frame(sqldf("SELECT Q2_SumArea_CellID_Mukey.Cell_ID, Q2_SumArea_CellID_Mukey.MUKEY, Sum(([Sum_Wetland_Area]/[SumCellMukey_Area])*100) AS SumPct_Wetland
FROM Q2_SumArea_CellID_Mukey INNER JOIN Q3_SumArea_CellID_Mukey_Wetland ON (Q2_SumArea_CellID_Mukey.MUKEY = Q3_SumArea_CellID_Mukey_Wetland.MUKEY) AND (Q2_SumArea_CellID_Mukey.Cell_ID = Q3_SumArea_CellID_Mukey_Wetland.Cell_ID)
GROUP BY Q2_SumArea_CellID_Mukey.Cell_ID, Q2_SumArea_CellID_Mukey.MUKEY"))

Q5_Get_Mukey_wo_Wetland = data.frame(sqldf("SELECT Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY, Avg(Q4_Get_Pct_Wetland.SumPct_Wetland) AS AvgOfSumPct_Wetland, Avg(Q2_SumArea_CellID_Mukey.SumCellMukey_Area) AS Area_CellMukey
FROM (Q1_Get_Valid_MUKEY LEFT JOIN Q4_Get_Pct_Wetland ON (Q1_Get_Valid_MUKEY.Cell_ID = Q4_Get_Pct_Wetland.Cell_ID) AND (Q1_Get_Valid_MUKEY.MUKEY = Q4_Get_Pct_Wetland.MUKEY)) LEFT JOIN Q2_SumArea_CellID_Mukey ON (Q1_Get_Valid_MUKEY.MUKEY = Q2_SumArea_CellID_Mukey.MUKEY) AND (Q1_Get_Valid_MUKEY.Cell_ID = Q2_SumArea_CellID_Mukey.Cell_ID)
GROUP BY Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY
HAVING (((Avg(Q4_Get_Pct_Wetland.SumPct_Wetland))<50 Or (Avg(Q4_Get_Pct_Wetland.SumPct_Wetland)) Is Null));"))

Q6_Interim_Mukey_LArea = data.frame(sqldf("SELECT t1.*
FROM Q5_Get_Mukey_wo_Wetland AS t1 LEFT JOIN Q5_Get_Mukey_wo_Wetland AS t2 ON (t1.cell_id = t2.cell_id) AND (t1.Area_CellMukey < t2.Area_CellMukey)
WHERE t2.cell_id is null"))

#Run the final query to generate mukey output table
Q7_Final_Mukey_LArea = data.frame(sqldf("SELECT Tb_FishnetGrid.Cell_ID, Tb_FishnetGrid.Lat, Tb_FishnetGrid.Lon, Q6_Interim_Mukey_LArea.MUKEY, Q6_Interim_Mukey_LArea.Area_CellMukey AS Area_Mukey, Tb_FishnetGrid.TArea_sqm AS Area_EntireCell, ([Area_CellMukey]/[TArea_sqm])*100 AS PctArea_Mukey, 
(Case When [mukey] IS NULL Then 'No' Else (Case When ([Area_CellMukey]/[TArea_sqm])*100 < 1 Then 'No' Else 'Yes' End) End) AS ValidCell
FROM Tb_FishnetGrid LEFT JOIN Q6_Interim_Mukey_LArea ON Tb_FishnetGrid.Cell_ID = Q6_Interim_Mukey_LArea.Cell_ID
ORDER BY Tb_FishnetGrid.Cell_ID"))

#(Case When [mukey] IS NULL Then 'No' Else (Case When ([Area_CellMukey]/[TArea_sqm])*100 < 1 Then 'No' Else 'Yes' End) End) AS ValidCell


#Set the working directory for output files
setwd(wdir_outputcsv)

#Write CSV output
write.csv(Q7_Final_Mukey_LArea, fname_outputcsv, row.names=FALSE)

#Display end time
cat("\n",paste("End time is ", Sys.time()),"\n")

