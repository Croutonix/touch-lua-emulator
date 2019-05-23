draw = require("draw")    -- Import draw library
sys = require("sys")      -- Import system library

function love.run()
	local config = require("config")  -- Read settings
	apply_settings(config) -- Apply settings

	-- Get file to run
	local file_name
	if config.file_name ~= "" then
		file_name = config.file_name
	elseif arg[1] then
		file_name = arg[1]
	else
		file_name = ""
	end
	
	-- Run program to emulate if file exist
	local f = io.open(file_name)
	if f then
		dofile(file_name)
	else
		print("No file or file doesn't exist")
	end
	
	-- Press any key to continue
	draw.setscreen(0)
	print() 
	os.execute("pause")
end

-- Pause the program for a given time
function sleep(ms)
	draw.sleep(ms)
end