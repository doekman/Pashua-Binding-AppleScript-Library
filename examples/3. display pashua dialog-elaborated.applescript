use script "ASPashua"
use scripting additions

-- Reuse the pashua-file form example 1
set script_path to (path to me as text) & "::"
set config_file_name to "1. display pashua dialog-with file.pashua"
set config_file to alias (script_path & config_file_name)


try
	set answer to display pashua dialog config_file
	-- When you press OK, "anwer" will contain something like this:
	-- {dob:"2016-10-19", email:"test@example.com", cb:"0", |name|:"Test Example", agree:"1", db:"1"}
	
	if agree of answer = "0" then
		-- You didn't check the checkbox
		display alert "NOTICE!" message "I'm very disappointed with you."
	else
		-- Notice the "name" property is surrounded by pipe characters. This is because "name" is an AppleScript reserved name.
		display alert "For your information" message "Hi, " & |name| of answer & ", you will be spammed at " & email of answer
	end if
	
on error number -128 --user canceled
	-- This part will only run if the user presses cancel, not with other errors
	display alert "User canceled" message "...but the script continues to execute"
end try
