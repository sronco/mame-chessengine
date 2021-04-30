-- license:BSD-3-Clause

interface = {}

interface.level = "a1"
interface.cur_level = nil
interface.turn = true
interface.capt = 0

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = tonumber(interface.level:sub(2, 2))
	send_input(":IN.0", 0x004, 0.5) -- LEVEL
	sb_press_square(":board", 0.5, x, y)
	send_input(":IN.0", 0x080, 0.5) -- CLEAR
end

function interface.setup_machine()
	interface.turn = true
	interface.capt = 0
	sb_reset_board(":board")
	emu.wait(2.75)
	for i=1,41 do
		machine:popmessage("board test " .. tostring(41-i))
		emu.wait(1)
	end

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.start_play(init)
	interface.turn = false
	send_input(":IN.0", 0x20, 1) -- MOVE
end

function interface.stop_play()
	send_input(":IN.0", 0x20, 1) -- MOVE
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d1 = output:get_value("digit1")
	local d2 = output:get_value("digit2")
	local d3 = output:get_value("digit3")
	local d4 = output:get_value("digit4")
	return (xval[x] == d1 and yval[y] == d2) or (xval[x] == d3 and yval[y] == d4)
end

local function removepiece(p)
	local z = 9
	if (p > 0) then
		send_input(":board:SPAWN", 0x001<<( 6-p), 1)
		z = 12
	elseif (p < 0) then
		send_input(":board:SPAWN", 0x001<<(12+p), 1)
	end
	sb_move_piece(":board", z, 8)
	sb_press_square(":board", 1, z, 8)
end

function interface.select_piece(x, y, event)
	if (output:get_value("digit2") == 0x40) then -- castling & enpassant
		sb_select_piece(":board", 1, x, y, event)
		if     (y == 4) then removepiece( 6)
		elseif (y == 5) then removepiece(-6)
		end
		return
	end
	if (interface.turn) then
		if (event == "get") then
			repeat
				emu.wait(0.5)
			until output:get_value("4.7") ~= 0x00
		end
		sb_select_piece(":board", 1, x, y, event)
		if (interface.capt ~= 0) then -- capture
			local p = removepiece(interface.capt)
			interface.capt = 0
		elseif (event == "capture") then
			interface.capt = get_piece_id(x, y)
		end
	end
	if (event == "put") then
		interface.turn = not interface.turn
	end
end

function interface.get_options()
	return { { "string", "Level", "a1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," "):lower() -- trim
		if (level:match("^[a-h][1-8]$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	return 'q' -- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	local z = 11
	if (y == 1) then
		z = 10
	end
	if     (piece == "q") then sb_press_square(":board", 1, z, 8)
	elseif (piece == "r") then sb_press_square(":board", 1, z, 7)
	elseif (piece == "b") then sb_press_square(":board", 1, z, 6)
	elseif (piece == "n") then sb_press_square(":board", 1, z, 5)
	end
end

return interface
