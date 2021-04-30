-- license:BSD-3-Clause

interface = {}

interface.opt_clear_announcements = true
interface.level = "a1"
interface.cur_level = nil

function interface.setdigit(n,d)
	local lcd_num = { 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67 }
	local led = 3-n
	while (output:get_value("digit" .. led) ~= lcd_num[d+1]) do
		send_input(":IN." .. tostring(3-n), 0x100, 0.5)  -- TM / RV / spk
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
	send_input(":IN.8", 0x08, 1)  -- LV
	sb_press_square(":board", 0.5, x, y)
	local num = level:sub(4)
	if (num ~= "" and num:len() <= 2) then
		if (num:len() == 1) then
			num = "0" .. num
		end
		for i=1,2 do
			interface.setdigit(i+1,num:sub(i,i))
		end
	else
		local k = 1
		while (num ~= "") do
			local d = num:sub(1,1)
			if (d == " ") then
				sb_press_square(":board", 0.5, x, y)
				k = 1
			elseif (d == "/") then
				sb_press_square(":board", 0.5, x, y)
				k = 2
			elseif (d ~= ":") then
				interface.setdigit(k,d)
				k = k + 1
			end
			num = num:sub(2)
		end
	end
	emu.wait(0.5)
	send_input(":IN.8", 0x40, 1) -- CL
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.8", 0x02, 1) -- DM
	send_input(":IN.8", 0x01, 1) -- RV
end

function interface.clear_announcements()
	-- machine turns on all LEDs on the first line for mate/draw announcements
	if (output:get_value("0.8") ~= 0 and output:get_value("1.8") ~= 0 and output:get_value("2.8") ~= 0 and output:get_value("3.8") ~= 0 and
	    output:get_value("4.8") ~= 0 and output:get_value("5.8") ~= 0 and output:get_value("6.8") ~= 0 and output:get_value("7.8") ~= 0) then
		send_input(":IN.8", 0x40, 1)
	end
end

function interface.is_selected(x, y)
	if (interface.opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return output:get_value(tostring(x - 1) .. "." .. tostring(y - 1 + 8)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a1"}, { "check", "Clear announcements", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:lower():match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		if (level:match("^a[1-8]$") or level:match("^b[1-7]$")
		or  level:match("^b[4-6]%s%d%d?$")
		or  level:match("^b[72]%s%d:%d%d$") or level:match("^b2%s%d:%d%d%s%d:%d%d$")
		or  level:match("^b3%s%d:%d%d/%d%d$") or level:match("^b3%s%d:%d%d/%d%d%s%d:%d%d/%d%d$") or level:match("^b3%s%d:%d%d/%d%d%s%d:%d%d/%d%d%s%d:%d%d$")) then
			interface.level = level
			interface.setlevel()
		end
	end
	if (name == "clear announcements") then
		interface.opt_clear_announcements = tonumber(value) == 1
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	emu.wait(1)
	if     (piece == "q") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x04, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x02, 1)
	end
end

return interface
