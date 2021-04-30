-- license:BSD-3-Clause

interface = load_interface("fdes2100d")

function interface.setdigit(d)
	d = tonumber(d)
	if (d == 0) then sb_press_square(":board", 0.5, 2, 1)
	elseif (d == 9) then sb_press_square(":board", 0.5, 2, 8)
	else sb_press_square(":board", 0.5, 1, d)
	end
end

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = interface.level:sub(2, 2)
	send_input(":IN.0", 0x10, 0.5)  -- LEVEL
	if (level:len() == 2) then
		sb_press_square(":board", 0.5, x, y)
	else
		level = level:sub(3)
		y = 1
		while (level ~= "") do
			sb_press_square(":board", 0.5, x, y)
			interface.setdigit(level:sub(1,1))
			interface.setdigit(level:sub(3,3))
			interface.setdigit(level:sub(4,4))
			sb_press_square(":board", 0.5, x, y+1)
			interface.setdigit(level:sub(6,6))
			interface.setdigit(level:sub(7,7))
			level = level:sub(9)
			y = y + 2
		end
	end
	send_input(":IN.0", 0x01, 0.5) -- CLEAR
end

function interface.get_options()
	return { { "string", "Level", "a1"}, { "check", "Clear announcements", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:lower():match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		if (level:match("^[ab][1-8]$") or level:match("^[d-h][1-8]$")
		or  level:match("^c%s%d:[0-5]%d/%d%d$")
		or  level:match("^c%s%d:[0-5]%d/%d%d%s%d:[0-5]%d/%d%d$")
		or  level:match("^c%s%d:[0-5]%d/%d%d%s%d:[0-5]%d/%d%d%s%d:[0-5]%d/%d%d$")) then
			interface.level = level
			interface.setlevel()
		end
	end
	if (name == "clear announcements") then
		interface.opt_clear_announcements = tonumber(value) == 1
	end
end

return interface
