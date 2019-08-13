-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}
interface.invert = false
interface.level = "a1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = tostring(tonumber(interface.level:sub(2, 2)))
	send_input(":IN.0", 0x08, 1)	-- LEVEL
	emu.wait(0.5)
	sb_press_square(":board", 1, x, y)
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
	emu.wait(8)
	send_input(":IN.0", 0x20, 1)	-- NEW GAME

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		sb_rotate_board(":board")
		interface.invert = true
	end
	send_input(":IN.1", 0x80, 1)	-- MOVE
end

function interface.is_selected(x, y)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	local xval = machine:outputs():get_value(tostring(x - 1) .. ".0") ~= 0
	local yval = machine:outputs():get_value(tostring(y - 1) .. ".1") ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end

	sb_select_piece(":board", 1, x, y, event)

	if (event == "put" or event == "put_castling") then
		emu.wait(1)
	end
end

function interface.get_options()
	return { { "string", "Level", "a1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	for i=0,5 do
		if     (machine:outputs():get_value("9.1") ~= 0) then return 'q'
		elseif (machine:outputs():get_value("9.2") ~= 0) then return 'r'
		elseif (machine:outputs():get_value("8.0") ~= 0) then return 'b'
		elseif (machine:outputs():get_value("8.1") ~= 0) then return 'n'
		end
		emu.wait(0.2)
	end
	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	if     (piece == "q" or piece == "Q") then	send_input(":IN.0", 0x01, 1)
	elseif (piece == "r" or piece == "R") then	send_input(":IN.1", 0x02, 1)
	elseif (piece == "b" or piece == "B") then	send_input(":IN.0", 0x02, 1)
	elseif (piece == "n" or piece == "N") then	send_input(":IN.1", 0x04, 1)
	end
end

return interface
