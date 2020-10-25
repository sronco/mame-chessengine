interface = {}

interface.level = 1
interface.cur_level = nil
interface.get_prom = false

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	while machine:outputs():get_indexed_value("7.", level - 1) == 0 do
		send_input(":IN.0", 0x10, 1.0) -- Level
	end
end

function interface.setup_machine()
	sb_reset_board(":board")
--	send_input(":IN.1", 0x02, 1) -- Reset
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.2", 0x10, 1)    -- Move
end

function interface.stop_play()
	send_input(":IN.2", 0x08, 1)    -- Interrupt
end

function interface.is_selected(x, y)
	if (machine:outputs():get_value((x - 1) .. "." .. (y - 1)) ~= 0) then
		if (math.abs(get_piece_id(x, y)) == 1) then
			emu.wait(1)
			return machine:outputs():get_value((x - 1) .. "." .. (y - 1)) ~= 0
		end
		return true
	end
	return false
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
	interface.get_prom = true
	local new_type = nil
	if     (machine:outputs():get_value("8.4") ~= 0) then new_type = 'q'
	elseif (machine:outputs():get_value("8.3") ~= 0) then new_type = 'r'
	elseif (machine:outputs():get_value("8.1") ~= 0) then new_type = 'b'
	elseif (machine:outputs():get_value("8.2") ~= 0) then new_type = 'n'
	end
	return new_type
end

function interface.promote(x, y, piece)
	if interface.get_prom == true then
		interface.get_prom = false
		interface.select_piece(x, y, "")
	end
	sb_promote(":board", x, y, piece)
end

return interface
