-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.opt_clear_announcements = true
interface.level = 0
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local led_code = { 1, 2, 4, 8, 16, 32, 64, 128, 129 }
	local cur_leds = 0
	local cur_level = 0
	local dif_level
	send_input(":IN.0", 0x40, 0.5) -- Change Level
	for y=0,7 do
		if machine:outputs():get_indexed_value("8.", 7-y) ~= 0 then
			cur_leds = cur_leds + (1 << y)
		end
	end
	while cur_leds ~= led_code[cur_level+1] do
		cur_level = cur_level + 1
	end
	dif_level = interface.level - cur_level
	if (dif_level < 0) then
		dif_level = dif_level + 9
	end
	for y=1,dif_level do
		send_input(":IN.0", 0x40, 0.5) -- Change Level
	end
	send_input(":IN.0", 0x02, 0.5) -- Clear
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)
	send_input(":IN.0", 0x80, 0.5) -- New Game
	sb_press_square(":board", 1, 4, 8)  -- d8
	send_input(":IN.0", 0x02, 0.5) -- Clear
	emu.wait(0.5)

	interface.cur_level = 0
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x20, 0.5) -- Change Color
	emu.wait(0.5)
end

function interface.stop_play()
	send_input(":IN.1", 0x02, 0.5) -- HALT
end

function interface.clear_announcements()
	-- machine turns on all LEDs on the first line for mate/draw announcements
	if (machine:outputs():get_value("0.0") ~= 0 and machine:outputs():get_value("1.1") ~= 0 and machine:outputs():get_value("2.2") ~= 0 and machine:outputs():get_value("3.3") ~= 0 and
	    machine:outputs():get_value("4.4") ~= 0 and machine:outputs():get_value("5.5") ~= 0 and machine:outputs():get_value("6.6") ~= 0 and machine:outputs():get_value("7.7") ~= 0 and
	    machine:outputs():get_value("0.7") ~= 0 and machine:outputs():get_value("1.6") ~= 0 and machine:outputs():get_value("2.5") ~= 0 and machine:outputs():get_value("3.4") ~= 0 and
	    machine:outputs():get_value("4.3") ~= 0 and machine:outputs():get_value("5.2") ~= 0 and machine:outputs():get_value("6.1") ~= 0 and machine:outputs():get_value("7.0") ~= 0) then
		send_input(":IN.0", 0x02, 0.5) -- Clear
	end
end

function interface.is_selected(x, y)
	if (interface.opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
		emu.wait(0.5)
	end

	return machine:outputs():get_value((x - 1) .. "." .. (y-1)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "0", "0", "8"}, { "check", "Clear announcements", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 8) then
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
	if     (piece == "q") then	send_input(":IN.0", 0x08, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x20, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x40, 1)
	end
end

return interface
