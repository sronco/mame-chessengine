interface = {}

interface.level = 2
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	repeat
		send_input(":IN.1", 0x02, 0.5) -- Level
		local cur_level = 0
		for y=0,7 do
			if machine:outputs():get_indexed_value("0.", 7-y) ~= 0 then
				cur_level = cur_level + 1
			end
		end
	until cur_level == interface.level
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)
	send_input(":IN.0", 0x01, 1) -- Set Up
	send_input(":IN.0", 0x04, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = 2
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.1", 0x04, 1) -- Move / Halt
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value(tostring(x - 1) .. ".", 8 - y) ~= 0
end

function interface.select_piece(x, y, event)
	if (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	else
		sb_select_piece(":board", 1, x, y, event)
	end
end

function interface.get_options()
	return { { "spin", "Level", "2", "1", "8"}, }
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
	elseif (piece == "r") then	send_input(":IN.0", 0x20, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x40, 1)
	elseif (piece == "n") then	send_input(":IN.1", 0x40, 1)
	end
end

return interface
