-- license:BSD-3-Clause

interface = {}

interface.level = "1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	local level = tonumber(interface.level)
	local y = (level - 1) % 8 + 1
	local x = (level - y) / 8 + 1
	send_input(":IN.0", 0x04, 0.5) -- Set Level
	sb_press_square(":board", 0.5, x, y)
	send_input(":IN.1", 0x01, 0.5) -- Go
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":IN.1", 0x80, 0.5) -- New Game
	emu.wait(1)

	interface.cur_level = "1"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.1", 0x01, 0.5) -- Go
end

function interface.stop_play()
	send_input(":IN.1", 0x01, 0.5) -- Go
end

function interface.is_selected(x, y)
	local xval = output:get_value("1." .. tostring(x - 1)) ~= 0
	local yval = output:get_value("0." .. tostring(8 - y)) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 0.5, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = value:upper():match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		local n = tonumber(level)
		if (n ~= nil and n >= 1 and n <= 48) then
			level = n
		else
			local tmp = level:sub(1,2)
			if     (tmp == "TR") then tmp = 0
			elseif (tmp == "FT") then tmp = 1
			elseif (tmp == "SD") then tmp = 2
			elseif (tmp == "FD") then tmp = 3
			elseif (tmp == "AN") then tmp = 4
			elseif (tmp == "EA") then tmp = 5
			else return
			end
			n = tonumber(level:sub(3,4))
			if (n == nil or n < 1 or n > 8) then
				return
			end
			level = tmp * 8 + n
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	local map = {"s0.1","s1.1","s2.1","s3.0","s2.0","s0.0","s1.0"}
	local dig = 0x00
	for i=1,7 do
		if (output:get_value(map[i]) ~= 0) then
			dig = dig | (1 << (i-1))
		end
	end
	if     (dig == 0x67) then return 'q'
	elseif (dig == 0x50) then return 'r'
	elseif (dig == 0x7c) then return 'b'
	elseif (dig == 0x54) then return 'n'
	end
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	if     (piece == "q") then send_input(":IN.0", 0x40, 1)
	elseif (piece == "r") then send_input(":IN.0", 0x20, 1)
	elseif (piece == "b") then send_input(":IN.0", 0x10, 1)
	elseif (piece == "n") then send_input(":IN.0", 0x08, 1)
	end
end

return interface
