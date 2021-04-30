-- license:BSD-3-Clause

interface = {}

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	repeat
		send_input(":IN.6", 0x02, 0.5) -- Set Level
		local cur_level = 0
		for y=0,7 do
			if output:get_indexed_value("1.", y) ~= 0 then
				cur_level = cur_level + 1
			end
		end
	until cur_level == math.abs(interface.level)
	send_input(":IN.7", 0x01, 1) -- Go
	local tc = 0x00
	if (interface.level < 0 ) then
		tc = 0x08
	end
	if (machine.devices[':maincpu'].spaces['program']:read_u8(0x58) & 0x08 ~= tc) then
		send_input(":IN.1", 0x02, 1) -- Time Control
	end
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":IN.0", 0x01, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.7", 0x01, 1) -- Go
end

function interface.is_selected(x, y)
	return (output:get_indexed_value("1.", (8 - y)) ~= 0) and (output:get_indexed_value("2.", (x - 1)) ~= 0)
end

function interface.select_piece(x, y, event)
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
	elseif (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	else
		sb_select_piece(":board", 1, x, y, event)
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "-8", "8"}, }  -- default difficulty level is 1
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < -8 or level > 8) then
			return
		elseif (level == 0) then
			level = 1
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- Super Sensor IV always promotes to Queen
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	-- TODO
end

return interface
