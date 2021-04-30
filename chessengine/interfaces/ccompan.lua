-- license:BSD-3-Clause

interface = {}

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	while output:get_value(tostring(level-1) .. ".1") == 0 do
		send_input(":IN.1", 0x80, 0.6) -- Change Level
	end
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1)
--	send_input(":IN.1", 0x01, 0.6)	-- New Game

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.1", 0x08, 0.8)	-- Play
end

function interface.is_selected(x, y)
	local xval = output:get_value(tostring(x - 1) .. ".0") ~= 0
	local yval = output:get_value(tostring(y - 1) .. ".1") ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	else
		sb_select_piece(":board", 0.6, x, y, event)
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
	if     (output:get_value("1.2") ~= 0) then return 'q'
	elseif (output:get_value("3.2") ~= 0) then return 'r'
	elseif (output:get_value("5.2") ~= 0) then return 'b'
	elseif (output:get_value("7.2") ~= 0) then return 'n'
	end
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, 'q')
	sb_press_square(":board", 0.6, x, y)
end

return interface
