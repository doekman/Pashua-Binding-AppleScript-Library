#!/usr/bin/osascript

-- BUILD ASPashua Library

on do_shell_with_log(naam, cmd)
	set cmdResult to do shell script cmd
	log "SHELL " & naam & ": [" & cmd & "] > [" & cmdResult & "]"
end do_shell_with_log

on get_boolean_default(key_name, default_value)
	try
		return (do shell script "defaults read com.zanstra.ASPashua embed_pashua") is "1"
	on error number 1
		return default_value
	end try
end get_boolean_default

set embed_pashua to get_boolean_default("embed_pashua", false)
set deploy_library to get_boolean_default("deploy_library", true)

set libName to "ASPashua"
set scriptFolder to POSIX path of ((path to me as text) & "::")
set buildFolder to scriptFolder & "build/"
set sourceFolder to scriptFolder & "source/"
set userLibraryFolder to POSIX path of (path to library folder from user domain)
set scriptLibrariesFolder to userLibraryFolder & "Script Libraries/"

set sourceFile to POSIX file (sourceFolder & libName & ".applescript")
set targetFile to POSIX file (buildFolder & libName & ".scptd")

-- CLEAN
set buildPath to quoted form of buildFolder
do_shell_with_log("clean", "rm -R -d -f " & buildPath & "; mkdir " & buildPath)

--| compile and save as script bundle
tell application "Script Editor"
	set libSource to open sourceFile
	if not (compile libSource) then
		error "ERROR: Compilation had error"
	end if
	save libSource as "script bundle" in targetFile with run only
	
	--Hard way to close a document
	--(this didn't work: "close libSource saving no")
	repeat with d in documents
		if name of d is (libName & ".scptd") then
			close d saving no
			exit repeat
		end if
	end repeat
end tell

--| now add the resources (SDEF and binaries)
set sourceResourcesPath to quoted form of POSIX path of (sourceFolder & "Resources/")
set targetResourcesPath to quoted form of POSIX path of ((POSIX path of targetFile) & "/Contents/Resources")
-- use rsync instead of cp, so we can exclude hidden files (--exclude=".*")
do_shell_with_log("resources", "rsync -av --exclude='.*' " & sourceResourcesPath & space & targetResourcesPath)

if embed_pashua then
	--| First lookup binary
	set pashua_binary to missing value
	repeat with pashua_location in [path to applications folder from user domain, path to applications folder from local domain]
		set app_location to (pashua_location as text) & "Pashua.app"
		tell application "Finder"
			if alias app_location exists then
				set pashua_binary to (my POSIX path of alias app_location)
			end if
		end tell
	end repeat
	if pashua_binary is missing value then
		error "Can't locate Pashua.app. Please put it in /Applications or ~/Applications"
	end if
	--| finally copy Pashua.app, first trim the trailing "/" of pashua_binary
	set pashua_binary to text 1 thru ((length of pashua_binary) - 1) of pashua_binary
	set pashuaSource to quoted form of pashua_binary
	set pashuaTargetPath to quoted form of POSIX path of ((POSIX path of targetFile) & "/Contents/Resources/bin")
	do_shell_with_log("embed_pashua", "cp -R " & pashuaSource & space & pashuaTargetPath)
end if

--| update the Info.plist with the custom one
set infoPlistSource to quoted form of ((POSIX path of sourceFolder) & "Info.plist")
set infoPlistTarget to quoted form of ((POSIX path of targetFile) & "/Contents")
do_shell_with_log("info.plist", "cp -f " & infoPlistSource & space & infoPlistTarget)


if deploy_library then
	--| install in Script Libraries (create folder when it doesn't exist; remove library first, to prevent merging of package)
	set deploySource to quoted form of POSIX path of targetFile
	set deployDestinationFile to quoted form of (scriptLibrariesFolder & libName & ".scptd")
	set deployDestination to quoted form of scriptLibrariesFolder
	do_shell_with_log("deploy", "mkdir " & deployDestination & "; rm -R -f " & deployDestinationFile & "; cp -R " & deploySource & space & deployDestination)
end if

--| and we're done.
if deploy_library then
	set message to "The scripting library has been build and installed."
else
	set message to "The scripting library has been build."
end if
if embed_pashua then set message to message & " Pashua.app has been embedded."
display notification message with title libName & " Library"
