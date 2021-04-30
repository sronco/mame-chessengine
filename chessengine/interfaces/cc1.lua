-- license:BSD-3-Clause

interface = {}

interface.turn = true
interface.invert = false
interface.last_get = nil

function interface.setup_machine()
	interface.turn = true
	interface.invert = false
	interface.last_get = nil
	send_input(":RESET", 0x01, 0.5) -- RE
	emu.wait(1.0)
end

function interface.start_play(init)
	if (init) then
		interface.send_pos_full(1, 1)
		interface.send_pos_full(1, 1)
		send_input(":IN.1", 0x01, 0.5) -- EN
		interface.turn = false
		interface.invert = true
	end
end

function interface.stop_play()
end

function interface.is_selected(x, y)
	if (interface.invert) then
		y = 9 - y
	end
	local yval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x6f, 0x76 }
	local xval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7c, 0x07, 0x7f }
	local d0 = output:get_value("digit0")
	local d1 = output:get_value("digit1")
	local d2 = output:get_value("digit2")
	local d3 = output:get_value("digit3")
	if (d0 == 0x3f and d1 == 0x3f and d2 == 0x3f and d3 == 0x00) then -- "000 ", computer castles queenside
		return y == 8 and (x == 5 or x == 3)
	end
	if (d0 == 0x3f and d1 == 0x3f and d2 == 0x00 and d3 == 0x00) then -- "00  ", computer castles kingside
		return y == 8 and (x == 5 or x == 7)
	end
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.0", 0x80, 0.5)
	elseif (p == 2)	then	send_input(":IN.0", 0x40, 0.5)
	elseif (p == 3)	then	send_input(":IN.0", 0x20, 0.5)
	elseif (p == 4)	then	send_input(":IN.0", 0x10, 0.5)
	elseif (p == 5)	then	send_input(":IN.0", 0x08, 0.5)
	elseif (p == 6)	then	send_input(":IN.0", 0x04, 0.5)
	elseif (p == 7)	then	send_input(":IN.0", 0x02, 0.5)
	elseif (p == 8)	then	send_input(":IN.0", 0x01, 0.5)
	end
end

function interface.send_pos_full(x, y)
	if (interface.invert) then
		y = 9 - y
	end
	interface.send_pos(x)
	interface.send_pos(y)
end

function interface.select_piece(x, y, event)
	if (event == "get" and interface.turn) then
		interface.last_get = {x=x, y=y}
	elseif (event == "put" and interface.turn) then
		local move_type = get_move_type(interface.last_get.x, interface.last_get.y, x, y)
		local dy
		if (move_type == "castling") then
			send_input(":IN.1", 0x02, 0.5) -- DM
		elseif (move_type == "en_passant") then
			dy = y
			y = interface.last_get.y
			send_input(":IN.1", 0x02, 0.5) -- DM
		end

		interface.send_pos_full(interface.last_get.x, interface.last_get.y)
		interface.send_pos_full(x, y)

		send_input(":IN.1", 0x01, 0.5) -- EN

		-- special moves require extra steps
		if (move_type == "castling" and x == 7) then
			interface.send_pos_full(8, y)
			interface.send_pos_full(6, y)
			send_input(":IN.1", 0x01, 0.5) -- EN
		elseif (move_type == "castling" and x == 3) then
			interface.send_pos_full(1, y)
			interface.send_pos_full(4, y)
			send_input(":IN.1", 0x01, 0.5) -- EN
		elseif (move_type == "en_passant") then
			interface.send_pos_full(x, y)
			interface.send_pos_full(x, dy)
			send_input(":IN.1", 0x01, 0.5) -- EN
		end

		interface.last_get = nil
	end
	if (event == "put") then
		interface.turn = not interface.turn
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	-- TODO
end

return interface
