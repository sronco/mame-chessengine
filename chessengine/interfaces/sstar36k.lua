interface = load_interface("sstar28k")

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x,y
	send_input(":IN.0", 0x08, 0.5)	-- LEVEL
	while (level ~= "") do
		x = cols_idx[level:sub(1, 1)]
		y = level:sub(2, 2)
		sb_press_square(":board", 0.5, x, y)
		level = level:sub(4)
	end
	send_input(":IN.0", 0x08, 0.5)	-- LEVEL
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
	emu.wait(13)
	send_input(":IN.0", 0x20, 1)	-- NEW GAME
	emu.wait(0.5)

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," "):lower() -- trim
		local tmp = level .. " "
		while (tmp ~= "") do
			if (tmp:sub(1,3):match("[a-ch][1-8]%s") == nil) then
				return
			else
				tmp = tmp:sub(4)
		
			end
		end
		interface.level = level
		interface.setlevel()
	end
end

return interface
