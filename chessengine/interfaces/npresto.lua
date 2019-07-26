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
	repeat
		send_input(":IN.0", 0x10, 0.5) -- Set Level
		local cur_level = 0
		for y=0,7 do
			if machine:outputs():get_indexed_value("0.", y) ~= 0 then
				cur_level = cur_level + 1
			end
		end
	until cur_level == interface.level
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	emu.wait(1)
	send_input(":IN.0", 0x80, 0.6) -- Go
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
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
end

return interface
