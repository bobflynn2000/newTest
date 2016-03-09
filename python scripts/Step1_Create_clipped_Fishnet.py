# Program to clip Fishnet layer for each state

#Import Time system module
import time

#Show start local time
localtime = time.asctime( time.localtime(time.time()) )
print "Local start time :", localtime

#Set seconds start time
start_time_sec = time.time()


# Import the ArcGIS system modules
import arcpy
from arcpy import env

# Set the current workspace
env.workspace = "C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Fishnet/Clip2State"


#------------Run clip for each state


State_List = ['CO', 'IA', 'KS', 'MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY']
#State_List = ['CO', 'KS', 'MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY']
#State_List = ['IA']

for State in State_List:


	arcpy.Clip_analysis(
	"C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/fishnet/Full/Fishnet_GPFull_DB.gdb/Fishnet_GPFull_Clip_Sort",
	"C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/Boundary_and_States/State_boundary/" + State + ".shp",
	"H:/Daymetrun2014/Fishnet/" + State + "_Fishnet.shp","#")



print "Module completed!"
print "Elapsed seconds = " + str(time.time() - start_time_sec)
