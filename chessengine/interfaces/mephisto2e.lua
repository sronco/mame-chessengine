-- license:BSD-3-Clause

interface = {}

interface.level = "a3"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	send_input(":IN.1", 0x04, 0.5) -- LEV
	for i=1,level:len() do
		local c = level:sub(i,i)
		if (c:match("[a-h]")) then
			interface.send_pos(cols_idx[c])
		elseif (c:match("[1-8]")) then
			interface.send_pos(tonumber(c))
		elseif (c == "0") then
			send_input(":IN.3", 0x01, 0.5) -- 0
		elseif (c == "9") then
			send_input(":IN.2", 0x04, 0.5) -- 9
		elseif (c == " ") then
			send_input(":IN.0", 0x04, 0.5) -- ENT
		end
	end
	send_input(":IN.0", 0x04, 0.5) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":RESET", 0x01, 0.5)  -- RES
	emu.wait(1.0)
	send_input(":IN.0", 0x01, 0.5) -- CL

	interface.cur_level = "a3"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.1", 0x01, 0.5) -- STA
end

function interface.stop_play()
	send_input(":IN.0", 0x04, 0.5) -- ENT
end

function interface.is_selected(x, y)
	return output:get_value((y - 1) .. "." .. (x - 1)) ~= 0
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.0", 0x02, 0.5)
	elseif (p == 2)	then	send_input(":IN.0", 0x08, 0.5)
	elseif (p == 3)	then	send_input(":IN.1", 0x02, 0.5)
	elseif (p == 4)	then	send_input(":IN.1", 0x08, 0.5)
	elseif (p == 5)	then	send_input(":IN.2", 0x02, 0.5)
	elseif (p == 6)	then	send_input(":IN.2", 0x08, 0.5)
	elseif (p == 7)	then	send_input(":IN.3", 0x02, 0.5)
	elseif (p == 8)	then	send_input(":IN.3", 0x08, 0.5)
	end
end

function interface.select_piece(x, y, event)
	if (event == "get_castling" or event == "en_passant" or event == "capture") then
		emu.wait(1)
	end

	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a3"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," "):lower() -- trim
		if (level:match("^[a-d][1-7]$") or level:match("^[ef][1-8]$") or level:match("^[gh][2-8]$")
		or  level:match("^[a-d]8%s%d%d:?%d%d?$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	-- TODO
end

return interface
