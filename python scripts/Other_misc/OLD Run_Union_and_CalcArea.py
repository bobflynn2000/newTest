# Program to Union Fishnet Grid with Mapunit layer

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
env.workspace = "C:/Users/bflynn/Documents/Dennis_general_workarea/DAYCENT_Run_2014/gis data/soils grid/Weld_test"


#----------Run UNION --------------------
# Set input and output feature variables for union
inFeatures = ["Weld_1k_fishnet.shp","Weld_mapunit_poly.shp"]
outFeatures = "out_union_python3.shp"

# Perform union using inFeatures and outFeatures
print "Starting Union..."
arcpy.Union_analysis (inFeatures, outFeatures)
#arcpy.Union_analysis (["Weld_1k_fishnet.shp","Weld_mapunit_poly.shp"], "out_union_python.shp")

# Print finished message
print "Union module completed!"


#----------Run Add Field --------------------
print "Running Add Field..."
AreaFieldName = "Area_sqm"
#Perform Add Field to add the Area in Sq Meters Field
arcpy.AddField_management(outFeatures, AreaFieldName, "DOUBLE", 16, 2, "","",
"NULLABLE", "NON_REQUIRED")


#----------Run Calculate Area on Field --------------------
print "Running Calculate Area..."
#Perform Calculate Field to get values for Area in Sq Meters
arcpy.CalculateField_management(outFeatures, AreaFieldName, 
                                    "!SHAPE.Area@SQUAREMETERS!",
                                    "PYTHON_9.3")

print "Module completed!"
print "Elapsed seconds = " + str(time.time() - start_time_sec)
