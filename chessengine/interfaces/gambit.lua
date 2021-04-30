-- license:BSD-3-Clause

interface = {}

interface.invert = false
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	repeat
		send_input(":IN.0", 0x08, 0.6) -- Level
	until output:get_indexed_value("0.", tostring(level-1)) ~= 0
	send_input(":IN.0", 0x40, 0.6) -- Clear
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
--	send_input(":IN.0", 0x80, 0.6) -- New Game
--	emu.wait(0.6)
	send_input(":IN.0", 0x40, 0.6) -- Clear
	emu.wait(0.6)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		sb_rotate_board(":board")
		interface.invert = true
	end
	send_input(":IN.0", 0x01, 0.6) -- Move
end

function interface.stop_play()
	send_input(":IN.0", 0x01, 0.6) -- Move
end

function interface.is_selected(x, y)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	local xval = output:get_indexed_value("1.", tostring(x - 1)) ~= 0
	local yval = output:get_indexed_value("0.", tostring(y - 1)) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
	elseif (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	else
		sb_select_piece(":board", 1.2, x, y, event)
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
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	sb_promote(":board", x, y, piece)
	if     (piece == "q") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x08, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x04, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x02, 1)
	end
end

return interface
