local config = {
	file_name = "example.lua";  -- File to run on execution (leave blank for drag and drop)
	
	----- SCREEN SIZE OPTIONS -----
	portrait_size = {320, 460};   -- Screen viewable size on portrait orientation
	landscape_size = {480, 300};  -- Screen viewable size on landscape orientation
	
	----- DRAW & SCREEN OPTIONS (default values) -----
	antialias = true;          -- Default antialias value
	auto_refresh = true;       -- Default auto refresh value
	
	line_width = 1;            -- Default line width
	line_cap = "round";        -- Default line cap/join
	
	screen = 0;                -- Default screen on execution (0=console / 1=draw)
	orientation = "portrait";  -- Default screen orientation (portrait/landscape)
	zoom = 1;                  -- Default screen zoom (Between 0.5 and 2)
	window_title = "";         -- Default window title
	
	----- FONT OPTIONS -----
	font_name = "Helvetica";   -- Default font face
	font_size = 20;            -- Default font size
	
	-- Match fonts on your device with equivalent fonts on your computer
	-- Fonts must be placed in res/font folder
	-- Unmatched font will be set to default font
	fonts = {
		["Helvetica"]              = "segoeui.ttf";   -- Helvetica = Segoe UI
		["Helvetica-Bold"]         = "segoeuib.ttf";
		["Helvetica-Oblique"]      = "segoeuii.ttf";
		["Helvetica-Light"]        = "segoeuil.ttf";
		["Helvetica-BoldOblique"]  = "segoeuiz.ttf";
		["Helvetica-LightOblique"] = "seguili.ttf";
		["Times New Roman"]        = "times.ttf";     -- Times New Roman
		["Avenir"]                 = "calibri.ttf";   -- Avenir = Calibri
		["Chalkboard SE"]          = "comic.ttf";     -- Chalkboard SE = Comic Sans MS
		["Courier New"]            = "cour.ttf";      -- Courier New
		["Verdana"]                = "verdana.ttf";   -- Verdana
	}
}

return config