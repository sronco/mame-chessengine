-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.turn = true
interface.invert = false
interface.selected = {}
interface.selected_cnt = 0
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level

	local level_id = {0x182418, 0x381010, 0x3c1818, 0x3c383c, 0x207c20, 0x1c1c3c, 0x181c18, 0x04103c, 0x181818, 0x183818}
	repeat
		local levid = 0
		send_input(":IN.2", 0x04, 1) -- Set Level

		for x=0,7 do
			if (machine:outputs():get_value(tostring(x) .. "." .. tostring(50 - (8 - 1) * 3)) == 1) then	levid = levid | (1 << x)	end
			if (machine:outputs():get_value(tostring(x) .. "." .. tostring(50 - (5 - 1) * 3)) == 1) then	levid = levid | (1 << (8 + x))	end
			if (machine:outputs():get_value(tostring(x) .. "." .. tostring(50 - (2 - 1) * 3)) == 1) then	levid = levid | (1 << (16 + x))	end
		end
	until level_id[interface.level + 1] == levid

	send_input(":IN.1", 0x10, 1) -- Return
end

function interface.setup_machine()
	interface.turn = true
	interface.invert = false
	interface.selected = {}
	interface.selected_cnt = 0
	emu.wait(1.0)
	send_input(":IN.2", 0x08, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.1", 0x80, 1) -- Change Color
	send_input(":IN.2", 0x10, 1) -- Go
	interface.turn = not interface.turn
	interface.invert = not interface.invert
end

function interface.stop_play()
	send_input(":IN.2", 0x10, 1) -- Go
end

function interface.is_pos_selected(x, y, piece)
	local piece_id = get_piece_id(x, y)

	local selected = (piece_id == 0 and piece ~= 0) or (piece_id > 0 and piece <= 0) or (piece_id < 0 and piece >= 0)
	if (selected) then
		interface.selected[y*10+x] = piece_id
	end

	-- ignore the rook in castling
	if     (y == 1 and (x == 8 or x == 6) and (interface.selected[1*10+5] ==  1 and interface.selected[1*10+7] == 0 and interface.selected[1*10+8] ==  3)) then	return false	-- white kingside castling
	elseif (y == 1 and (x == 1 or x == 4) and (interface.selected[1*10+5] ==  1 and interface.selected[1*10+3] == 0 and interface.selected[1*10+1] ==  3)) then	return false	-- white queenside castling
	elseif (y == 8 and (x == 8 or x == 6) and (interface.selected[8*10+5] == -1 and interface.selected[8*10+7] == 0 and interface.selected[8*10+8] == -3)) then	return false	-- black kingside castling
	elseif (y == 8 and (x == 1 or x == 4) and (interface.selected[8*10+5] == -1 and interface.selected[8*10+3] == 0 and interface.selected[8*10+1] == -3)) then	return false	-- black queenside castling

	-- ignore en-passant capture
	elseif (y == 5 and x < 8 and piece_id == -6 and interface.selected[(y+1)*10+x] == 0 and interface.selected[y*10+(x+1)] ==  6) then 	return false	-- white en passant
	elseif (y == 5 and x > 1 and piece_id == -6 and interface.selected[(y+1)*10+x] == 0 and interface.selected[y*10+(x-1)] ==  6) then 	return false	-- white en passant
	elseif (y == 4 and x < 8 and piece_id ==  6 and interface.selected[(y-1)*10+x] == 0 and interface.selected[y*10+(x+1)] == -6) then 	return false	-- black en passant
	elseif (y == 4 and x > 1 and piece_id ==  6 and interface.selected[(y-1)*10+x] == 0 and interface.selected[y*10+(x-1)] == -6) then 	return false	-- black en passant
	end

	if (x == 1 and y == 1) then
		interface.selected_cnt = interface.selected_cnt + 1
	end
	if (interface.selected_cnt >= 25) then
		interface.selected_cnt = 0
		interface.selected = {}
	end

	-- wait complete scan before report selections
	if (interface.selected_cnt <= 3) then
		return false
	end

	return selected
end

function interface.is_selected_int(x, y)
	local piece0 = machine:outputs():get_value(tostring(x-1) .. "." .. tostring(50 - (y - 1) * 3))
	local piece1 = machine:outputs():get_value(tostring(x-1) .. "." .. tostring(23 - (y - 1) * 3))
	if (interface.invert) then
		piece0 = machine:outputs():get_value(tostring(8 -x) .. "." .. tostring(50 - (8 - y) * 3))
		piece1 = machine:outputs():get_value(tostring(8 -x) .. "." .. tostring(23 - (8 - y) * 3))
	end

	local piece = 0
	if (piece0 == 1 and piece1 == 1) then		piece = -1
	elseif (piece0 == 1 and piece1 == 0) then	piece = 1
	end

	return interface.is_pos_selected(x, y, piece)
end

function interface.is_selected(x, y)
	if (interface.is_selected_int(x, y)) then
		emu.wait(0.5)
		return interface.is_selected_int(x, y)
	end

	return false
end


function interface.select_piece(x, y, event)
	if (interface.invert) then
		x = 9 - x
		y = 9 - y
	end
	if (interface.turn) then
		if (event == "get" or event == "put") then
			sb_select_piece(":board", 0.5, x, y, event)
		end
	end
	if (event == "put") then
		interface.turn = not interface.turn
		interface.selected = {}
		interface.selected_cnt = 0
		emu.wait(2)
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "0", "9"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 9) then
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
	-- TODO
end

return interface
