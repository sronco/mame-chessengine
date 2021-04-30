-- license:BSD-3-Clause

interface = {}

interface.level = 1
interface.cur_level = 1

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	local level = interface.cur_level
	interface.cur_level = interface.level
	send_input(":IN.0", 0x02, 0.5) -- Sound
	emu.wait(0.25)
	send_input(":IN.0", 0x01, 0.5) -- Set Level
	emu.wait(0.25)
	local k = (interface.level - level + 8) % 8
	for i=1,k do
		send_input(":IN.0", 0x01, 0.5) -- Set Level
		emu.wait(0.3)
	end
	send_input(":IN.0", 0x08, 0.5) -- Go
	emu.wait(0.25)
	send_input(":IN.0", 0x02, 0.5) -- Sound
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1)
	send_input(":IN.0", 0x80, 0.5) -- New Game
	emu.wait(0.5)

--	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x08, 0.5) -- Go
end

function interface.is_selected(x, y)
	local xval,yval
	if (x < 7) then xval = output:get_indexed_value("0.", (x - 1)) ~= 0
	else xval = output:get_indexed_value("1.", (x - 3)) ~= 0
	end
	if (y > 2) then yval = output:get_indexed_value("2.", (8 - y)) ~= 0
	else yval = output:get_indexed_value("1.", (2 - y)) ~= 0
	end
	return xval and yval
end

function interface.select_piece(x, y, event)
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
	elseif (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	else
		sb_select_piece(":board", 0.5, x, y, event)
		emu.wait(0.3)
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
end

return interface
