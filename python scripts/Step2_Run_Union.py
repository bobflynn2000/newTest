# Program to Union Fishnet Grid with Mapunit layer and Wetland Layer for each State

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


#------------Run UNION for each state


#State_List = ['CO', 'IA', 'KS', 'MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY']
#State_List = ['CO', 'KS', 'MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY']
#State_List = ['MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY']
State_List = ['WY']

for State in State_List:

	print "Processing State = " + State

	arcpy.Union_analysis(["H:/Daymetrun2014/Fishnet/" + State + "_Fishnet.shp",
	"H:/Daymetrun2014/Ssurgo_processed/Ssurgo_work.gdb/" + State + "_Mapunit",
	"H:/Daymetrun2014/Wetland/" + State + "_wetlands.gdb/CONUS_wetlands/CONUS_wet_poly"],
	"H:/Daymetrun2014/union_output/" + State + "_Union_outputdb.gdb/" + State + "_Union","ALL","#","NO_GAPS")



print "Module completed!"
print "Elapsed seconds = " + str(time.time() - start_time_sec)
