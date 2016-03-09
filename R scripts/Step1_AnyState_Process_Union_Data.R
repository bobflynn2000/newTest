##################################################################################
# Script to process output from Union for any or all states. Each requested state
# is read from CSV file into dataframe and following queries are performed:
# 1. Inner join to get only valid mukeys (based on Ernie's file)
# 2. Get sum of poly areas grouped by cell and mukey (mukey within cell)
# 3. Get sum of poly areas grouped by on cell, mukey, and wetland (wetland in mukey)
# 4. Get percent wetland within mukey in each cell
# 5. Get all valid Mukey's with less than 50% wetland
# 6. Select only highest area Mukey within each cell using result from 6.
# 7. Join with full cell id list (acct for null muid's) and calc percent of cell
#
# Finally write each state output to csv file
#####################################################################################

#Display start time
cat("\n",paste("Start time is ", Sys.time()),"\n")

#clear all objects
rm(list=ls())

#Set memory limits
memory.limit(size=7000)



#First - - Load all Library packages
require (sqldf)
require (foreign)

#########################################
##Run parameters - MODIFY AS Needed 

#Set State 

#Set State List
#State_Abbr_List = c('CO', 'IA', 'KS', 'MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY')
#State_Abbr_List = c('CO', 'IA', 'KS', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY')
#State_Abbr_List = c('MT', 'ND', 'MN')
State_Abbr_List = c("MT")

#loop for all states ... Ends at bottom
for (State_Abbr in State_Abbr_List) 
  {

  #Report progress 
  cat("\n",paste("Start processing for State = ",State_Abbr))
  flush.console()
  
#Set the Working Directory Files
wdir_SoilUnionGrid = "H:/Daymetrun2014/union_output"
wdir_FishnetGrid = "H:/Daymetrun2014/Fishnet"
wdir_validmu = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/SSURGO tables", sep="")
wdir_outputcsv = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Final_output", sep="")

#Set file name variables
fname_SoilUnionGrid = paste(State_Abbr,"_union_out_table.csv",sep="")
fname_Fishnet = paste(State_Abbr,"_Fishnet.dbf",sep="")
fname_outputcsv = paste(State_Abbr,"_final_output.csv",sep="")
fname_validmu = "valid_daycent_mukeys.csv"

## End of Run Parameters
######################################


#Read in the Soils Data Unioned with Grid layer csv file
Tb_Unioned_Layers <- read.csv(paste(wdir_SoilUnionGrid,"/", fname_SoilUnionGrid, sep=""))

#Read in the Valid MUkey csv file
Tb_DCValid_Mukeys <- read.csv(paste(wdir_validmu, "/",fname_validmu,sep=""))


#-------Run Queries-----------------------
# Q1. Inner join to get only valid mukeys (based on Ernie's file)
Q1_Get_Valid_MUKEY  = data.frame(sqldf("SELECT Tb_Unioned_Layers.*
  FROM Tb_Unioned_Layers INNER JOIN Tb_DCValid_Mukeys ON Tb_Unioned_Layers.MUKEY = Tb_DCValid_Mukeys.mukey"))

#Remove Unioned layers DF and Valid Mukeys DF
rm(Tb_Unioned_Layers, Tb_DCValid_Mukeys)

# Q2. Get sum of poly areas grouped by cell and mukey (mukey within cell)
Q2_SumArea_CellID_Mukey = data.frame(sqldf("SELECT Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY, Sum(Q1_Get_Valid_MUKEY.Shape_Area) AS SumCellMukey_Area
FROM Q1_Get_Valid_MUKEY
GROUP BY Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY"))

# Q3. Get sum of poly areas grouped by on cell, mukey, and wetland (wetland in mukey)
Q3_SumArea_CellID_Mukey_Wetland = data.frame(sqldf("SELECT Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY, Q1_Get_Valid_MUKEY.FID_CONUS_wet_poly, Sum(Q1_Get_Valid_MUKEY.Shape_Area) AS Sum_Wetland_Area
FROM Q1_Get_Valid_MUKEY
GROUP BY Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY, Q1_Get_Valid_MUKEY.FID_CONUS_wet_poly
HAVING (((Q1_Get_Valid_MUKEY.FID_CONUS_wet_poly)<>-1))"))

# Q4. Get percent wetland within mukey in each cell
Q4_Get_Pct_Wetland = data.frame(sqldf("SELECT Q2_SumArea_CellID_Mukey.Cell_ID, Q2_SumArea_CellID_Mukey.MUKEY, Sum(([Sum_Wetland_Area]/[SumCellMukey_Area])*100) AS SumPct_Wetland
FROM Q2_SumArea_CellID_Mukey INNER JOIN Q3_SumArea_CellID_Mukey_Wetland ON (Q2_SumArea_CellID_Mukey.MUKEY = Q3_SumArea_CellID_Mukey_Wetland.MUKEY) AND (Q2_SumArea_CellID_Mukey.Cell_ID = Q3_SumArea_CellID_Mukey_Wetland.Cell_ID)
GROUP BY Q2_SumArea_CellID_Mukey.Cell_ID, Q2_SumArea_CellID_Mukey.MUKEY"))

#Remove un-used data frames
rm(Q3_SumArea_CellID_Mukey_Wetland)

# Q5. Get all valid Mukey's with less than 50% wetland
Q5_Get_Mukey_wo_Wetland = data.frame(sqldf("SELECT Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY, Avg(Q4_Get_Pct_Wetland.SumPct_Wetland) AS AvgOfSumPct_Wetland, Avg(Q2_SumArea_CellID_Mukey.SumCellMukey_Area) AS Area_CellMukey
FROM (Q1_Get_Valid_MUKEY LEFT JOIN Q4_Get_Pct_Wetland ON (Q1_Get_Valid_MUKEY.Cell_ID = Q4_Get_Pct_Wetland.Cell_ID) AND (Q1_Get_Valid_MUKEY.MUKEY = Q4_Get_Pct_Wetland.MUKEY)) LEFT JOIN Q2_SumArea_CellID_Mukey ON (Q1_Get_Valid_MUKEY.MUKEY = Q2_SumArea_CellID_Mukey.MUKEY) AND (Q1_Get_Valid_MUKEY.Cell_ID = Q2_SumArea_CellID_Mukey.Cell_ID)
GROUP BY Q1_Get_Valid_MUKEY.Cell_ID, Q1_Get_Valid_MUKEY.MUKEY
HAVING (((Avg(Q4_Get_Pct_Wetland.SumPct_Wetland))<50 Or (Avg(Q4_Get_Pct_Wetland.SumPct_Wetland)) Is Null));"))

#Remove un-used data frames
rm(Q2_SumArea_CellID_Mukey, Q1_Get_Valid_MUKEY,Q4_Get_Pct_Wetland)

# Q6. Select only highest area Mukey within each cell using result from 6.
Q6_Interim_Mukey_LArea = data.frame(sqldf("SELECT t1.*
FROM Q5_Get_Mukey_wo_Wetland AS t1 LEFT JOIN Q5_Get_Mukey_wo_Wetland AS t2 ON (t1.cell_id = t2.cell_id) AND (t1.Area_CellMukey < t2.Area_CellMukey)
WHERE t2.cell_id is null"))

#Remove un-used data frames
rm(Q5_Get_Mukey_wo_Wetland)

#Read in the 1k Fishnet layer csv file
Tb_FishnetGrid <- read.dbf(paste(wdir_FishnetGrid,"/",fname_Fishnet,sep=""))


#Run the final query to generate mukey output table

# Q7. Join with full cell id list (acct for null muid's) and calc percent of cell
Q7_Final_Mukey_LArea = data.frame(sqldf("SELECT Tb_FishnetGrid.Cell_ID, Tb_FishnetGrid.Lat, Tb_FishnetGrid.Lon, Q6_Interim_Mukey_LArea.MUKEY, Q6_Interim_Mukey_LArea.Area_CellMukey AS Area_Mukey, Tb_FishnetGrid.TArea_sqm AS Area_EntireCell, 
(Case When [mukey] IS NULL Then 0.0 Else ([Area_CellMukey]/[TArea_sqm])*100 End) AS PctArea_Mukey 
FROM Tb_FishnetGrid LEFT JOIN Q6_Interim_Mukey_LArea ON Tb_FishnetGrid.Cell_ID = Q6_Interim_Mukey_LArea.Cell_ID
ORDER BY Tb_FishnetGrid.Cell_ID"))

# SQL for case (not used here)
#(Case When [mukey] IS NULL Then 'No' Else (Case When ([Area_CellMukey]/[TArea_sqm])*100 < 1 Then 'No' Else 'Yes' End) End) AS ValidCell

#Remove un-used data frames
rm(Q6_Interim_Mukey_LArea,Tb_FishnetGrid)


#Set the working directory for output files
#setwd(wdir_outputcsv)

#Write CSV output
write.csv(Q7_Final_Mukey_LArea, paste(wdir_outputcsv,"/", fname_outputcsv, sep=""), row.names=FALSE)

}

#Display end time
cat("\n",paste("End time is ", Sys.time()),"\n")

