-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

local turn = true

function interface.setup_machine()
	emu.wait(1.0)
end

function interface.start_play()
	turn = false
	send_input(":LINE7", 0x80, 1)
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":LINE4", 0x20, 1)
	elseif (p == 2)	then	send_input(":LINE2", 0x20, 1)
	elseif (p == 3)	then	send_input(":LINE3", 0x20, 1)
	elseif (p == 4)	then	send_input(":LINE1", 0x80, 1)
	elseif (p == 5)	then	send_input(":LINE4", 0x80, 1)
	elseif (p == 6)	then	send_input(":LINE2", 0x80, 1)
	elseif (p == 7)	then	send_input(":LINE3", 0x80, 1)
	elseif (p == 8)	then	send_input(":LINE5", 0x20, 1)
	end
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (turn) then
			interface.send_pos(x)
			interface.send_pos(y)
		end

		if (event == "put") then
			if (turn) then
				send_input(":LINE6", 0x80, 1)
			end
			turn = not turn
		end
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	-- TODO
end

return interface
