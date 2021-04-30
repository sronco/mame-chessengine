-- license:BSD-3-Clause

interface = {}

interface.level = "a2"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = interface.level:sub(2, 2)
	send_input(":IN.1", 0x02, 0.5)  -- Level
	sb_press_square(":board", 0.5, x, y)
	send_input(":IN.1", 0x02, 0.5)  -- Level
end

function interface.setup_machine()
	sb_reset_board(":board")
--	send_input(":IN.1", 0x80, 0.5) -- New Game
	emu.wait(1.0)

	interface.cur_level = "a2"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x01, 0.5) -- Move
end

function interface.is_selected(x, y)
	return output:get_value((y - 1) .. "." .. (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 0.5, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a2"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:lower():match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		if (level:match("^[a-g][1-8]$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	local new_type = nil
	if     (output:get_value("8.4") ~= 0) then new_type = 'q'
	elseif (output:get_value("8.3") ~= 0) then new_type = 'r'
	elseif (output:get_value("8.2") ~= 0) then new_type = 'b'
	elseif (output:get_value("8.1") ~= 0) then new_type = 'n'
	end
	if (new_type ~= nil) then
		interface.select_piece(x, y, "")
	end
	return new_type
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	emu.wait(0.5)
	if     (piece == "q") then send_input(":IN.0", 0x40, 1)
	elseif (piece == "r") then send_input(":IN.0", 0x20, 1)
	elseif (piece == "b") then send_input(":IN.0", 0x10, 1)
	elseif (piece == "n") then send_input(":IN.0", 0x08, 1)
	end
end

return interface
