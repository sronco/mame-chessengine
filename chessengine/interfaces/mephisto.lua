-- license:BSD-3-Clause

interface = {}

interface.turn = true
interface.level = "a1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = tonumber(interface.level:sub(2, 2))
	send_input(":IN.1", 0x04, 0.5) -- LEV
	interface.send_pos(x)
	interface.send_pos(y)
	send_input(":IN.0", 0x04, 0.5) -- ENT
end

function interface.setup_machine()
	interface.turn = true
	send_input(":RESET", 0x01, 0.5)  -- RES
	emu.wait(1.0)
	send_input(":IN.0", 0x01, 0.5) -- CL

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.start_play(init)
	interface.turn = false
	send_input(":IN.1", 0x01, 0.5) -- STA
end

function interface.stop_play()
	send_input(":IN.0", 0x04, 0.5) -- ENT
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = output:get_value("digit3")
	local d1 = output:get_value("digit2")
	local d2 = output:get_value("digit1")
	local d3 = output:get_value("digit0")
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.0", 0x02, 0.5)
	elseif (p == 2)	then	send_input(":IN.0", 0x08, 0.5)
	elseif (p == 3)	then	send_input(":IN.1", 0x02, 0.5)
	elseif (p == 4)	then	send_input(":IN.1", 0x08, 0.5)
	elseif (p == 5)	then	send_input(":IN.2", 0x02, 0.5)
	elseif (p == 6)	then	send_input(":IN.2", 0x08, 0.5)
	elseif (p == 7)	then	send_input(":IN.3", 0x02, 0.5)
	elseif (p == 8)	then	send_input(":IN.3", 0x08, 0.5)
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
				send_input(":IN.1", 0x01, 1) -- STA
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "string", "Level", "a1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," "):lower() -- trim
		if (level:match("^[a-h][1-8]$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	-- TODO
end

return interface
