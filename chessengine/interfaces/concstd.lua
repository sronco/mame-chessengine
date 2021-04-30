-- license:BSD-3-Clause

interface = {}

interface.level = "P2"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	local cur_level = (interface.cur_level .. "6"):sub(1,2)
	local level = (interface.level .. "6"):sub(1,2)
	interface.cur_level = interface.level
	local count = 1
	if (level:sub(2,2) ~= cur_level:sub(2,2) and level:sub(1,1):match("[TM]")) then
		count = 2
	end
	send_input(":IN.0", 0x40, 0.5) -- Level
	emu.wait(0.5)
	for i=1,count do
		send_input(":IN.1", 0x01 << (tonumber(level:sub(2,2)) - 1), 0.5)
	end
	emu.wait(0.5)
	send_input(":IN.0", 0x02, 0.5) -- Stop
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)
--	send_input(":IN.0", 0x01, 0.5) -- Clear
--	send_input(":IN.0", 0x80, 0.5) -- Continue

	interface.cur_level = "P2"
	interface.setlevel()
end

function interface.start_play(init)
	if     (output:get_value("9.7") ~= 0) then send_input(":IN.1", 0x80, 0.5) -- Black
	elseif (output:get_value("9.6") ~= 0) then send_input(":IN.1", 0x40, 0.5) -- White
	end
end

function interface.stop_play()
	send_input(":IN.0", 0x02, 0.5) -- Stop
end

function interface.is_selected(x, y)
	return output:get_indexed_value(tostring(9 - x) .. ".", y - 1) ~= 0
end

function interface.select_piece(x, y, event)
	if (event == "get") then
		if (output:get_value("0.1") ~= 0 and output:get_value("0.7") ~= 0) then
			send_input(":IN.0", 0x80, 0.5) -- Continue
			emu.wait(0.5)
		end
	end
	if (event == "en_passant") then
		sb_remove_piece(":board", x, y)
	elseif (event == "get_castling" or event == "put_castling") then
		sb_move_piece(":board", x, y)
	else
		sb_select_piece(":board", 1, x, y, event)
	end
end

function interface.get_options()
	return { { "string", "Level", "P2"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," "):upper() -- trim
		if (level:match("^[PT][1-5]$") or level:match("^[AM]$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	for i=0,5 do
		if     (output:get_value("9.4") ~= 0) then return 'q'
		elseif (output:get_value("9.3") ~= 0) then return 'r'
		elseif (output:get_value("9.2") ~= 0) then return 'b'
		elseif (output:get_value("9.1") ~= 0) then return 'n'
		end
		emu.wait(0.2)
	end
	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	if     (piece == "q" or piece == "Q") then send_input(":IN.1", 0x10, 0.5)
	elseif (piece == "r" or piece == "R") then send_input(":IN.1", 0x08, 0.5)
	elseif (piece == "b" or piece == "B") then send_input(":IN.1", 0x04, 0.5)
	elseif (piece == "n" or piece == "N") then send_input(":IN.1", 0x02, 0.5)
	end
end

return interface
