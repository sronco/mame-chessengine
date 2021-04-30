-- license:BSD-3-Clause

interface = {}

interface.turn = true
interface.invert = false
interface.last_get = nil
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":RESET", 0x01, 1) -- Reset
	send_input(":RESET", 0x01, 1) -- Reset
	emu.wait(1)
	if (interface.level > 4)	then
		send_input(":IN.3", 0x08 >> (interface.level-5), 1)
	else
		send_input(":IN.2", 0x08 >> (interface.level-1), 1)
	end
	emu.wait(1.0)
	send_input(":IN.0", 0x08, 1) -- A
end

function interface.setup_machine()
	interface.turn = true
	interface.invert = false
	interface.last_get = nil
	emu.wait(1.0)
	send_input(":RESET", 0x01, 1) -- Reset
	send_input(":RESET", 0x01, 1) -- Reset
	send_input(":IN.2", 0x08, 1) -- 1
	emu.wait(0.5)
	send_input(":IN.0", 0x08, 1) -- A

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		interface.turn = false
		interface.invert = true
		send_input(":IN.2", 0x01, 1) -- fp
		send_input(":IN.0", 0x01, 1) -- Play
		emu.wait(0.5)
	end
end

function interface.is_selected(x, y)
	if (interface.invert) then
--		x = 9 - x
		y = 9 - y
	end
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 } -- A to H
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f } -- 1 to 8
	local d0 = output:get_value("digit0")
	local d1 = output:get_value("digit1")
	local d2 = output:get_value("digit2")
	local d3 = output:get_value("digit3")
	if (d0 == 0x3f and d1 == 0x40 and d2 == 0x3f and d3 == 0x77) then -- "0-0A", computer castles queenside
		return (x == 5 or x == 3) and (y == 8)
	end
	if (d0 == 0x3f and d1 == 0x40 and d2 == 0x3f and d3 == 0x76) then -- "0-0H", computer castles kingside
		return (x == 5 or x == 7) and (y == 8)
	end
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos1(p)  -- "A" to "H" keys
	if     (p == 1)	then	send_input(":IN.0", 0x08, 0.5)
	elseif (p == 2)	then	send_input(":IN.0", 0x04, 0.5)
	elseif (p == 3)	then	send_input(":IN.0", 0x02, 0.5)
	elseif (p == 4)	then	send_input(":IN.0", 0x01, 0.5)
	elseif (p == 5)	then	send_input(":IN.1", 0x08, 0.5)
	elseif (p == 6)	then	send_input(":IN.1", 0x04, 0.5)
	elseif (p == 7)	then	send_input(":IN.1", 0x02, 0.5)
	elseif (p == 8)	then	send_input(":IN.1", 0x01, 0.5)
	end
end

function interface.send_pos2(p)  -- "1" to "8" keys
	if (interface.invert) then
		p = 9 - p
	end
	if     (p == 1)	then	send_input(":IN.2", 0x08, 0.5)
	elseif (p == 2)	then	send_input(":IN.2", 0x04, 0.5)
	elseif (p == 3)	then	send_input(":IN.2", 0x02, 0.5)
	elseif (p == 4)	then	send_input(":IN.2", 0x01, 0.5)
	elseif (p == 5)	then	send_input(":IN.3", 0x08, 0.5)
	elseif (p == 6)	then	send_input(":IN.3", 0x04, 0.5)
	elseif (p == 7)	then	send_input(":IN.3", 0x02, 0.5)
	elseif (p == 8)	then	send_input(":IN.3", 0x01, 0.5)
	end
end

function interface.send_pos(x, y)
	interface.send_pos1(x)
	interface.send_pos2(y)
end

function interface.select_piece(x, y, event)
	if (event == "get" and interface.turn) then
		interface.last_get = {x=x, y=y}
	elseif (event == "put" and interface.turn) then
		local move_type = get_move_type(interface.last_get.x, interface.last_get.y, x, y)
		if (move_type == "castling") then
			if    (x == 7) then	interface.send_pos(8, y)
			elseif (x == 3) then	interface.send_pos(1, y)
			end
			if    (x == 7) then	interface.send_pos(6, y)
			elseif (x == 3) then	interface.send_pos(4, y)
			end
			send_input(":IN.1", 0x01, 0.5) -- md
			interface.send_pos(interface.last_get.x, interface.last_get.y)
			interface.send_pos(x, y)
			send_input(":IN.0", 0x01, 0.5) -- play
		elseif (move_type == "en_passant") then
			interface.send_pos(interface.last_get.x, interface.last_get.y)
			interface.send_pos(x, y)
			send_input(":IN.1", 0x01, 0.5) -- md
			y = interface.last_get.y
			interface.send_pos(interface.last_get.x, interface.last_get.y)
			interface.send_pos(x, y)
			send_input(":IN.0", 0x01, 0.5) -- play
		elseif (move_type == "promotion" or move_type == "capture_promotion") then
			interface.send_pos(interface.last_get.x, interface.last_get.y)
			interface.send_pos(x, y)
			send_input(":IN.1", 0x01, 0.5) -- md
		else
			interface.send_pos(interface.last_get.x, interface.last_get.y)
			interface.send_pos(x, y)
			send_input(":IN.0", 0x01, 0.5) -- play
		end

		interface.last_get = nil
	end
	if (event == "put") then
		interface.turn = not interface.turn
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "6"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 6) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- CC Mk 1 always promotes to Queen
end

function interface.promote(x, y, piece)
	if (piece == "q" or piece == "r" or piece == "b" or piece == "n") then
		send_input(":IN.3", 0x01, 0.5) -- ep
		if     (piece == "q") then	send_input(":IN.0", 0x04, 0.5)
		elseif (piece == "r") then	send_input(":IN.1", 0x04, 0.5)
		elseif (piece == "b") then	send_input(":IN.0", 0x02, 0.5)
		elseif (piece == "n") then	send_input(":IN.1", 0x08, 0.5)
		end
		if (interface.invert) then
--			x = 9 - x
			y = 9 - y
		end
		interface.send_pos(x, y)
		send_input(":IN.0", 0x01, 0.5) -- play
	end
end

return interface
