# Ag Tools README

This is a sample tool to show some additional functionality of R script tools. It contains a few different parameter types and a longer R script than the sample my_R_tool.R script. Note that this script tool is still in a draft state! In the "real world", we would want to add some additional funtionality, such as: 
 - a progress bar to show users how the tool execution is progressing,
 - error handling so that users would get an error message when the USDA NASS API does not return any results,
 - additional tool validation, perhaps
 - documentation about each of the parameters to explain what they are and what the user should input.

Feel free to use this script tool as a jumping off point to try implementing any of the above functionality.

To use the tool:
1. Open ArcGIS Pro
2. In the Contents pane, right click on the Toolboxes section and select "Add Toolbox"
3. Navigate to the "Ag_Tools.atbx" and click OK
4. In the tool properties, double check the path to the script (in the Execution tab) and the path to the Symbology layer (in the Parameters tab). Make sure they are pointing to the correct paths on your machine.

** Also: the script requires using a USDA NASS Quick Stats API key. This script will not run successfully unless you request an API key (https://quickstats.nass.usda.gov/api/) and either save the key to your system environment variables (Windows) or hardcode the API key value into the script code. **


Other info:
USDA NASS Quickstats webpage: https://quickstats.nass.usda.gov/
