
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

#Set State List
State_Abbr_List = c('CO', 'IA', 'KS', 'MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY')
#State_Abbr_List = c('MT', 'ND', 'MN')
#State_Abbr_List = c("MT")


#Set the Working Directory Files
wdir_inputcsv = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Final_output", sep="")
wdir_outputcsv = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Final_output/Merged", sep="")

#Set file name variables
fname_outputcsv = paste("/Final_output_allGPStates.csv",sep="")


## End of Run Parameters
######################################




firstloop = TRUE

#loop for all states
for (State_Abbr in State_Abbr_List) 
{
  #Report progress 
  cat("\n",paste("Start processing for State = ",State_Abbr))
  flush.console()
  
  #Set variable for input file name
  fname_inputcsv = paste(State_Abbr,"_final_output.csv", sep="")
  
  # read in Extreme CSV file with all values
  ReadDF <- read.csv(paste(wdir_inputcsv, "/", fname_inputcsv,sep=""))
  
  if (firstloop) {
    MergeAll_final_output = ReadDF
    firstloop = FALSE 
  } else {
    MergeAll_final_output = rbind(MergeAll_final_output,ReadDF)
  }
  
}


#Clear read dataframe
rm(ReadDF)


#Run 1st Query to get max area mukey in each cellid

Q1_Get_LargestArea_Mukey = data.frame(sqldf("SELECT t1.* 
FROM MergeAll_final_output AS t1 LEFT JOIN MergeAll_final_output AS t2 ON (t1.cell_id = t2.cell_id) AND (t1.PctArea_Mukey < t2.PctArea_Mukey)
WHERE t2.cell_id is null"))

Q2_Get_CellValid = data.frame(sqldf("SELECT Q1_Get_LargestArea_Mukey.*, (Case When [mukey] IS NULL Then 'No' Else (Case When ([Area_Mukey]/[Area_EntireCell])*100 < 1 Then 'No' Else 'Yes' End) End) AS ValidCell 
FROM Q1_Get_LargestArea_Mukey ORDER BY Cell_ID"))

rm(Q1_Get_LargestArea_Mukey)

Q3_Remove_Duplicates = data.frame(sqldf("SELECT Q2_Get_CellValid.Cell_ID, Max(Q2_Get_CellValid.Lat) AS Lat, Max(Q2_Get_CellValid.Lon) ASLon, Max(Q2_Get_CellValid.MUKEY) AS MUKEY, Max(Q2_Get_CellValid.Area_Mukey) AS Area_Mukey, Max(Q2_Get_CellValid.Area_EntireCell) AS Area_EntireCell, Max(Q2_Get_CellValid.PctArea_Mukey) AS PctArea_Mukey, Max(Q2_Get_CellValid.ValidCell) AS ValidCell
FROM Q2_Get_CellValid
GROUP BY Q2_Get_CellValid.Cell_ID"))

rm(Q2_Get_CellValid)

#Write CSV output
write.csv(Q3_Remove_Duplicates, paste(wdir_outputcsv,"/", fname_outputcsv, sep=""), row.names=FALSE)


#Display end time
cat("\n",paste("End time is ", Sys.time()),"\n")


