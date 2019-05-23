----------[[ SYSTEM LIBRARY ]]----------
local sys = {}

local alert_cache = {}
local alertdir = "res/sound/"

-- Print without adding new line
function sys.print(...)
	local arg = {...}
	local result = ""
  for i, v in ipairs(arg) do
    result = result .. tostring(v) 
		if i ~= #arg then result = result .. "\t" end
  end
	io.write(result)
end

-- Print by adding new line
function sys.println(...)
	sys.print(...)
	io.write("\n")
end

-- Input
function sys.input(input)
	io.write(input)
	return io.read()
end

-- Clear text screen
function sys.clear()
	os.execute("cls")
end

-- Wait a certain amount of time (ms)
function sys.sleep(values)
	love.timer.sleep(ms/1000)
end

-- Change cursor position
function sys.locate(row, column)
	-- Not implanted
end

-- Play alert sounds
function sys.alert(tone)
	local alert
	if alert_cache[tone] then
		alert = alert_cache[tone]
	else
		local file = io.open(alertdir..tone..".mp3", "rb")
		if not file then return end
		local content = file:read("*a")
		local data, err = love.filesystem.newFileData(content, tone..".mp3")
		local sound = love.sound.newSoundData(data)
		alert = love.audio.newSource(sound)
		alert_cache[tone] = alert
	end
	love.audio.play(alert)
end

-- Play alert sounds
function sys.gettime()
	return love.timer.getTime( )
end

-- Return table of filenames
function sys.dir(path)
	-- Not implanted
	return {}
end

return sys