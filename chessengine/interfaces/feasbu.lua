-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.opt_clear_announcements = true
interface.level = "a1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	if (x > 2) then
		return
	end
	local y = interface.level:sub(2, 2)
	send_input(":IN.0", 0x80, 1)  -- LV
	sb_press_square(":board", 1, x, y)
	send_input(":IN.1", 0x02, 1) -- CL
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(5)
	send_input(":IN.0", 0x01, 0.5)  -- Game Control
	sb_press_square(":board", 1, 4, 8)  -- D8
	send_input(":IN.1", 0x02, 0.5) -- CL
	emu.wait(1)

	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.1", 0x04, 1) -- RV
end

function interface.clear_announcements()
	-- machine turns on all LEDs on the first line for mate/draw announcements
	if (machine:outputs():get_value("0.15") ~= 0 and machine:outputs():get_value("1.15") ~= 0 and machine:outputs():get_value("2.15") ~= 0 and machine:outputs():get_value("3.15") ~= 0 and
	    machine:outputs():get_value("4.15") ~= 0 and machine:outputs():get_value("5.15") ~= 0 and machine:outputs():get_value("6.15") ~= 0 and machine:outputs():get_value("7.15") ~= 0) then
		send_input(":IN.1", 0x02, 1) -- CL
	end
end

function interface.is_selected(x, y)
	if (interface.opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_indexed_value(tostring(x - 1) .. ".", 16 - y) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a1"}, { "check", "Clear announcements", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
		interface.setlevel()
	end
	if (name == "clear announcements") then
		interface.opt_clear_announcements = tonumber(value) == 1
	end
end

function interface.get_promotion(x, y)
	interface.clear_announcements()
	interface.select_piece(x, y, "")

	local new_type = nil
	if     (machine:outputs():get_value("8.9")  ~= 0) then	new_type = 'q'
	elseif (machine:outputs():get_value("8.10") ~= 0) then	new_type = 'r'
	elseif (machine:outputs():get_value("8.11") ~= 0) then	new_type = 'b'
	elseif (machine:outputs():get_value("8.12") ~= 0) then	new_type = 'n'
	end

	interface.select_piece(x, y, "")
	return new_type
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	sb_press_square(":board", 1, x, y)
	if     (piece == "q") then	send_input(":IN.0", 0x08, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x20, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x40, 1)
	end
end

return interface
