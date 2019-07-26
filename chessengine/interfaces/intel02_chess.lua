-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

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
	send_input(":RESET", 0x01, 0.5) -- RESET
	emu.wait(0.5)
	for i=1,interface.level-1 do
		send_input(":IN.1", 0x08, 0.5) -- ERASE
		emu.wait(0.5)
	end
end

function interface.setup_machine()
	interface.turn = true
	interface.invert = false
	interface.last_get = nil
	send_input(":RESET", 0x01, 0.5) -- RESET
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		interface.invert = true
		interface.turn = false
		send_input(":IN.1", 0x04, 0.5) -- SELECT
		emu.wait(0.5)
		send_input(":IN.1", 0x04, 0.5) -- SELECT
		emu.wait(0.5)
		send_input(":IN.1", 0x02, 0.5) -- INPUT
		emu.wait(0.5)
	end
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x6f, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	if (d0 == 0x3f and d1 == 0x3f and d2 == 0x3f and d3 == 0x00) then -- "000 ", computer castles queenside
		return (interface.invert and y == 1 and (x == 5 or x == 7)) or (not interface.invert and y == 8 and (x == 5 or x == 3))
	end
	if (d0 == 0x3f and d1 == 0x3f and d2 == 0x00 and d3 == 0x00) then -- "00  ", computer castles kingside
		return (interface.invert and y == 1 and (x == 5 or x == 3)) or (not interface.invert and y == 8 and (x == 5 or x == 7))
	end

	if (interface.invert) then
		x = 9 - x
		y = 9 - y
	end
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos(p)
	if (interface.invert) then
		p = 9 - p
	end
	if     (p == 1)	then	send_input(":IN.0", 0x2000, 0.5)
	elseif (p == 2)	then	send_input(":IN.0", 0x1000, 0.5)
	elseif (p == 3)	then	send_input(":IN.0", 0x0800, 0.5)
	elseif (p == 4)	then	send_input(":IN.0", 0x0400, 0.5)
	elseif (p == 5)	then	send_input(":IN.0", 0x0200, 0.5)
	elseif (p == 6)	then	send_input(":IN.0", 0x0100, 0.5)
	elseif (p == 7)	then	send_input(":IN.0", 0x0080, 0.5)
	elseif (p == 8)	then	send_input(":IN.0", 0x0040, 0.5)
	end
end

function interface.send_pos_full(x, y)
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
			send_input(":IN.1", 0x04, 0.5) -- SELECT
		elseif (move_type == "en_passant") then
			dy = y
			y = interface.last_get.y
			send_input(":IN.1", 0x04, 0.5) -- SELECT
		end

		interface.send_pos_full(interface.last_get.x, interface.last_get.y)
		interface.send_pos_full(x, y)

		send_input(":IN.1", 0x02, 0.5) -- INPUT

		-- special moves require extra steps
		if (move_type == "castling" and x == 7) then
			interface.send_pos_full(8, y)
			interface.send_pos_full(6, y)
			send_input(":IN.1", 0x02, 0.5) -- INPUT
		elseif (move_type == "castling" and x == 3) then
			interface.send_pos_full(1, y)
			interface.send_pos_full(4, y)
			send_input(":IN.1", 0x02, 0.5) -- INPUT
		elseif (move_type == "en_passant") then
			interface.send_pos_full(x, y)
			interface.send_pos_full(x, dy)
			send_input(":IN.1", 0x02, 0.5) -- INPUT
		end
		interface.last_get = nil
	end
	if (event == "put") then
		interface.turn = not interface.turn
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "3"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 3) then
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
	-- TODO
end

return interface
