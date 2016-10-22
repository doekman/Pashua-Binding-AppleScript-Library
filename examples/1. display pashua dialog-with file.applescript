-- The following line is needed to use ASPashua
use script "ASPashua"
-- When you don't have any "use" statements, the following is incluced automatically.
-- When including ASPashua, you need to uncomment this when using standard things 
-- like "display alert" or "path to me"
use scripting additions


-- Get the path to the current folder, and create an alias for the mentioned file
set script_path to (path to me as text) & "::"
set config_file_name to "1. display pashua dialog-with file.pashua"
set config_file to alias (script_path & config_file_name)


-- Show the dialog, the results of the dialog will be shown in the Results-pane
display pashua dialog config_file
