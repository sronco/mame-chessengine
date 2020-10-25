interface = {}

interface.turn = true
interface.invert = false
interface.color = "B"
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	send_input(":IN.4", 0x04, 1) -- Level
	if     (level ==  1) then send_input(":IN.6", 0x01, 1)
	elseif (level ==  2) then send_input(":IN.5", 0x08, 1)
	elseif (level ==  3) then send_input(":IN.5", 0x04, 1)
	elseif (level ==  4) then send_input(":IN.5", 0x02, 1)
	elseif (level ==  5) then send_input(":IN.5", 0x01, 1)
	elseif (level ==  6) then send_input(":IN.4", 0x08, 1)
	elseif (level ==  7) then send_input(":IN.6", 0x04, 1)
	elseif (level ==  8) then send_input(":IN.6", 0x08, 1)
	elseif (level ==  9) then send_input(":IN.7", 0x01, 1)
	elseif (level == 10) then send_input(":IN.7", 0x02, 1)
	elseif (level == 11) then send_input(":IN.7", 0x04, 1)
	elseif (level == 12) then send_input(":IN.7", 0x08, 1)
	end
	send_input(":IN.6", 0x02, 1) -- Clear
end

function interface.setup_machine()
	interface.turn = true
	interface.invert = false
	interface.color = "B"
	sb_reset_board(":board")
	emu.wait(8)
	local switch = false
	if (emu.item(machine.devices[':maincpu'].items['0/00000000-0000ffff']):read(0x13) == 0x04) then
		send_input(":IN.0", 0x08, 1)  -- Play
		switch = true
	end
	if (emu.item(machine.devices[':maincpu'].items['0/00000000-0000ffff']):read(0x07) == 0x01) then
		send_input(":IN.1", 0x02, 1)  -- White
		switch = true
	end
	if (switch) then
		send_input(":RESET", 0x01, 1) -- Reset
		emu.wait(8)
	end
	send_input(":IN.6", 0x02, 1)  -- Clear

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		interface.turn = false
		interface.invert = true
		interface.color = "W"
		sb_rotate_board(":board")
		send_input(":IN.1", 0x01, 1)  -- Black
		send_input(":RESET", 0x01, 1) -- Reset
		emu.wait(1)
	else
		interface.turn = not interface.turn
		if (interface.color == "W") then
			interface.color = "B"
			send_input(":IN.1", 0x01, 1)  -- Black
		else
			interface.color = "W"
			send_input(":IN.1", 0x02, 1)  -- White
		end
	end
	send_input(":IN.4", 0x01, 1)  -- Enter
end

function interface.stop_play()
end

function interface.is_selected(x, y)
	if (interface.invert) then
		x = 9 - x
		y = 9 - y
	end
	-- castling moves
	if (y == 8 or y == 1) then
		local d1=(machine:outputs():get_value((y - 1) .. "." .. 0) ~= 0)
		local d2=(machine:outputs():get_value((y - 1) .. "." .. 1) ~= 0)
		local d3=(machine:outputs():get_value((y - 1) .. "." .. 2) ~= 0)
		local d4=(machine:outputs():get_value((y - 1) .. "." .. 3) ~= 0)
		local d5=(machine:outputs():get_value((y - 1) .. "." .. 4) ~= 0)
		local d6=(machine:outputs():get_value((y - 1) .. "." .. 5) ~= 0)
		local d7=(machine:outputs():get_value((y - 1) .. "." .. 6) ~= 0)
		local d8=(machine:outputs():get_value((y - 1) .. "." .. 7) ~= 0)
		if (not interface.invert) then
			if (d1 and d3 and d4 and d5) then
				if (x == 5 or x == 3) then
					return true
				else
					return false
				end
			end
			if (d5 and d6 and d7 and d8) then
				if (x == 5 or x == 7) then
					return true
				else
					return false
				end
			end
		else
			if (d1 and d2 and d3 and d4) then
				if (x == 4 or x == 2) then
					return true
				else
					return false
				end
			end
			if (d4 and d5 and d6 and d8) then
				if (x == 4 or x == 6) then
					return true
				else
					return false
				end
			end
		end
	end
	-- enpassant moves
	if (not interface.invert) then
		if (y == 4) then
			local d1=(machine:outputs():get_value(3 .. "." .. (x-2)) ~= 0)
			local d2=(machine:outputs():get_value(3 .. "." .. (x-1)) ~= 0)
			local d3=(machine:outputs():get_value(3 .. "." .. (x-0)) ~= 0)
			local d4=(machine:outputs():get_value(2 .. "." .. (x-1)) ~= 0)
			if (d2 and d4 and (d1 or d3)) then
				return false
			end
		end
	else
		if (y == 5) then
			local d1=(machine:outputs():get_value(4 .. "." .. (x-2)) ~= 0)
			local d2=(machine:outputs():get_value(4 .. "." .. (x-1)) ~= 0)
			local d3=(machine:outputs():get_value(4 .. "." .. (x-0)) ~= 0)
			local d4=(machine:outputs():get_value(5 .. "." .. (x-1)) ~= 0)
			if (d2 and d4 and (d1 or d3)) then
				return false
			end
		end
	end 
	return machine:outputs():get_value((y - 1) .. "." .. (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	if (interface.invert) then
		x = 9 - x
		y = 9 - y
	end
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
		send_input(":IN.4", 0x01, 1) -- Enter
	elseif (event == "get_castling") then
		sb_move_piece(":board", x, y)
	elseif (event == "put_castling") then
		sb_move_piece(":board", x, y)
		send_input(":IN.4", 0x01, 1) -- Enter
	else
		sb_select_piece(":board", 1, x, y, event)
	end

	if (event == "put") then
		if (interface.turn) then
			send_input(":IN.4", 0x01, 1) -- Enter
			emu.wait(0.25)
		end
		interface.turn = not interface.turn
	end
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
	if (interface.invert) then
		x = 9 - x
		y = 9 - y
	end
	sb_promote(":board", x, y, piece)
end

return interface
