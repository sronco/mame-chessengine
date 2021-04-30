-- license:BSD-3-Clause

interface = {}

interface.turn = true
interface.color = "B"
interface.level = "10"
interface.cur_level = nil
interface.levelnum = 1
local computing
local ddram

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level or interface.levelnum == 0) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	if (interface.levelnum > 1) then
		level = level:sub(level:find("%s")+1)
	end
	send_input(":IN.4", 0x08, 0.25) -- CE
	local mode = 1
	for i=2,4 do
		if (output:get_value("0.7." .. tostring(12-i)) ~= 0x00) then
			mode = i
			break
		end
	end
	mode = (interface.levelnum - mode + 4) % 4
	for i=0,mode do
		send_input(":IN.4", 0x10, 0.25) -- Mode
	end
	local k = 0
	for i=1,level:len() do
		local d = level:sub(i,i)
		if (d == " " or d == "/") then
			if (k == 15) then
				break
			end
			send_input(":IN.4", 0x04, 0.25) -- Enter
			k = k + 1
		elseif (string.match(d,"%d")) then
			if (tonumber(d) <= 5) then
				send_input(":IN.2", 1 << d, 0.25)
			elseif (tonumber(d) <= 9) then
				send_input(":IN.3", 1 << (d - 6), 0.25)
			end
		end
	end
	send_input(":IN.4", 0x04, 0.25) -- Enter
	if (interface.levelnum == 4) then
		send_input(":IN.4", 0x08, 0.25) -- CE
	end
	send_input(":IN.4", 0x20, 0.25) -- Start Clock
end

function interface.setup_machine()
	interface.turn = true
	interface.color = "B"
	emu.wait(2.0)
	send_input(":IN.0", 0x02, 0.5) -- New Game
	emu.wait(0.5)
	send_input(":IN.3", 0x08, 0.5) -- Yes
	emu.wait(0.5)

	interface.cur_level = ""
	interface.setlevel()
end

function interface.start_play(init)
	if (interface.color == "W") then
		interface.color = "B"
	else
		interface.color = "W"
	end
	interface.turn = false
	send_input(":IN.4", 0x02, 1) -- Go
end

function interface.stop_play()
	if (not interface.turn) then
		send_input(":IN.4", 0x02, 0.5) -- Go
		emu.wait(0.5)
		send_input(":IN.3", 0x08, 0.5) -- Yes
		emu.wait(0.5)
	end
end

function interface.is_selected(x, y)
	if (x == 1 and y == 1) then
--		computing = (machine.devices[':maincpu'].spaces['program']:read_u8(0x3de4) ~= 0x00) -- COMPUTING?
		computing = (output:get_value("0.7.11") ~= 0x00) -- COMPUTING?
		if (not computing) then
			local ram = machine.devices[':maincpu'].spaces['program']:read_range(0x3e70, 0x3e80, 8)
			ddram = {}
			for i=1,16 do
				ddram[i] = string.byte(string.sub(ram, i))
			end
		end
	end
	if (computing) then
		return false
	end
	local xval = { 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48 }
	local yval = { 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38 }
	local d0, d1, d2, d3, d4
	if (interface.color == "B") then
		d0 = ddram[7]
		d1 = ddram[8]
		d2 = ddram[9]
		d3 = ddram[10]
		d4 = ddram[11]
		if (d0 == 0x4f and d1 == 0x2d and d2 == 0x4f and d3 == 0x2d) then -- "0-0-", computer castles queenside
			if ((x == 5 or x == 3) and (y == 8)) then
				return true
			else
				return false
			end
		end
		if (d0 == 0x4f and d1 == 0x2d and d2 == 0x4f and d3 == 0x3a) then -- "0-0:", computer castles kingside
			if ((x == 5 or x == 7) and (y == 8)) then
				return true
			else
				return false
			end
		end
	else
		d0 = ddram[4]
		d1 = ddram[5]
		d2 = ddram[6]
		d3 = ddram[7]
		d4 = ddram[8]
		if (d0 == 0x4f and d1 == 0x2d and d2 == 0x4f and d3 == 0x2d) then -- "0-0-", computer castles queenside
			if ((x == 5 or x == 3) and (y == 1)) then
				return true
			else
				return false
			end
		end
		if (d0 == 0x4f and d1 == 0x2d and d2 == 0x4f and d3 == 0x3a) then -- "0-0:", computer castles kingside
			if ((x == 5 or x == 7) and (y == 1)) then
				return true
			else
				return false
			end
		end
	end
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d3 and yval[y] == d4)
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.2", 0x02, 0.5)
	elseif (p == 2)	then	send_input(":IN.2", 0x04, 0.5)
	elseif (p == 3)	then	send_input(":IN.2", 0x08, 0.5)
	elseif (p == 4)	then	send_input(":IN.2", 0x10, 0.5)
	elseif (p == 5)	then	send_input(":IN.2", 0x20, 0.5)
	elseif (p == 6)	then	send_input(":IN.3", 0x01, 0.5)
	elseif (p == 7)	then	send_input(":IN.3", 0x02, 0.5)
	elseif (p == 8)	then	send_input(":IN.3", 0x04, 0.5)
	end
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (interface.turn) then
			interface.send_pos(x)
			interface.send_pos(y)
		end

		if (event == "put") then
			if (interface.turn) then
				send_input(":IN.4", 0x04, 1) -- Enter
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "string", "Level", "10"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		interface.levelnum = 0
		local level = string.upper(value:match("^%s*(.-)%s*$"):gsub("%s%s+"," ")) -- trim
		local n = tonumber(level)
		if (n ~= nil and n >= 0 and n <= 999) then
			interface.levelnum = 1
		elseif (level:sub(1,8) == "PROBLEM " or level:sub(1,5) == "MATE " or level:sub(1,5) == "MATT ") then
			n = tonumber(level:sub(level:find("%s") + 1))
			if (n ~= nil and n >= 1 and n <= 7) then
				interface.levelnum = 2
			end
		elseif (level:sub(1,6) == "SPEED " or level:sub(1,6) == "BLITZ ") then
			n = tonumber(level:sub(7))
			if (n ~= nil and n >= 0 and n <= 999) then
				interface.levelnum = 3
			end
		elseif (level:sub(1,6) == "TOURN " or level:sub(1,5) == "TURN ") then
			interface.levelnum = 4
		end
		if (interface.levelnum ~=0) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	local p
	if (interface.color == "B") then
		p = machine.devices[':maincpu'].spaces['program']:read_u8(0x3e70 + 12) -- piece for black promotion
	else
		p = machine.devices[':maincpu'].spaces['program']:read_u8(0x3e70 + 9)  -- piece for white promotion
	end

	if (p == 0x51) then return 'q'
	elseif (p == 0x52) then return 'r'
	elseif (p == 0x42) then return 'b'
	elseif (p == 0x4e) then return 'n'
	end

	return nil
end

function interface.promote(x, y, piece)
	-- TODO: remove 'Enter' before sending promotion piece!
	if     (piece == "q") then	send_input(":IN.2", 0x20, 0.5)
	elseif (piece == "r") then	send_input(":IN.2", 0x10, 0.5)
	elseif (piece == "b") then	send_input(":IN.2", 0x08, 0.5)
	elseif (piece == "n") then	send_input(":IN.2", 0x04, 0.5)
	end
	if (piece == "q" or piece == "r" or piece == "b" or piece == "n") then
		send_input(":IN.4", 0x04, 1) -- Enter
	end
end

return interface
