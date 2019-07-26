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
	send_input(":IN.0", 0x40, 1) -- Change Level
	send_input(":IN.0", 1 << (7-interface.level), 1)
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)
	send_input(":IN.0", 0x80, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x20, 1) -- Change Color
	if machine:outputs():get_value("8.1") ~= 0 then
		send_input(":IN.0", 0x01, 1) -- Black
	else
		send_input(":IN.0", 0x02, 1) -- White
	end
end

function interface.stop_play()
	send_input(":IN.1", 0x02, 0.5) -- HALT
end

function interface.is_selected(x, y)
	return machine:outputs():get_value((x - 1) .. "." .. (y-1)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "1", "0", "6"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 6) then
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
