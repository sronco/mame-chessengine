-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

-- TODO:
-- * player castling
-- * UCI level option does not work yet
-- * player pawn promotion

interface = {}

local turn = true
local invert = false

function interface.setup_machine()
	turn = true
	invert = false
	emu.wait(1.0)
	send_input(":LINE3", 0x80, 1) -- difficulty level 1
	emu.wait(1.0)
	send_input(":LINE1", 0x80, 1) -- select game A
end

function interface.start_play()
end

function interface.is_selected(x, y)
	if (invert) then
		x = 9 - x
		y = 9 - y
	end
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 } -- A to H
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f } -- 1 to 8
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	if (d0 == 0x3f and d1 == 0x40 and d2 == 0x3f and d3 == 0x77) then -- "0-0A", computer castles queenside
		if ((x == 5 or x == 3) and (y == 8)) then
			return true
		else
			return false
		end
	end
	if (d0 == 0x3f and d1 == 0x40 and d2 == 0x3f and d3 == 0x76) then -- "0-0H", computer castles kingside
		if ((x == 5 or x == 7) and (y == 8)) then
			return true
		else
			return false
		end
	end
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos1(p)  -- "A" to "H" keys
	if     (p == 1)	then	send_input(":LINE1", 0x80, 1)
	elseif (p == 2)	then	send_input(":LINE1", 0x40, 1)
	elseif (p == 3)	then	send_input(":LINE1", 0x20, 1)
	elseif (p == 4)	then	send_input(":LINE1", 0x10, 1)
	elseif (p == 5)	then	send_input(":LINE2", 0x80, 1)
	elseif (p == 6)	then	send_input(":LINE2", 0x40, 1)
	elseif (p == 7)	then	send_input(":LINE2", 0x20, 1)
	elseif (p == 8)	then	send_input(":LINE2", 0x10, 1)
	end
end

function interface.send_pos2(p)  -- "1" to "8" keys
	if     (p == 1)	then	send_input(":LINE3", 0x80, 1)
	elseif (p == 2)	then	send_input(":LINE3", 0x40, 1)
	elseif (p == 3)	then	send_input(":LINE3", 0x20, 1)
	elseif (p == 4)	then	send_input(":LINE3", 0x10, 1)
	elseif (p == 5)	then	send_input(":LINE4", 0x80, 1)
	elseif (p == 6)	then	send_input(":LINE4", 0x40, 1)
	elseif (p == 7)	then	send_input(":LINE4", 0x20, 1)
	elseif (p == 8)	then	send_input(":LINE4", 0x10, 1)
	end
end

function interface.select_piece(x, y, event)
	if (invert) then
		x = 9 - x
		y = 9 - y
	end
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (turn) then
			interface.send_pos1(x)
			interface.send_pos2(y)
		end


		if (event == "put") then
			if (turn) then
				send_input(":LINE1", 0x10, 1) -- press play
			end
			turn = not turn
		end
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
		send_input(":RESET", 0x01, 1)
		emu.wait(1.0)
		send_input(":RESET", 0x01, 1)
		emu.wait(1.0)
		if     (level == 1)	then	send_input(":LINE3", 0x80, 1)
		elseif (level == 2)	then	send_input(":LINE3", 0x40, 1)
		elseif (level == 3)	then	send_input(":LINE3", 0x20, 1)
		elseif (level == 4)	then	send_input(":LINE3", 0x10, 1)
		elseif (level == 5)	then	send_input(":LINE4", 0x80, 1)
		elseif (level == 6)	then	send_input(":LINE4", 0x40, 1)
		end
		emu.wait(1.0)
		send_input(":LINE1", 0x20, 1) -- press "C"
	end
end

function interface.get_promotion()
	return 'q'	-- CC Mk 1 always promotes to Queen
end

function interface.promote(x, y, piece)
	-- TODO
end

return interface
