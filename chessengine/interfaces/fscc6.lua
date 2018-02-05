-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":IN.8", 0x40, 0.5)
end

function interface.start_play()
	send_input(":IN.8", 0x01, 0.5)
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")

	return xval[x] == d0 and yval[y] == d1
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling") then
		send_input(":IN." .. tostring(x - 1), 1 << (y - 1), 1)
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
		local lcd_num = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d }
		repeat
			send_input(":IN.8", 0x08, 0.5)
		until machine:outputs():get_value("digit1") == lcd_num[level]
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x04, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x02, 1)
	end
end

return interface
