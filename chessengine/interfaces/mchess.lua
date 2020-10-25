interface = {}

interface.turn = true
interface.selected = {}
interface.selected_cnt = 0
interface.cursor = {y = 1, x = 1}
interface.level = 1
interface.cur_level = nil
interface.init = false

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	repeat
		local lev2 = machine:outputs():get_value("1.2.20")
		local lev3 = machine:outputs():get_value("1.3.20")
		local lev4 = machine:outputs():get_value("1.7.20")
		if (1 + lev2 + lev3 + lev4 ~= interface.level) then
			send_input(":IN.0", 0x10, 0.2) -- LEVEL
		end
	until 1 + lev2 + lev3 + lev4 == interface.level
end

function interface.setup_machine()
	interface.turn = true
	interface.selected = {}
	interface.selected_cnt = 0
	interface.cursor = {y = 1, x = 1}
	if (interface.init) then
		local ddram0 = emu.item(machine.devices[':lcd0'].items['0/m_ram'])
		local ddram1 = emu.item(machine.devices[':lcd1'].items['0/m_ram'])
		for i=0,0x1f do
			ddram0:write(i, 0x00)
			ddram1:write(i, 0x00)
		end
		machine:soft_reset()
	end
	emu.wait(1.0)
	interface.init = true

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.1", 0x02, 1) -- MOVE
	interface.turn = false
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
	elseif (y == 5 and x < 8 and piece_id == -6 and interface.selected[(y+1)*10+x] == 0 and interface.selected[y*10+(x+1)] ==  6) then	return false	-- white en passant
	elseif (y == 5 and x > 1 and piece_id == -6 and interface.selected[(y+1)*10+x] == 0 and interface.selected[y*10+(x-1)] ==  6) then	return false	-- white en passant
	elseif (y == 4 and x < 8 and piece_id ==  6 and interface.selected[(y-1)*10+x] == 0 and interface.selected[y*10+(x+1)] == -6) then	return false	-- black en passant
	elseif (y == 4 and x > 1 and piece_id ==  6 and interface.selected[(y-1)*10+x] == 0 and interface.selected[y*10+(x-1)] == -6) then	return false	-- black en passant
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

function interface.is_selected(x, y)
	local ytag = 1
	local xtag = { 0, 1, 2, 3, 7, 6, 5, 4 }
	if (y > 4) then
		ytag = 0
		xtag =  { 3, 2, 1, 0, 7, 6, 5, 4 }
	end

	local piece0 = machine:outputs():get_value(ytag .. "." .. xtag[x] .. "." .. tostring(19 - ((y - 1) & 3) * 5))
	local piece1 = machine:outputs():get_value(ytag .. "." .. xtag[x] .. "." .. tostring(16 - ((y - 1) & 3) * 5))
	local piece2 = machine:outputs():get_value(ytag .. "." .. xtag[x] .. "." .. tostring(18 - ((y - 1) & 3) * 5))
	local piece3 = machine:outputs():get_value(ytag .. "." .. xtag[x] .. "." .. tostring(15 - ((y - 1) & 3) * 5))

	local piece = 0
	if ((piece0 + piece1) ~= 0 and (piece2 + piece3) ~= 0) then	piece = -1
	elseif ((piece0 + piece1) ~= 0 and (piece2 + piece3) == 0) then	piece = 1
	end

	return interface.is_pos_selected(x, y, piece)
end

function interface.select_piece(x, y, event)
	if (interface.turn) then
		if (event == "get" or event == "put") then
			if (event == "get") then
				send_input(":IN.1", 0x08, 0.7) -- LEFT
			end

			while x < interface.cursor.x do
				interface.cursor.x = interface.cursor.x - 1
				send_input(":IN.1", 0x08, 0.7) -- LEFT
			end

			while x > interface.cursor.x do
				interface.cursor.x = interface.cursor.x + 1
				send_input(":IN.1", 0x04, 0.7) -- RIGHT
			end

			while y < interface.cursor.y do
				interface.cursor.y = interface.cursor.y - 1
				send_input(":IN.1", 0x80, 0.7) -- DOWN
			end

			while y > interface.cursor.y do
				interface.cursor.y = interface.cursor.y + 1
				send_input(":IN.1", 0x10, 0.7) -- UP
			end

			if (event == "get") then
				send_input(":IN.1", 0x02, 0.7) -- MOVE
			else
				send_input(":IN.2", 0x02, 0.7) -- ENTER
				emu.wait(1)
			end
		end
	end
	if (event == "put") then
		interface.turn = not interface.turn
		interface.selected = {}
		interface.selected_cnt = 0
		emu.wait(2)
	end
	if (event == "get" or event == "put") then
		interface.cursor = {y = y, x = x}
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "4"}, }
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
