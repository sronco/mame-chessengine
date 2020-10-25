interface = {}

interface.level = "1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local lcd_lev = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67, 0x76 }
	local level = interface.level
	local lev = "123456789H"
	lev = lev:find(level:sub(1,1))
	repeat
		send_input(":IN.1", 0x08, 0.75) -- LV
	until machine:outputs():get_value("digit0") == lcd_lev[lev]
	send_input(":IN.1", 0x01, 0.5) -- TM
end

function interface.setup_machine()
	sb_reset_board(":board")
--	send_input(":IN.0", 0x80, 1) -- RE
	emu.wait(1.0)
	send_input(":IN.0", 0x40, 1) -- CL
	emu.wait(1.0)

	interface.cur_level = "1"
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		sb_press_square(":board", 1, 5, 8) -- e8 (black king)
	else
		send_input(":IN.0", 0x40, 1) -- CL
		send_input(":IN.1", 0x02, 1) -- RV
	end
end

function interface.stop_play()
	send_input(":IN.1", 0x20, 1) -- ST
end

function interface.is_selected(x, y)
	return machine:outputs():get_value(tostring(x - 1) .. "." .. tostring(y - 1 + 8)) ~= 0
end

function interface.select_piece(x, y, event)
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
	elseif (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	elseif (event ~= "capture") then
		sb_select_piece(":board", 1, x, y, event)
	end
end

function interface.get_options()
	return { { "string", "Level", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:upper():match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		if (level:match("^[1-9H]$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	emu.wait(1)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x02, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x04, 1)
	end
end

return interface
