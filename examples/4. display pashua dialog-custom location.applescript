use script "ASPashua"
use scripting additions

-- Get dialog config
set script_path to (path to me as text) & "::"
set config_file_name to "4. display pashua dialog-custom location.pashua"
set config_file to alias (script_path & config_file_name)

-- Determine path for Pashua.app
set my_prompt to "Please specify the custom location of Pashua.app"
repeat
	set my_location to choose file with prompt my_prompt of type {"com.apple.application-bundle"} default location (path to applications folder)
	if (my_location as text) ends with ":Pashua.app:" then
		--found
		exit repeat
	else
		--not found
		beep
		set my_prompt to "Please select the Pashua.app somewhere on your hard drive, or press cancel to stop."
	end if
end repeat


-- Now set the custom path
custom pashua location my_location

-- Show the dialog, the results of the dialog will be shown in the Results-pane
set my_answer to display pashua dialog config_file


-- Do something with the result
say "You are in a " & mood of my_answer & " mood"

if os of my_answer is "macOS" then
	say "I like you."
else if os of my_answer is "Linux" then
	say "You nerd." speaking rate 120 pitch 70
else if os of my_answer is "Windows" then
	say "Developers developers developers" speaking rate 240 pitch 50
else --if os of my_answer is "Other" then
	say "Hmm, very peculiar." pitch 35
end if
