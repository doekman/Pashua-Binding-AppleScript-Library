use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

global pashua_binary
global log_to_file

--| custom pashua location
on «event PASHCMPL» new_path
	global pashua_path
	
	tell application "Finder"
		if not (new_path exists) then
			error "New path to Pashua.app does not exist" number 1003
		end if
	end tell
	init_library_stuff()
	set pashua_binary to (POSIX path of new_path) & "Contents/MacOS/Pashua"
end «event PASHCMPL»


--| display pashua dialog
on «event PASHDIDI» config
	-- Get path to Pashua binary
	set pashua_binary to get_pashua_path()
	
	-- Call with either text or alias
	if class of config is text then
		set pashua_cmd to "echo " & quoted form of config & " | " & quoted form of pashua_binary & " -"
	else if class of config is alias then
		set pashua_cmd to quoted form of pashua_binary & space & quoted form of POSIX path of config
	else
		error "Call this method with either 'text' of 'alias', not with '" & (class of config) & "'" number 1000
	end if
	
	-- Call pashua
	set pashua_res to do_shell_with_log("display pashua dialog", pashua_cmd)
	
	set result_lines to split_string(pashua_res, return)
	
	-- There was an error in the config
	if (count of result_lines) is 0 then error "It looks like Pashua.app had some problems using the window configuration." number 1001
	
	-- User pressed cancel
	if (count of result_lines) is 1 then error number -128 --user canceled 
	
	-- Everything went fine
	set record_result to ini_to_record(result_lines)
	return record_result
	
end «event PASHDIDI»

--| display multi dialog
on «event PASHDIMD» introductionText given «class Qsnl»:questionLabels : missing value, «class Dfta»:defaultAnswers : missing value, «class Eltt»:elementTypes : missing value, «class Wttl»:titleText : missing value
	set configLines to {}
	if titleText is not missing value then set configLines to configLines & {"*.title = " & titleText}
	if introductionText is not missing value and introductionText ≠ "" then set configLines to configLines & {"intro.type = text", "intro.text = " & replace_text(linefeed, "[return]", introductionText)}
	if questionLabels is not missing value or defaultAnswers is not missing value or elementTypes is not missing value then
		# we need to create some input fields
		if elementTypes is missing value then
			if defaultAnswers is missing value then
				set elementTypes to inferElementTypes(questionLabels)
			else
				set elementTypes to inferElementTypes(defaultAnswers)
			end if
		end if
		appendFieldsToConfig(configLines, questionLabels, defaultAnswers, elementTypes)
	end if
	set config to join_list(configLines, linefeed)
	display dialog "This is the generated config" default answer config
	return «event PASHDIDI» config
end «event PASHDIMD»

on appendFieldsToConfig(configLines, questionLabels, defaultAnswers, elementTypes)
	set codeToType to {EChk:"checkbox", EDte:"date", ETme:"date", EDtm:"date", EPwd:"password", MPwd:"password", ETbx:"textbox", MTbx:"textbox", ETfd:"textfield", MTfd:"textfield"}
	set the codeToTypeDict to current application's NSDictionary's dictionaryWithDictionary:codeToType
	repeat with i from 1 to count of elementTypes
		set fieldName to "field" & i
		set elementType to item i of elementTypes
		set elementCode to text 8 thru 11 of (elementType as text) #«class xxxx»
		set elementValue to (codeToTypeDict's valueForKey:elementCode)
		set pashuaType to elementValue as text
		copy (fieldName & ".type = " & pashuaType) to the end of configLines
		if elementCode starts with "M " then
			copy (fieldName & ".mandatory = 1") to the end of configLines
		end if
		if pashuaType is "date" then
			copy (fieldName & ".textual = 1") to the end of configLines
			if elementCode is "EDtm" then --datetime
				copy (fieldName & ".time = 1") to the end of configLines
			end if
			if elementCode is "ETme" then --time
				copy (fieldName & ".date = 0") to the end of configLines
				copy (fieldName & ".time = 1") to the end of configLines
			end if
		end if
		if questionLabels is not missing value then
			set questionLabel to item i of questionLabels
			copy (fieldName & ".label = " & questionLabel) to the end of configLines
		else if pashuaType is "checkbox" then
			copy (fieldName & ".label = " & fieldName) to the end of configLines
		end if
		if defaultAnswers is not missing value then
			set defaultAnswer to item i of defaultAnswers
			--TODO: convert to text in right format
			copy (fieldName & ".default = " & defaultAnswer) to the end of configLines
		end if
	end repeat
end appendFieldsToConfig

on inferElementTypes(fieldValues as list)
	set inferedElementTypes to {}
	repeat with fieldValue in fieldValues
		if class of fieldValue is boolean then
			copy «class EChk» to the end of inferedElementTypes #checkbox
		else if class of fieldValue is date then
			if time of fieldValue is 0 then
				copy «class EDte» to the end of inferedElementTypes #date
			else
				copy «class EDtm» to the end of inferedElementTypes #datetime
			end if
		else
			copy «class ETfd» to the end of inferedElementTypes #textfield
		end if
	end repeat
	return inferedElementTypes
end inferElementTypes

-- Private handlers ---------------------------------------------------------------------

--| Parses Pashua's output to a AppleScript record
on ini_to_record(ini_lines as list)
	local result_dictionary, pos, key_string, value_string
	set number_of_lines to count of ini_lines
	set result_dictionary to current application's NSMutableDictionary's dictionaryWithCapacity:number_of_lines
	repeat with text_line in ini_lines
		set pos to offset of "=" in text_line
		set key_string to text 1 thru (pos - 1) of text_line
		if (count of text_line) ≤ pos then
			set value_string to "" --use empty string, because missing value won't show up in record
		else
			set value_string to text (pos + 1) thru (length of text_line) of text_line
		end if
		(result_dictionary's setValue:value_string forKey:key_string)
	end repeat
	return result_dictionary as record
end ini_to_record

on get_pashua_path()
	global pashua_binary
	try
		return pashua_binary
	on error number -2753
		--The variable <pashua_path> is not defined; first:
		init_library_stuff()
		-- now look for a reference to the Pashua binary
		try
			set app_location to path to resource "Pashua.app" in directory "bin" as text
			return (POSIX path of app_location) & "Contents/MacOS/Pashua"
		on error number -192
			--A resource wasn’t found.
			repeat with pashua_location in [path to applications folder from user domain, path to applications folder from local domain]
				set app_location to (pashua_location as text) & "Pashua.app:"
				tell application "Finder"
					if alias app_location exists then
						set pashua_binary to (my POSIX path of alias app_location) & "Contents/MacOS/Pashua"
						return pashua_binary
					end if
				end tell
			end repeat
		end try
		error "Can't locate the path of Pashua.app. Download it from http://www.bluem.net/files/Pashua.dmg and save it in the 'Applications' folder." number 1002
	end try
end get_pashua_path

--| Utilities

to join_list(aList as list, delimiter as text)
	local sourceList, res
	set the sourceList to current application's NSArray's arrayWithArray:aList
	set res to sourceList's componentsJoinedByString:delimiter
	return res as text
end join_list

to split_string(aString as text, delimiter as text)
	local sourceString, res
	if aString is "" then return {} --special case
	set the sourceList to current application's NSString's stringWithString:aString
	set res to sourceList's componentsSeparatedByString:delimiter
	return res as list
end split_string

on replace_text(searchString as text, replacementString as text, sourceText)
	local sourceString, adjustedString
	if sourceText is missing value then
		return sourceText
	end if
	set the sourceString to current application's NSString's stringWithString:sourceText
	set the adjustedString to the sourceString's stringByReplacingOccurrencesOfString:searchString withString:replacementString
	return adjustedString as text
end replace_text


--| Executes a shell command, and logs before and after
on do_shell_with_log(title, command)
	do_log(title & " COMMAND [" & command & "]")
	set shell_result to do shell script command
	do_log(title & " RESULT [" & command & "]")
	return shell_result
end do_shell_with_log

--| Log a line of text to ~/Library/Logs/AppleScript/ASPashua.log
on do_log(log_message)
	if log_to_file then
		set log_sh to path to resource "log.sh" in directory "bin"
		set log_name to "ASPashua" --name of logfile
		--set log_message to replaceText(return, linefeed, log_message)
		set cmd to (quoted form of the POSIX path of log_sh) & space & (quoted form of log_name) & space & (quoted form of log_message)
		do shell script cmd
	end if
end do_log

on init_library_stuff()
	try
		set log_to_file to (do shell script "defaults read com.zanstra.ASPashua do_log") is "1"
	on error number 1
		set log_to_file to false
	end try
end init_library_stuff
