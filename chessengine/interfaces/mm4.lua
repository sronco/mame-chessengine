-- license:BSD-3-Clause

interface = {}

interface.level = "le 1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":KEY.0", 0x10, 1) -- LEV
	if (interface.level:sub(1,2) == "bl") then
		send_input(":KEY.0", 0x10, 1) -- LEV
	end
	local n = tonumber(interface.level:sub(4))
	if     (n == 0) then send_input(":KEY.0", 0x40, 1)
	elseif (n == 1) then send_input(":KEY.1", 0x08, 1)
	elseif (n == 2) then send_input(":KEY.1", 0x20, 1)
	elseif (n == 3) then send_input(":KEY.1", 0x40, 1)
	elseif (n == 4) then send_input(":KEY.1", 0x80, 1)
	elseif (n == 5) then send_input(":KEY.1", 0x01, 1)
	elseif (n == 6) then send_input(":KEY.1", 0x02, 1)
	elseif (n == 7) then send_input(":KEY.1", 0x04, 1)
	elseif (n == 8) then send_input(":KEY.1", 0x10, 1)
	elseif (n == 9) then send_input(":KEY.0", 0x80, 1)
	end
	send_input(":KEY.0", 0x20, 1) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)
--	send_input(":KEY.0", 0x01, 1) -- CL
--	emu.wait(1.0)

	interface.cur_level = "le 1"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":KEY.0", 0x20, 1) -- ENT
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = output:get_value("digit3") & 0x7f
	local d1 = output:get_value("digit2") & 0x7f
	local d2 = output:get_value("digit1") & 0x7f
	local d3 = output:get_value("digit0") & 0x7f
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3) or output:get_value("led" .. tostring(8 * (y - 1) + (x - 1))) ~= 0
end

function interface.select_piece(x, y, event)
	local d0 = output:get_value("digit3") & 0x7f
	local d1 = output:get_value("digit2") & 0x7f
	local d2 = output:get_value("digit1") & 0x7f
	local d3 = output:get_value("digit0") & 0x7f
	if ((d0 == 0x31 and d1 == 0x30 and d2 == 0x37 and d3 == 0x79)
	or  (d0 == 0x77 and d1 == 0x06 and d2 == 0x77 and d3 == 0x06)) then -- 'TIME' or 'A1A1'
		send_input(":KEY.0", 0x01, 1) -- CL
	end
	sb_select_piece(":board:board", 1.5, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "le 1"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = string.lower(value:match("^%s*(.-)%s*$"):gsub("%s%s+"," ")) -- trim
		if (string.match(level,"^[0-9]$")) then
			level = "le " .. level
		end
		if (string.match(level,"^le [0-9]$") or string.match(level,"^bl [1-8]$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	send_input(":KEY.0", 0x08, 0.5)	-- INFO
	send_input(":KEY.1", 0x08, 0.5)	-- 1

	local d3 = 0
	for i=0,5 do
		local d0 = output:get_value("digit3") & 0x7f
		local d1 = output:get_value("digit2") & 0x7f

		if (d0 == 0x73 and d1 == 0x50) then	-- display shows 'Pr'
			d3 = output:get_value("digit0") & 0x7f
			break
		end
		send_input(":KEY.0", 0x40, 0.5)	-- 0
	end

	send_input(":KEY.0", 0x08, 0.5)	-- INFO

	if     (d3 == 0x5e) then	return "q"
	elseif (d3 == 0x31) then	return "r"
	elseif (d3 == 0x38) then	return "b"
	elseif (d3 == 0x6d) then	return "n"
	end

	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board:board", x, y, piece)
	if     (piece == "q") then	send_input(":KEY.1", 0x01, 1)
	elseif (piece == "r") then	send_input(":KEY.1", 0x80, 1)
	elseif (piece == "b") then	send_input(":KEY.1", 0x40, 1)
	elseif (piece == "n") then	send_input(":KEY.1", 0x20, 1)
	end
	if (piece == "q" or piece == "r" or piece == "b" or piece == "n") then
		send_input(":KEY.0", 0x20, 1)
	end
end

return interface
