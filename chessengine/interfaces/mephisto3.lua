-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.level = 3
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":IN.1", 0x04, 0.5) -- LEV
	if     (interface.level == 0)	then	send_input(":IN.3", 0x01, 0.5)
	elseif (interface.level == 1)	then	send_input(":IN.0", 0x02, 0.5)
	elseif (interface.level == 2)	then	send_input(":IN.0", 0x08, 0.5)
	elseif (interface.level == 3)	then	send_input(":IN.1", 0x02, 0.5)
	elseif (interface.level == 4)	then	send_input(":IN.1", 0x08, 0.5)
	elseif (interface.level == 5)	then	send_input(":IN.2", 0x02, 0.5)
	elseif (interface.level == 6)	then	send_input(":IN.2", 0x08, 0.5)
	elseif (interface.level == 7)	then	send_input(":IN.3", 0x02, 0.5)
	elseif (interface.level == 8)	then	send_input(":IN.3", 0x08, 0.5)
	elseif (interface.level == 9)	then	send_input(":IN.2", 0x04, 0.5)
	end
	send_input(":IN.0", 0x04, 0.5) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":RESET", 0x01, 0.5)  -- RES
	emu.wait(1.0)
	send_input(":IN.0", 0x01, 0.5) -- CL

	interface.cur_level = 3
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x04, 0.5) -- ENT
end

function interface.is_selected(x, y)
	return machine:outputs():get_value((y + 3) .. "." .. (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	if (event == "get_castling" or event == "en_passant" or event == "capture") then
		emu.wait(1)
	end

	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "3", "0", "9"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 9) then
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
	if     (piece == "q") then	send_input(":IN.2", 0x08, 0.5)
	elseif (piece == "r") then	send_input(":IN.2", 0x02, 0.5)
	elseif (piece == "b") then	send_input(":IN.1", 0x08, 0.5)
	elseif (piece == "n") then	send_input(":IN.1", 0x02, 0.5)
	end
	if (piece == "q" or piece == "r" or piece == "b" or piece == "n") then
		send_input(":IN.0", 0x04, 0.5) -- ENT
	end
end

return interface
