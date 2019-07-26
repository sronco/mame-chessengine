-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.turn = true
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":IN.2", 0x01, 0.5) -- LV
	if (interface.level > 4) then
		send_input(":IN.1", 0x01 << ((interface.level - 1) & 0x03), 0.5)
	else
		send_input(":IN.0", 0x01 << ((interface.level - 1) & 0x03), 0.5)
	end
	send_input(":IN.3", 0x02, 0.5) -- ENTER
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.turn = true
	send_input(":IN.3", 0x01, 1) -- CE
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.3", 0x02, 1) -- ENTER
	interface.turn = false
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit3")
	local d1 = machine:outputs():get_value("digit2")
	local d2 = machine:outputs():get_value("digit1")
	local d3 = machine:outputs():get_value("digit0")
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.0", 0x01, 1)
	elseif (p == 2)	then	send_input(":IN.0", 0x02, 1)
	elseif (p == 3)	then	send_input(":IN.0", 0x04, 1)
	elseif (p == 4)	then	send_input(":IN.0", 0x08, 1)
	elseif (p == 5)	then	send_input(":IN.1", 0x01, 1)
	elseif (p == 6)	then	send_input(":IN.1", 0x02, 1)
	elseif (p == 7)	then	send_input(":IN.1", 0x04, 1)
	elseif (p == 8)	then	send_input(":IN.1", 0x08, 1)
	end
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 0.09, x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (interface.turn) then
			interface.send_pos(x)
			interface.send_pos(y)
		end

		if (event == "put") then
			if (interface.turn) then
				-- clears digits to avoid mistakes
				machine:outputs():set_value("digit0", 0)
				machine:outputs():set_value("digit1", 0)
				machine:outputs():set_value("digit2", 0)
				machine:outputs():set_value("digit3", 0)

				send_input(":IN.3", 0x02, 1) -- ENTER
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "8"}, }
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
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	-- TODO
end

return interface
