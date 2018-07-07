-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

local turn = true

function interface.setup_machine()
	turn = true
	emu.wait(1.0)
	-- default difficulty level is 4
	send_input(":EXTRA", 0x001, 1) -- new game
	emu.wait(1.0)
end

function interface.start_play()
	turn = false
	send_input(":EXTRA", 0x002, 1) -- clear
	emu.wait(0.5)
	send_input(":BLACK", 0x080, 1) -- H
	emu.wait(0.5)
	send_input(":EXTRA", 0x004, 1) -- enter
	emu.wait(0.5)
	send_input(":BLACK", 0x040, 1) -- G
	emu.wait(0.5)
	send_input(":EXTRA", 0x004, 1) -- enter
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
	if     (p == 1)	then	send_input(":BLACK", 0x001, 1)
	elseif (p == 2)	then	send_input(":BLACK", 0x002, 1)
	elseif (p == 3)	then	send_input(":BLACK", 0x004, 1)
	elseif (p == 4)	then	send_input(":BLACK", 0x008, 1)
	elseif (p == 5)	then	send_input(":BLACK", 0x010, 1)
	elseif (p == 6)	then	send_input(":BLACK", 0x020, 1)
	elseif (p == 7)	then	send_input(":BLACK", 0x040, 1)
	elseif (p == 8)	then	send_input(":BLACK", 0x080, 1)
	end
end

function interface.send_pos2(p)  -- "1" to "8" keys
	if     (p == 1)    then    send_input(":WHITE", 0x001, 1)
	elseif (p == 2)    then    send_input(":WHITE", 0x002, 1)
	elseif (p == 3)    then    send_input(":WHITE", 0x004, 1)
	elseif (p == 4)    then    send_input(":WHITE", 0x008, 1)
	elseif (p == 5)    then    send_input(":WHITE", 0x010, 1)
	elseif (p == 6)    then    send_input(":WHITE", 0x020, 1)
	elseif (p == 7)    then    send_input(":WHITE", 0x040, 1)
	elseif (p == 8)    then    send_input(":WHITE", 0x080, 1)
	end
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (turn) then
			interface.send_pos1(x)
			interface.send_pos2(y)
		end

		if (event == "put") then
			if (turn) then
				send_input(":EXTRA", 0x004, 1) -- press enter
			end
			turn = not turn
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
        send_input(":EXTRA", 0x002, 1) -- press clear
	emu.wait(0.5)
	send_input(":BLACK", 0x020, 1) -- F for level
	emu.wait(0.5)
	if     (level == 1)	then	send_input(":WHITE", 0x001, 1) -- 1
	elseif (level == 2)	then	send_input(":WHITE", 0x002, 1) -- 2
	elseif (level == 3)	then	send_input(":WHITE", 0x004, 1) -- 3
	elseif (level == 4)	then	send_input(":WHITE", 0x008, 1) -- 4
	elseif (level == 5)	then	send_input(":WHITE", 0x010, 1) -- 5
	elseif (level == 6)	then	send_input(":WHITE", 0x020, 1) -- 6
	elseif (level == 5)	then    send_input(":WHITE", 0x040, 1) -- 7
	elseif (level == 6)	then    send_input(":WHITE", 0x080, 1) -- 8
	end
	emu.wait(0.5)
        send_input(":EXTRA", 0x004, 1) -- press enter
        emu.wait(0.5)
	send_input(":EXTRA", 0x002, 1) -- press clear (not even necessary)
	end
end

function interface.get_promotion()
	return 'q'	-- CC Mk 2 always promotes to Queen
end

function interface.promote(x, y, piece)
	-- automatic promotion to Queen, nothing to do/set
end

return interface

