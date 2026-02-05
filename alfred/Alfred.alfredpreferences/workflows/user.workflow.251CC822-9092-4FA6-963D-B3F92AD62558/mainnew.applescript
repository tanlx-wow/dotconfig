on run argv
	set query to item 1 of argv
	set settingsPlist to "settings.plist"
	set workflowFolder to do shell script "pwd"
	set wlib to load script POSIX file (workflowFolder & "/q_workflow.scpt")
	set wf to wlib's new_workflow()
	
	set new_path to wf's get_data()
	set file_path to new_path & settingsPlist
	
	wf's set_value("start", "", settingsPlist)
	
	set cal_name to ""
	set cal_name to wf's get_value("cal_name", settingsPlist)
	if ((cal_name is equal to missing value) or (query is equal to "default")) then
		set c_list to {}
		
		tell application "Calendar"
			activate
			
			set c_calendars to (get every calendar as list)
			repeat with cal in c_calendars
				copy name of cal to end of c_list
			end repeat
			
		end tell
		
		tell application "System Events"
			activate
			if length of c_list is equal to 0 then
				display dialog "Cannot find Calendar. Please, configure Calendar first"
			else
				set cal_name to (choose from list c_list with prompt "Please, select one calendar to use as default one") as string
			end if
		end tell
		
		if cal_name is not equal to "" and cal_name is not equal to "false" then
			wf's set_value("cal_name", cal_name, settingsPlist)
		end if
	end if
	
	if query is equal to "default" then
		if (cal_name is equal to "false") then
			display alert "Nothing changed"
		else
			display alert "New name: " & cal_name
		end if
		return
		
	end if
	
	set me_path to wf's get_path()
	
	
	set script_str to "ruby \"" & me_path & "calendar.rb\" \"" & cal_name & "\" \"" & query & "\""
	
	set temp to (do shell script script_str)
	
	if temp is equal to "ok" then
		set result to "Event created with success!"
	else
		set result to "Could not create the event. Please, check for the correct syntax"
	end if
	
end run