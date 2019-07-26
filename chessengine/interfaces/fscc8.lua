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
	repeat
		send_input(":IN.0", 0x40, 0.6) -- CL
	until machine:outputs():get_value("7." .. interface.level-1) ~= 0
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":IN.0", 0x80, 1) -- RE
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		sb_press_square(":board", 1, 5, 8) -- e8 (black king)
	end
end

function interface.is_selected(x, y)
	if (machine:outputs():get_value("0.0") ~= 0 and machine:outputs():get_value("1.0") ~= 0 and machine:outputs():get_value("2.0") ~= 0 and machine:outputs():get_value("3.0") ~= 0 or
	    machine:outputs():get_value("4.0") ~= 0 and machine:outputs():get_value("5.0") ~= 0 and machine:outputs():get_value("6.0") ~= 0 and machine:outputs():get_value("7.0") ~= 0) then
		-- TODO: machine turns on all LEDs for mate announcement
		return false
	end

	return machine:outputs():get_value(tostring(x - 1) .. "." .. tostring(y - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	if (event ~= "get_castling" and event ~= "put_castling") then
		sb_select_piece(":board", 1, x, y, event)
	end
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
	if     (piece == "q") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x02, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x04, 1)
	end
end

return interface
