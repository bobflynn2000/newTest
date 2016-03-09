Rem  BATCH FILE TO GENERATE DOMINANT SOILS MUKEY FILE

REM  FIRST RUN PYTHON PROGRAM TO PERFORM UNION AND CALCULATE AREA
python "C:\Users\bflynn\Documents\Dennis_general_workarea\DAYCENT_Run_2014\python scripts\Run_Union_and_CalcArea.py"

REM NEXT RUN R SCRIPT TO PERFORM VARIOUS QUERIES TO GENERATE DOMINANT MUKEY FILE

R CMD BATCH "C:\Users\bflynn\Documents\Dennis_general_workarea\DAYCENT_Run_2014\R scripts\Weld_Process_Union_Data.R"