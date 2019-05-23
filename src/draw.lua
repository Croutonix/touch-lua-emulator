----------[[ DRAW LIBRARY ]]----------
local draw = {}

----------- VARIABLES AND CONSTANTS -----------
-- Define colors
draw.white     = {1.00, 1.00, 1.00, 1.00}
draw.black     = {0.00, 0.00, 0.00, 1.00}
draw.red       = {1.00, 0.00, 0.00, 1.00}
draw.green     = {0.00, 1.00, 0.00, 1.00}
draw.blue      = {0.00, 0.00, 1.00, 1.00}
draw.cyan      = {0.00, 1.00, 1.00, 1.00}
draw.magenta   = {1.00, 0.00, 1.00, 1.00}
draw.orange    = {1.00, 0.50, 0.00, 1.00}
draw.purple    = {0.50, 0.00, 0.50, 1.00}
draw.yellow    = {1.00, 1.00, 0.00, 1.00}
draw.brown     = {0.60, 0.40, 0.20, 1.00}
draw.gray      = {0.50, 0.50, 0.50, 1.00}
draw.darkgray  = {0.33, 0.33, 0.33, 1.00}
draw.lightgray = {0.66, 0.66, 0.66, 1.00}

-- Screen
local screen_size, zoom, screen, canvas
local window_title = ""  -- Default window title

-- Refresh
local auto_refresh, old_auto_refresh, antialias

-- Events
local pressed_action, moved_action, released_action  -- Functions to call in case of an event
local ispressed = false  -- Is mouse pressed
local paused, resume_at = false, nil  -- Used for draw.waittouch()

-- Fonts
local fontdir = "res/font/"  -- Folder containing fonts
local font, default_font  -- Used to save current font
local fonts  -- Contains font matches
local font_cache = {}  -- Use to prevent rendering the same font again

-- Others
local lastX, lastY = {0}, {0}  -- Last lineto position
local line_width, line_join, line_style

----------- SCREEN FUNCTIONS -----------
-- Change between graphics and text mode
function draw.setscreen(n)
	if n == 0 then
		screen = 0
		love.window.close()
	elseif n == 1 then
		screen = 1
		setscreensize()  -- Set inital window size
		
		local s = screen_size
		canvas = love.graphics.newCanvas(math.max(s[2][1], s[2][2]), math.max(s[1][1], s[1][2]))  -- New canvas
		love.graphics.setCanvas(canvas)  -- Set render target to canvas
		draw.settitle(window_title)  -- Set title to current
		draw.clear()  -- Clear screen with white
		draw.refresh()
	end
end

-- Set graphics screen title
function draw.settitle(title)
	if screen == 0 then return end
	window_title = title
	love.window.setTitle(window_title)
end

-- Clear the screen
function draw.clear(color)
	if screen == 0 then return end
	if not color then color = draw.white end
	love.graphics.clear(convertcolor(color))
	if auto_refresh then draw.refresh() end
end

-- Return screen resolution
function draw.getsize()
    local _, _, flags = love.window.getMode()
    local w, h = love.window.getDesktopDimensions(flags.display)
	return w, h
end

-- Return viewable screen size
function draw.getport()
	return screen_size[orientation+1][1], screen_size[orientation+1][2]
end


----------- DRAW FUNCTIONS -----------
-- Draw string
function draw.string(text, x, y, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))
	love.graphics.print(text, x, y)
	if auto_refresh then draw.refresh() end
end

-- Draw string centered in rectangle
function draw.stringinrect(text, x1, y1, x2, y2, color)
	if screen == 0 then return end
	local w, h = draw.stringsize(text)
	local x, y = x1 + (x2-x1)/2 - w/2, y1 + (y2-y1)/2 - h/2
	love.graphics.setColor(convertcolor(color))
	love.graphics.print(text, x, y)
	if auto_refresh then draw.refresh() end
end

---------------------
-- Draw point
function draw.point(x, y, color)
	if screen == 0 then return end
	n = line_width/2
	if line_join == "round" then
		draw.fillcircle(x, y, n, color)
	else
		draw.fillrect(x-n, y-n, x+n, y+n, color)
	end
	if auto_refresh then draw.refresh() end
end

---------------------
-- Move current point to coordinate
function draw.moveto(x, y)
	lastX, lastY = {x}, {y}
end

-- Draw line from current point to coordinate
function draw.lineto(x, y, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))
	if lastX[2] then
		love.graphics.line(lastX[2],lastY[2],  lastX[1],lastY[1],  x,y)
	else
		love.graphics.line(lastX[1],lastY[1],  x,y)
	end
	if line_style == "round" then
		love.graphics.circle("fill", lastX[1], lastY[1], line_width/2)
		love.graphics.circle("fill", x, y, line_width/2)
	end
	lastX, lastY = {x, lastX[1]}, {y, lastY[1]}
	if auto_refresh then draw.refresh() end
end

-- Draw line
function draw.line(x1, y1, x2, y2, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.line(x1, y1, x2, y2)
	if auto_refresh then draw.refresh() end
end

---------------------
-- Draw rectangle
function draw.rect(x1, y1, x2, y2, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.rectangle("line", x1, y1, x2-x1, y2-y1)
	if auto_refresh then draw.refresh() end
end

-- Draw filled rectangle
function draw.fillrect(x1, y1, x2, y2, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.rectangle("fill", x1, y1, x2-x1, y2-y1)
	if auto_refresh then draw.refresh() end
end

---------------------
-- Draw circle
function draw.circle(x, y, r, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.circle("line", x, y, r)	
	if auto_refresh then draw.refresh() end
end

-- Draw filled circle
function draw.fillcircle(x, y, r, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.circle("fill", x, y, r)
	if antialias then
		local w = line_width
		love.graphics.setLineWidth(1)
		love.graphics.circle("line", x, y, r)
		love.graphics.setLineWidth(line_width)
	end
	if auto_refresh then draw.refresh() end
end

---------------------
-- Draw arc
function draw.arc(x, y, r, start_angle, end_angle, color)
	if screen == 0 then return end
	love.graphics.setLineJoin("miter")
	if start_angle > end_angle then end_angle = end_angle + 2*math.pi end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.arc("line", "pie", x, y, r, start_angle, end_angle)
	if auto_refresh then draw.refresh() end
	love.graphics.setLineJoin(line_join)
end

-- Draw filled arc
function draw.fillarc(x, y, r, start_angle, end_angle, color)
	if screen == 0 then return end
	if start_angle > end_angle then end_angle = end_angle + 2*math.pi end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.arc("fill", "pie", x, y, r, start_angle, end_angle)
	if antialias then
		local w = line_width
		love.graphics.setLineWidth(1)
		love.graphics.arc("line", "pie", x, y, r, start_angle, end_angle)
		love.graphics.setLineWidth(line_width)
	end
	if auto_refresh then draw.refresh() end
end

---------------------
-- Draw ellipse
function draw.ellipse(x1, y1, x2, y2, color)
	if screen == 0 then return end
	xr, yr = (x2-x1)/2, (y2-y1)/2
	love.graphics.setColor(convertcolor(color))	
	love.graphics.ellipse("line", x1+xr, y1+yr, xr, yr)	
	if auto_refresh then draw.refresh() end
end

-- Draw filled ellipse
function draw.fillellipse(x1, y1, x2, y2, color)
	if screen == 0 then return end
	xr, yr = (x2-x1)/2, (y2-y1)/2
	love.graphics.setColor(convertcolor(color))	
	love.graphics.ellipse("fill", x1+xr, y1+yr, xr, yr)
	if antialias then
		local w = line_width
		love.graphics.setLineWidth(1)
		love.graphics.ellipse("line", x1+xr, y1+yr, xr, yr)
		love.graphics.setLineWidth(line_width)
	end
	if auto_refresh then draw.refresh() end
end

---------------------
-- Draw polygon
function draw.polygon(x, y, r, sides, rotation, color)
	if screen == 0 then return end
	love.graphics.setLineJoin("miter")
	local points = {}
	for i = 1, sides do
		local angle = (i/sides)*(2*math.pi) - rotation
		local px = math.cos(angle)*r + x
		local py = math.sin(angle)*r + y
		points[i*2-1], points[i*2] = px, py
	end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.polygon("line", points)
	if auto_refresh then draw.refresh() end
	love.graphics.setLineJoin(line_join)	
end

-- Draw filled polygon
function draw.fillpolygon(x, y, r, sides, rotation, color)
	if screen == 0 then return end
	local points = {}
	for i = 1, sides do
		local angle = (i/sides)*(2*math.pi) - rotation
		local px = math.cos(angle)*r + x
		local py = math.sin(angle)*r + y
		points[i*2-1], points[i*2] = px, py
	end
	love.graphics.setColor(convertcolor(color))	
	love.graphics.polygon("fill", points)
	if antialias then
		local w = line_width
		love.graphics.setLineWidth(1)
		love.graphics.polygon("line", points)
		love.graphics.setLineWidth(line_width)
	end
	if auto_refresh then draw.refresh() end	
end

---------------------
-- Draw star
function draw.star(x, y, inr, outr, vertices, rotation, color)
	if screen == 0 then return end
	love.graphics.setLineJoin("miter")

  local pts = {}	
  local rot = -rotation
  local step = math.pi/vertices
  for i = 1, vertices do
    pts[#pts+1] = x + math.cos(rot)*outr
    pts[#pts+1] = y + math.sin(rot)*outr
    rot = rot + step

    pts[#pts+1] = x + math.cos(rot)*inr
    pts[#pts+1] = y + math.sin(rot)*inr
    rot = rot + step
  end
	
	love.graphics.setColor(convertcolor(color))
	love.graphics.polygon("line", pts)
	if auto_refresh then draw.refresh() end
	love.graphics.setLineJoin(line_join)
end

-- Draw filled star
function draw.fillstar(x, y, inr, outr, vertices, rotation, color)
	if screen == 0 then return end
	love.graphics.setLineJoin("miter")

  local pts = {}	
  local rot = -rotation
  local step = math.pi/vertices
  for i = 1, vertices do
    pts[#pts+1] = x + math.cos(rot)*outr
    pts[#pts+1] = y + math.sin(rot)*outr
    rot = rot + step

    pts[#pts+1] = x + math.cos(rot)*inr
    pts[#pts+1] = y + math.sin(rot)*inr
    rot = rot + step
  end
	
	love.graphics.setColor(convertcolor(color))
	local triangles = love.math.triangulate(pts)
	for i, t in ipairs(triangles)	do
		love.graphics.polygon("fill", t[1], t[2], t[3], t[4], t[5], t[6])
	end
	if antialias then
		local w = line_width
		love.graphics.setLineWidth(1)
		love.graphics.polygon("line", pts)
		love.graphics.setLineWidth(line_width)
	end
	
	if auto_refresh then draw.refresh() end
	love.graphics.setLineJoin(line_join)
end

---------------------
-- Draw triangle
function draw.triangle(x1, y1, x2, y2, x3, y3, color)
	if screen == 0 then return end
	love.graphics.setLineJoin("miter")
	love.graphics.setColor(convertcolor(color))
	love.graphics.polygon("line", x1, y1, x2, y2, x3, y3)
	if auto_refresh then draw.refresh() end
	love.graphics.setLineJoin(line_join)
end

-- Draw filled triangle
function draw.filltriangle(x1, y1, x2, y2, x3, y3, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))
	love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
		if antialias then love.graphics.polygon("line", x1, y1, x2, y2, x3, y3) end
	if auto_refresh then draw.refresh() end
end

---------------------
-- Draw rounded rectangle
function draw.roundedrect(x1, y1, x2, y2, r, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))
	love.graphics.arc("line", "open", x2-r, y2-r, r, 0,           math.pi*0.5)  -- Bot right
	love.graphics.arc("line", "open", x1+r, y2-r, r, math.pi*0.5, math.pi*1.0)  -- Bot left
	love.graphics.arc("line", "open", x1+r, y1+r, r, math.pi*1.0, math.pi*1.5)  -- Top right
	love.graphics.arc("line", "open", x2-r, y1+r, r, math.pi*1.5, math.pi*2.0)  -- Top left
	love.graphics.line(x1+r, y1, x2-r, y1)  -- Top
	love.graphics.line(x1+r, y2, x2-r, y2)  -- Bottom
	love.graphics.line(x1, y1+r, x1, y2-r)  -- Left
	love.graphics.line(x2, y1+r, x2, y2-r)  -- Right
	if auto_refresh then draw.refresh() end
end

-- Draw filled rounded rectangle
function draw.fillroundedrect(x1, y1, x2, y2, r, color)
	if screen == 0 then return end
	love.graphics.setColor(convertcolor(color))
	love.graphics.arc("fill", "pie", x2-r, y2-r, r, 0,           math.pi*0.5)  -- Bot right
	love.graphics.arc("fill", "pie", x1+r, y2-r, r, math.pi*0.5, math.pi*1.0)  -- Bot left
	love.graphics.arc("fill", "pie", x1+r, y1+r, r, math.pi*1.0, math.pi*1.5)  -- Top right
	love.graphics.arc("fill", "pie", x2-r, y1+r, r, math.pi*1.5, math.pi*2.0)  -- Top left
	love.graphics.rectangle("fill", x1+r, y1, x2-x1-2*r, r)            -- Top
	love.graphics.rectangle("fill", x1+r, y2-r, x2-x1-2*r, r)          -- Bottom
	love.graphics.rectangle("fill", x1, y1+r, r, y2-y1-2*r)            -- Left
	love.graphics.rectangle("fill", x2-r, y1+r, r, y2-y1-2*r)          -- Right
	love.graphics.rectangle("fill", x1+r, y1+r, x2-x1-2*r, y2-y1-2*r)  -- Center
	if auto_refresh then draw.refresh() end
end


----------- DRAW PARAMETERS AND OTHER -----------
-- Return drawn string size
function draw.stringsize(text)
	local w = font:getWidth(text)
	local h = font:getHeight()
	return w, h
end

-- Set font face and size
function draw.setfont(name, size)
	name = fonts[name]
	if name == nil then name = fonts[default_font] end
	
	if font_cache[name] and font_cache[name][size] then
		font = font_cache[name][size]
	else
		local file = io.open(fontdir..name, "rb")
		local content = file:read("*a")
		local data, err = love.filesystem.newFileData(content, name)
		font = love.graphics.newFont(data, size)
		
		if not font_cache[name] then font_cache[name] = {} end
		font_cache[name][size] = font
	end
	love.graphics.setFont(font)
end

-- Set line width and ending
function draw.setlinestyle(width, style)
	line_width, line_style = width, style
	love.graphics.setLineWidth(line_width)  -- Set line width
	 
	if style == "square" then  -- Set line join/style
		love.graphics.setLineJoin("miter")  -- Square
		line_join = "miter"
	else  
		love.graphics.setLineJoin("none")   -- Butt/round
		line_join = "none"
	end
end

-- Toggle antialias
function draw.setantialias(flag)
	antialiasing = flag
	if antialiasing ~= true and antialiasing ~= false then antialiasing = true end
	if antialiasing then
		love.graphics.setLineStyle("smooth")  
	else
		love.graphics.setLineStyle("rough")
	end
end

-- Get antialias state
function draw.getantialias()
	return antialiasing
end


----------- TIME FUNCTIONS -----------
-- Wait a certain amount of time
function draw.sleep(ms)
	love.timer.sleep(ms/1000)
end

-- Return system time in seconds
function draw.gettime()
	return love.timer.getTime( )
end


----------- DISPLAY FUNCTIONS -----------
-- Display current frame 
function draw.refresh()
	if screen == 0 then return end
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.origin()
	love.graphics.setCanvas()       -- Set target to screen
	love.graphics.draw(canvas, 0, 0, 0, zoom)  -- Draw canvas to screen
	love.graphics.present()         -- Refresh screen
	love.graphics.setCanvas(canvas) -- Set target to canvas
end

-- Disable auto refresh until draw.endframe()
function draw.beginframe()
	old_auto_refresh = auto_refresh
	auto_refresh = false
end

-- Display frame and reenable auto refresh
function draw.endframe()
	auto_refresh = old_auto_refresh
	draw.refresh()
end

-- Enable auto screen refresh
function draw.enablerefresh()
	auto_refresh = true
end

-- Disable auto screen refresh
function draw.disablerefresh()
	auto_refresh = false
end


----------- EVEMT FUNCTIONS -----------
-- Wait for user to make touch
function draw.waittouch()
	if screen == 0 then return end
	paused = true
	while paused do
		draw.doevents()
	end
	return resume_at[1], resume_at[2]
end

-- Touch handling
function draw.tracktouches(p, m, r)
	if screen == 0 then return end
	pressed_action, moved_action, released_action = p, m, r  -- Save function
end

-- Call function related to touches
function draw.doevents(bool)
	if screen == 0 then return end
	if bool == nil then bool = true end  -- if bool == false then doevents is used for exit
	
	if love.event then
		love.event.pump()
		for event, a,b,c,d,e,f in love.event.poll() do
			if bool then 
				if event == "mousepressed" then  -- Mouse pressed
					ispressed = true
					local x, y = math.floor((a/zoom)+0.5), math.floor((b/zoom)+0.5)
					if pressed_action then pressed_action(x, y) end
					
					if paused then
						paused = false
						resume_at = {x, y}
					end
				end
				
				if ispressed and event == "mousemoved" then  -- Mouse moved while pressed
					local x, y = math.floor((a/zoom)+0.5), math.floor((b/zoom)+0.5)
					if moved_action then moved_action(x, y) end
				end
			
				if event == "mousereleased" then  -- Mouse released
					ispressed = false
					local x, y = math.floor((a/zoom)+0.5), math.floor((b/zoom)+0.5)
					if released_action then released_action(x, y) end
				end
			end
			
			if event == "keypressed" then keypressed(a, b, c) end  -- Key pressed
		end
	end
end

-- Reset events
function draw.clearevents()
	pressed_action, moved_action, released_action = nil, nil, nil
end

----------- EMULATOR-SPECIFIC FUNCTIONS -----------
-- Set appropriate window size
function setscreensize()
	if screen ~= 0 then
		local w, h = draw.getport()
		w, h = w*zoom, h*zoom  -- Apply zoom to window size
		love.graphics.setCanvas()
		love.window.setMode(w, h, {resizable=false, centered=true, vsync=true})  -- Set window size and position
		love.graphics.setCanvas(canvas)
	end
end

-- Key is pressed
function keypressed(key, scancode, isrepeat)
	if not isrepeat then
		-- Zoom in and out
		local oldzoom = zoom
		if key == "=" and zoom < 2 then zoom = zoom + 0.1 end    -- Zoom in
		if key == "-" and zoom > 0.5 then zoom = zoom - 0.1 end  -- Zoom out
		if key == "0" then zoom = 1 end                          -- Default zoom
		if zoom ~= oldzoom then apply_zoom(zoom) end
		
		-- Swap between orientations
		if key == "return" then apply_orientation(1 - orientation) end  

		-- Quit
		if key == "escape" then
			draw.setscreen(0)
			print("Program Break:")
			print("Interrupted by user")
			print() os.execute("pause")  -- Press any key to continue
			os.exit()
		end
	end
end

-- Set screen zoom
function apply_zoom(n)
	zoom = n
	setscreensize() -- Apply new window size
	draw.refresh()
end

-- Set screen orientation
function apply_orientation(n)
	orientation = n
	setscreensize()  -- Apply new orientation
	draw.refresh()
end

-- Convert color from 0-100% to 0-255
function convertcolor(c)
	return c[1]*255, c[2]*255, c[3]*255, c[4]*255
end

-- Apply settings
function apply_settings(config)
	screen_size = {config.portrait_size, config.landscape_size}
	antialias, auto_refresh = config.antialias, config.auto_refresh
	
	line_style = config.line_cap
	draw.setlinestyle(config.line_width, config.line_cap)
	
	fonts = config.fonts
	draw.setfont(config.font_name, config.font_size)
	default_font = config.font_name
	
	draw.setscreen(config.screen)
	draw.settitle(config.window_title)
	
	zoom, orientation = config.zoom, config.orientation
	if orientation == "portrait" then orientation = 0 end
	if orientation == "landscape" then orientation = 1 end
	apply_orientation(orientation)
	apply_zoom(zoom)
end

return draw