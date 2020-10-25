interface = {}

interface.turn = true
interface.color = "B"
interface.level = 4
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":IN.1", 0x10, 1) -- CLEAR
	emu.wait(0.5)
	send_input(":IN.0", 0x01, 1) -- LEVEL
	emu.wait(0.5)
	interface.send_pos2(interface.level)
	emu.wait(0.5)
	send_input(":IN.1", 0x08, 1) -- ENTER
end

function interface.setup_machine()
	interface.turn = true
	interface.color = "B"
	send_input(":RESET", 0x01, 1) -- NEW GAME
	emu.wait(1.0)

	interface.cur_level = 4
	interface.setlevel()
end

function interface.start_play(init)
	interface.turn = false
	send_input(":IN.1", 0x10, 1) -- CLEAR
	emu.wait(0.5)
	if (interface.color == "W") then
		interface.color = "B"
		send_input(":IN.0", 0x20, 1) -- A
	else
		interface.color = "W"
		send_input(":IN.1", 0x20, 1) -- H
	end

	emu.wait(0.5)
	send_input(":IN.1", 0x08, 1) -- ENTER
	emu.wait(0.5)
	send_input(":IN.1", 0x40, 1) -- G
	emu.wait(0.5)
	send_input(":IN.1", 0x08, 1) -- ENTER
	--  computer moves automatically
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 } -- A - H
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f } -- 1 to 8
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos1(p)  -- "A" to "H" keys
	if     (p == 1)	then	send_input(":IN.0", 0x20, 0.5)
	elseif (p == 2)	then	send_input(":IN.0", 0x10, 0.5)
	elseif (p == 3)	then	send_input(":IN.0", 0x08, 0.5)
	elseif (p == 4)	then	send_input(":IN.0", 0x04, 0.5)
	elseif (p == 5)	then	send_input(":IN.0", 0x02, 0.5)
	elseif (p == 6)	then	send_input(":IN.0", 0x01, 0.5)
	elseif (p == 7)	then	send_input(":IN.1", 0x40, 0.5)
	elseif (p == 8)	then	send_input(":IN.1", 0x20, 0.5)
	end
end

function interface.send_pos2(p)  -- "1" to "8" keys
	if     (p == 1)    then    send_input(":IN.2", 0x20, 0.5)
	elseif (p == 2)    then    send_input(":IN.2", 0x10, 0.5)
	elseif (p == 3)    then    send_input(":IN.2", 0x08, 0.5)
	elseif (p == 4)    then    send_input(":IN.2", 0x04, 0.5)
	elseif (p == 5)    then    send_input(":IN.2", 0x02, 0.5)
	elseif (p == 6)    then    send_input(":IN.2", 0x01, 0.5)
	elseif (p == 7)    then    send_input(":IN.3", 0x40, 0.5)
	elseif (p == 8)    then    send_input(":IN.3", 0x20, 0.5)
	end
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (event == "get" and machine:outputs():get_value("4.0") ~= 0) then
			send_input(":IN.1", 0x10, 1) -- CLEAR
		end

		if (interface.turn) then
			interface.send_pos1(x)
			interface.send_pos2(y)
		end

		if (event == "put") then
			if (interface.turn) then
				send_input(":IN.1", 0x08, 1)
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "spin", "Level", "4", "1", "8"}, }  -- default difficulty level is 4
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
	return 'q'	-- CC Mk 2 always promotes to Queen
end

function interface.promote(x, y, piece)
	-- automatic promotion to Queen, nothing to do/set
end

return interface
