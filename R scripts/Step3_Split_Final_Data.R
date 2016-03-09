##########################################################################
# Script to split the final csv file into smaller individual csv files
# so that it can be viewed in Excel. Excel's max row is 1 million. 
# Currently we split it into 4 files.
##########################################################################

#Display start time
cat("\n",paste("Start time is ", Sys.time()),"\n")

#clear all objects
rm(list=ls())

#Set memory limits
memory.limit(size=7000)


#########################################
##Run parameters - MODIFY AS Needed 

#Set the Working Directory Files
wdir_inputcsv = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Final_output/Merged", sep="")
wdir_outputcsv = paste("C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Final_output/Merged", sep="")


#Set file name variables
fname_inputcsv = paste("/Final_output_allGPStates.csv",sep="")
fname_outputcsv = paste("/Final_output_GP_Part_",sep="")

## End of Run Parameters
######################################

#Read in the final Mukey full output
Full_GPStates_df <- read.csv(paste(wdir_inputcsv,"/", fname_inputcsv, sep=""))

# #Determine split values
# Num_Splits = 4
# #Split_incr = nrow(Full_GPStates_df)/Num_Splits
# Split_incr = 600000

DF_NRows = nrow(Full_GPStates_df)
# 

# 
# #Loop for each portion
# for (i in 1:Num_Splits) 
# {
# 
#   if (i != 4)
#     {
#     Part_GPStates_df = Full_GPStates_df[(i-1)*Split_incr + 1 : i*Split_incr,]
#   } else {
#     Part_GPStates_df = Full_GPStates_df[(i-1)*Split_incr + 1 : DF_NRows,]
#   }
#    
#   
#Write out csv file1

write.csv(Full_GPStates_df[1:600000,], paste(wdir_outputcsv, "/", fname_outputcsv,"1.csv", sep=""), row.names=FALSE)
write.csv(Full_GPStates_df[600001:1200000,], paste(wdir_outputcsv, "/", fname_outputcsv,"2.csv", sep=""), row.names=FALSE)
write.csv(Full_GPStates_df[1200001:1800000,], paste(wdir_outputcsv, "/", fname_outputcsv,"3.csv", sep=""), row.names=FALSE)
write.csv(Full_GPStates_df[1800001:nrow(Full_GPStates_df),], paste(wdir_outputcsv, "/", fname_outputcsv,"4.csv", sep=""), row.names=FALSE)

#Example for removing NA's (make null)
#write.csv(Full_GPStates_df[1:600000,], paste(wdir_outputcsv, "/", fname_outputcsv,"1.csv", sep=""), row.names=FALSE, na="")

# }

#Display end time
cat("\n",paste("End time is ", Sys.time()),"\n")



  