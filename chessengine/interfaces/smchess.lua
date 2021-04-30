-- license:BSD-3-Clause

interface = {}

interface.turn = true
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":IN.4", 0x01, 0.6) -- Level
end

function interface.setup_machine()
	local cfg = ioport.ports[":IN.4"]:read()
	if (cfg == 4 or cfg == 5) then
		send_input(":IN.4", 0x04, 0.6) -- MM off
	end
	interface.turn = true
	send_input(":IN.3", 0x01, 1)  -- New Game

	interface.cur_level = (cfg % 2) + 1
	interface.setlevel()
end

function interface.start_play(init)
	interface.turn = not interface.turn
	send_input(":IN.3", 0x04, 0.6) -- Enter
end

function interface.stop_play()
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = output:get_value("digit0")
	local d1 = output:get_value("digit1")
	local d2 = output:get_value("digit2")
	local d3 = output:get_value("digit3")
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.0", 0x01, 0.6)
	elseif (p == 2)	then	send_input(":IN.0", 0x02, 0.6)
	elseif (p == 3)	then	send_input(":IN.0", 0x04, 0.6)
	elseif (p == 4)	then	send_input(":IN.1", 0x01, 0.6)
	elseif (p == 5)	then	send_input(":IN.1", 0x02, 0.6)
	elseif (p == 6)	then	send_input(":IN.1", 0x04, 0.6)
	elseif (p == 7)	then	send_input(":IN.2", 0x01, 0.6)
	elseif (p == 8)	then	send_input(":IN.2", 0x02, 0.6)
	end
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (interface.turn) then
			interface.send_pos(x)
			interface.send_pos(y)
		end

		if (event == "put") then
			if (interface.turn) then
				send_input(":IN.3", 0x04, 0.6) -- Enter
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "2"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 2) then
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
