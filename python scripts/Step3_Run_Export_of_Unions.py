# Program to export the union layer of each state to csv file

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
env.workspace = "C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data"


#------------Run UNION for each state


State_List = ['CO', 'IA', 'KS', 'MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY']
#State_List = ['CO', 'KS', 'MN', 'MT', 'ND', 'NE', 'NM', 'OK', 'SD', 'Tx', 'WY']
#State_List = ['IA']

for State in State_List:

	print "Processing State = " + State


	arcpy.ExportXYv_stats("H:/Daymetrun2014/union_output/" + State + "_Union_outputdb.gdb/" + State + "_Union","Cell_ID;Lat;Lon;TArea_SqM;FID_CONUS_wet_poly;MUKEY;Shape_Area","COMMA","H:/Daymetrun2014/union_output/" + State + "_union_out_table.csv","ADD_FIELD_NAMES")



print "Module completed!"
print "Elapsed seconds = " + str(time.time() - start_time_sec)
