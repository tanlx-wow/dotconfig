on run argv
	set c_calendar_name to item 1 of argv
	set c_description to item 2 of argv
	set c_year to item 3 of argv
	set c_month to item 4 of argv
	set c_day to item 5 of argv
	set c_hours to item 6 of argv
	set c_minutes to item 7 of argv
	set c_duration to item 8 of argv
	
	set c_location to ""
	set c_all_day_flag to false
	
	if (length of argv > 8) then
		set c_location to item 9 of argv
	end if
	
	if (length of argv > 9) then
		if (item 10 of argv) is equal to "true" then
			set c_all_day_flag to true
		end if
	end if
	
	try
		set c_date to current date
		set day of c_date to c_day
		set month of c_date to c_month
		set year of c_date to c_year
		set hours of c_date to c_hours
		set minutes of c_date to c_minutes
	on error errText number errNum
		return "nok"
	end try
	
	set recur to false
	if (length of argv > 10) then
		set n_of_items to ((length of argv) - 10)
		set counter to 0
		set counter_recur to 0
		repeat
			set cur_item to item (11 + counter) of argv
			set offitemindex to offset of "-" in cur_item
			
			if offitemindex is equal to 0 then
				if counter_recur is equal to 0 then
					set recur to ("FREQ=" & cur_item)
					set counter_recur to 1
				else
					set recur to recur & ";" & cur_item
				end if
			end if
			
			set counter to (counter + 1)
			if counter is equal to n_of_items then
				exit repeat
			end if
			
		end repeat
	end if
	
	tell application "Calendar"
		activate
		delay 2
		
		try
			if c_calendar_name is not equal to "" then
				if recur is not false then
					set newEvent to make new event in calendar c_calendar_name with properties {summary:c_description, start date:c_date, end date:c_date + c_duration * minutes, location:c_location, allday event:c_all_day_flag, recurrence:recur}
				else
					set newEvent to make new event in calendar c_calendar_name with properties {summary:c_description, start date:c_date, end date:c_date + c_duration * minutes, location:c_location, allday event:c_all_day_flag}
				end if
				
			else
				if recur is not false then
					set newEvent to make new event at end with properties {summary:c_description, start date:c_date, end date:c_date + c_duration * minutes, location:c_location, allday event:c_all_day_flag, recurrence:recur}
				else
					set newEvent to make new event at end with properties {summary:c_description, start date:c_date, end date:c_date + c_duration * minutes, location:c_location, allday event:c_all_day_flag}
				end if
			end if
			
			
			if (length of argv > 10) then
				set n_of_alarms to ((length of argv) - 10)
				set counter to 0
				repeat
					set current_interval to item (11 + counter) of argv
					set offindex to offset of "-" in current_interval
					
					if offindex is greater than 0 then
						set theAlarm1 to make new sound alarm at end of sound alarms of newEvent with properties {trigger interval:current_interval, sound name:"Sosumi"}
					end if
					
					
					set counter to (counter + 1)
					
					if counter is equal to n_of_alarms then
						exit repeat
					end if
				end repeat
			end if
		on error errText number errNum
			set result to "nok"
		end try
		
		set result to "ok"
		
		
	end tell
end run