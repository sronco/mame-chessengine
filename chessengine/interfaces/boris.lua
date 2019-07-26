-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.turn = true
interface.color = "B"
interface.level = "00"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local s = "000000"
	local level = s:sub(1,6-interface.level:len()) .. interface.level
	send_input(":IN.0", 0x04, 0.5) -- SET
	emu.wait(0.5)
	send_input(":IN.0", 0x08, 0.5) -- CE
	emu.wait(0.5)
	for i=1,6 do
		local n = tonumber(level:sub(i,i))
		if (n==0) then
			send_input(":IN.3", 0x01, 0.5)
		elseif (n<=3) then
			send_input(":IN.2", 0x01 << (n-1), 0.5)
		elseif (n<=6) then
			send_input(":IN.1", 0x01 << (n-4), 0.5)
		elseif (n<=9) then
			send_input(":IN.0", 0x01 << (n-7), 0.5)
		end
	end
	send_input(":IN.3", 0x08, 0.5) -- ENTER
	emu.wait(0.5)
end

function interface.setup_machine()
	interface.turn = true
	interface.color = "B"
	send_input(":RESET", 0x01, 0.5) -- RESET
	emu.wait(0.1)
	send_input(":RESET", 0x01, 0.5) -- RESET
	emu.wait(10.0)

	interface.cur_level = "00"
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		send_input(":IN.3", 0x04, 0.5) -- B/W
	end
	if (interface.color == "W") then
		interface.color = "B"
	else
		interface.color = "W"
	end
	interface.turn = false
	send_input(":IN.3", 0x08, 0.5) -- ENTER
	emu.wait(0.25)
end

function interface.is_selected_int(x, y)
	local xval = { 0x3cf, 0x0e3f, 0x00f3, 0x0c3f, 0x01f3, 0x01c3, 0x02fb, 0x03cc }
	local yval = { 0xc31, 0x0377, 0x023f, 0x038c, 0x03bb, 0x03fb, 0x4803, 0x03ff }
	local d0 = machine:outputs():get_value("digit7")
	local d1 = machine:outputs():get_value("digit6")
	local d2 = machine:outputs():get_value("digit5")
	local d3 = machine:outputs():get_value("digit4")
	local d4 = machine:outputs():get_value("digit3")
	return (d2 == 0x0003 or interface.color == "W") and (d2 == 0x0030 or interface.color == "B") and ((xval[x] == d0 and yval[y] == d1) or (xval[x] == d3 and yval[y] == d4))
end

function interface.is_selected(x, y)
	if (interface.is_selected_int(x, y)) then
		emu.wait(0.3)
		return interface.is_selected_int(x, y)
	end

	return false
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.2", 0x01, 0.5)
	elseif (p == 2)	then	send_input(":IN.2", 0x02, 0.5)
	elseif (p == 3)	then	send_input(":IN.2", 0x04, 0.5)
	elseif (p == 4)	then	send_input(":IN.1", 0x01, 0.5)
	elseif (p == 5)	then	send_input(":IN.1", 0x02, 0.5)
	elseif (p == 6)	then	send_input(":IN.1", 0x04, 0.5)
	elseif (p == 7)	then	send_input(":IN.0", 0x01, 0.5)
	elseif (p == 8)	then	send_input(":IN.0", 0x02, 0.5)
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
				send_input(":IN.3", 0x08, 0.5) -- ENTER
				emu.wait(0.25)
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "string", "Level", "00"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
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
