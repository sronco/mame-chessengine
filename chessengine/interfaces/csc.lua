-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local lcd_num = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x79, 0x71, 0x3d, 0x76 }
	repeat
		send_input(":IN.3", 0x100, 0.5) -- LV
	until machine:outputs():get_value("digit0") == lcd_num[interface.level]
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":IN.8", 0x80, 1) -- RE
	emu.wait(1.0)
	send_input(":IN.8", 0x40, 1) -- CL

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.4", 0x100, 1) -- DM
	send_input(":IN.1", 0x100, 1) -- RV
end

function interface.is_selected(x, y)
	return machine:outputs():get_value(tostring(x - 1) .. "." .. tostring(y - 1 + 8)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "12"}, }
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
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x02, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x04, 1)
	end
end

return interface
