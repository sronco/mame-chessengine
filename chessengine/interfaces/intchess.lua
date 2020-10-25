interface = {}

interface.turn = true
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	local dval = { 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67 }
	local l0 = 0x38
	local l2 = 0x00
	local l3 = dval[level % 10 + 1]
	if (level > 9) then
		l2 = 0x06
	end
	repeat
		send_input(":X1", 0x04, 0.25)	-- LEVEL
		emu.wait(0.25)
		local d0 = machine:outputs():get_value("digit0")
		local d2 = machine:outputs():get_value("digit2")
		local d3 = machine:outputs():get_value("digit3")
	until (d0 == l0 and d2 == l2 and d3 == l3)
	send_input(":X2", 0x08, 0.25)		-- ENTER
	emu.wait(0.25)
end

function interface.setup_machine()
	interface.turn = true
	send_input(":RESET", 0x01, 0.25)	-- RESET
	emu.wait(0.5)
	send_input(":X2", 0x04, 0.25)		-- NEW GAME
	emu.wait(0.5)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":X2", 0x08, 0.25)	-- ENTER
	emu.wait(0.25)
	interface.turn = false

	interface.cur_level = 1
	interface.setlevel()
end

function interface.stop_play()
end

function interface.is_selected(x, y)
	if (x == 1 and y == 1) then
		computing = false
		for i=1,4 do
			if (machine:outputs():get_value("digit0") == 0) then
				computing = true
				return false
			elseif (i<4) then
				emu.wait(0.25)
			end
		end
	elseif (computing) then
		return false
	end
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	return ((xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3))
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":X1", 0x01, 0.25)
	elseif (p == 2)	then	send_input(":X2", 0x01, 0.25)
	elseif (p == 3)	then	send_input(":X3", 0x01, 0.25)
	elseif (p == 4)	then	send_input(":X4", 0x01, 0.25)
	elseif (p == 5)	then	send_input(":X1", 0x02, 0.25)
	elseif (p == 6)	then	send_input(":X2", 0x02, 0.25)
	elseif (p == 7)	then	send_input(":X3", 0x02, 0.25)
	elseif (p == 8)	then	send_input(":X4", 0x02, 0.25)
	end
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (interface.turn) then
			interface.send_pos(x)
			emu.wait(0.25)
			interface.send_pos(y)
			emu.wait(0.25)
		end

		if (event == "put") then
			if (interface.turn) then
				send_input(":X2", 0x08, 0.25) -- ENTER
				emu.wait(0.25)
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "13"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 13) then
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
