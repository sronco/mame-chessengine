interface = {}

interface.level = "1"
interface.cur_level = nil
interface.style = 5
interface.cur_style = nil

function interface.setvalue(n)
	for i=1,math.abs(n) do
		if (n > 0) then send_input(":IN.1", 0x04, 0.25) -- F.W.
		else send_input(":IN.2", 0x04, 0.25)		-- B.W.
		end
		end
end

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	local nvram = emu.item(machine.devices[':nvram_map'].items['0/00000000-0000ffff'])
	repeat
		send_input(":IN.0", 0x04, 0.25) -- Level
	until nvram:read(0x01) == 0x00
	local n = tonumber(level:sub(1,2)) - (nvram:read(0x03) + 1)
	if (n > 8) then
		n = n - 17
	elseif (n < -8) then
		n = n + 17
	end
	interface.setvalue(n)
	if (level:sub(1,2) == "17") then
		level = level:sub(4)
		local k = 0
		for i=1,2 do
			send_input(":IN.0", 0x01, 0.25) -- Clock
			k = level:find("/")
			if (level ~= "" and k ~= nil) then
				n = tonumber(level:sub(1,k-1)) - nvram:read(i*0x06+3)
				interface.setvalue(n)
				level = level:sub(k+1)
			end
			send_input(":IN.0", 0x01, 0.25) -- Clock
			k = (level .. " "):find(" ")
			if (level ~= "" and k ~= nil) then
				n = tonumber(level:sub(1,k-1)) - (256 * (nvram:read(i*0x06)) + nvram:read(i*0x06+1)) / 60
				interface.setvalue(n)
				level = level:sub(k+1)
			end
		end
	end
	send_input(":IN.0", 0x01, 0.25) -- Clock
end

function interface.setstyle()
	if (interface.cur_style == nil or interface.cur_style == interface.style) then
		return
	end
	interface.cur_style = interface.style
	local style = interface.style
	local ddram = emu.item(machine.devices[':lcd'].items['0/m_ram'])
	local lcd_num = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67 }
	send_input(":IN.0", 0x08, 0.25) -- Function
	local s = ddram:read(0x00) >> 24
	local n = 0
	repeat
		n = n + 1
	until (s ~= lcd_num[n])
	n = style - n
	if (n > 4) then
		n = n - 9
	elseif (n < -4) then
		n = n + 9
	end
	interface.setvalue(n)
	send_input(":IN.0", 0x01, 0.25) -- Clock
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(6)
	send_input(":IN.3", 0x08, 1) -- New Game
	emu.wait(1)

	interface.cur_level = "1"
	interface.setlevel()
	interface.cur_style = 5
	interface.setstyle()
end

function interface.start_play(init)
	send_input(":IN.0", 0x02, 1) -- Move
	emu.wait(1)
end

function interface.is_selected(x, y)
	if (machine:outputs():get_indexed_value(tostring(y - 1) .. ".", 8 - x) ~= 0) then
		for i=1,2 do
			emu.wait(0.3)
			if (machine:outputs():get_indexed_value(tostring(y - 1) .. ".", 8 - x) == 0) then
				return false
			end
		end
		return true
	end
	return false
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "1"}, { "spin", "Style", "5", "1", "9"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		if (level:len() <= 2) then
			local num = tonumber(level)
			if (num ~= nil and num >= 1 and num <= 17) then
				if (num < 10) then
					num = "0" .. num
				end
				interface.level = tostring(num)
				interface.setlevel()
			end
		elseif (level:match("^17%s%d?%d/[01]?%d?%d$") or level:match("^17%s%d?%d/[01]?%d?%d%s%d?%d/[01]?%d?%d$")) then
			interface.level = level
			interface.setlevel()
		end
	elseif (name == "style" and value ~= "") then
		interface.style = tonumber(value)
		interface.setstyle()
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then send_input(":IN.3", 0x10, 1)
	elseif (piece == "r") then send_input(":IN.1", 0x01, 1)
	elseif (piece == "b") then send_input(":IN.1", 0x10, 1)
	elseif (piece == "n") then send_input(":IN.2", 0x01, 1)
	end
end

return interface
