-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.opt_clear_announcements = true
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local led_code = { 1, 2, 4, 8, 16, 32, 64, 128, 255, 63, 31, 15 }
	local cur_leds = 0
	local cur_level = 0
	local dif_level
	send_input(":IN.0", 0x08, 1) -- LV
	for y=0,7 do
		if machine:outputs():get_indexed_value("7.", y) ~= 0 then
			cur_leds = cur_leds + (1 << y)
		end
	end
	repeat
		cur_level = cur_level + 1
	until cur_leds == led_code[cur_level]
	dif_level = interface.level - cur_level
	if (dif_level < 0) then
		dif_level = dif_level + 12
	end
	for y=1,dif_level do
		send_input(":IN.0", 0x08, 0.5) -- LV
	end
	send_input(":IN.0", 0x40, 1) -- CL
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1)
	send_input(":IN.0", 0x80, 0.5) -- RE
	sb_press_square(":board", 1, 4, 8)  -- D8
	send_input(":IN.0", 0x40, 0.5) -- CL
	emu.wait(1)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x01, 1) -- RV
end

function interface.clear_announcements()
	-- machine turns on all leds on the first line for mate/draw announcements
	if (machine:outputs():get_value("0.0") ~= 0 and machine:outputs():get_value("1.0") ~= 0 and machine:outputs():get_value("2.0") ~= 0 and machine:outputs():get_value("3.0") ~= 0 and
	    machine:outputs():get_value("4.0") ~= 0 and machine:outputs():get_value("5.0") ~= 0 and machine:outputs():get_value("6.0") ~= 0 and machine:outputs():get_value("7.0") ~= 0) then
		send_input(":IN.0", 0x40, 1)
	end
end

function interface.is_selected(x, y)
	if (interface.opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_indexed_value(tostring(x - 1) .. ".", y - 1) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "12"}, { "check", "Clear announcements", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 12) then
			return
		end
		interface.level = level
		interface.setlevel()
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
	if     (piece == "q") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x08, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x04, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x02, 1)
	end
end

return interface
