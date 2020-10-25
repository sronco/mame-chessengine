interface = {}

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local hold = 0.5
	if machine:outputs():get_value("fast") == 1 then
		hold = 0.25
	end
	send_input(":IN.0", 0x10, hold) -- Set Level
	emu.wait(0.75-hold)
	local k = 8
	while machine:outputs():get_indexed_value("0.", k - 1) == 0 do
		k = k - 1
	end
	k = (interface.level - k + 8) % 8
	for i=1,k do
		send_input(":IN.0", 0x10, hold) -- Set Level
		emu.wait(0.75-hold)
	end
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	local hold = 0.5
	if machine:outputs():get_value("fast") == 1 then
		hold = 0.25
	end
	send_input(":IN.0", 0x80, hold) -- Go
end

function interface.stop_play()
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_indexed_value("1.", (x - 1)) ~= 0
	local yval = machine:outputs():get_indexed_value("0.", (y - 1)) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
	elseif (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	else
		sb_select_piece(":board", 0.5, x, y, event)
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
end

return interface
