-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local lcd_num = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d }
	repeat
		send_input(":IN.0", 0x08, 0.6) -- LV
	until machine:outputs():get_value("digit1") == lcd_num[interface.level]
	send_input(":IN.0", 0x40, 0.5) -- CL
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":IN.0", 0x40, 0.5) -- CL
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x01, 0.5) -- RV
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")

	return xval[x] == d0 and yval[y] == d1
end

function interface.select_piece(x, y, event)
	if (event ~= "get_castling" and event ~= "put_castling") then
		sb_select_piece(":board", 1, x, y, event)
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
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	if     (piece == "q") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x08, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x04, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x02, 1)
	end
end

return interface
