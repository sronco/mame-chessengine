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
	send_input(":BUTTONS", 0x40, 1) -- Level
	send_input(":BUTTONS", 0x80 >> (interface.level - 1), 1)
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":BUTTONS", 0x80, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":BUTTONS", 0x20, 1) -- Color
end

function interface.is_selected(x, y)
	local led_tag = { "a", "b", "c", "d", "e", "f", "g", "h" }
	return machine:outputs():get_indexed_value("led_" .. led_tag[x], 9 - y) == 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "8"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 8) then
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
	-- TODO
end

return interface
