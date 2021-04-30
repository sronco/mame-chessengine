-- license:BSD-3-Clause

interface = load_interface("sexperta")

interface.sel = 3
interface.cur_sel = 3

function interface.setsel()
	if (interface.cur_sel == interface.sel) then
		return
	end
	interface.cur_sel = interface.sel
	local ddram = emu.item(machine.devices[':hd44780'].items['0/m_ddram'])
	if (interface.level:sub(1,2) == "b8") then
		sb_press_square(":board", 0.6, 2, 7)
	end
	while (ddram:read(0x47) - 0x30 ~= interface.sel) do
		send_input(":IN.0", 0x04, 0.3) -- ->
	end
end

function interface.setlevel()
	if (interface.cur_level == nil or (interface.cur_level == interface.level and interface.cur_sel == interface.sel)) then
		return
	end
	local level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[level:sub(1, 1)]
	local y = level:sub(2, 2)
	send_input(":IN.5", 0x02, 0.6) -- Sound (off)
	send_input(":IN.1", 0x01, 0.6) -- Set Level
	if (level:sub(1,2) ~= "b8") then
		sb_press_square(":board", 0.6, x, y)
		interface.setsel()
	else
		interface.setsel()
		sb_press_square(":board", 0.6, x, y)
	end
	if (interface.cur_level ~= interface.level) then
		interface.cur_level = interface.level
		level = level:sub(4)
		for i=1,level:len() do
			if (i == 1) then
				send_input(":IN.1", 0x04, 0.6) -- <-
			end
			local j = i % 9
			if (j == 0) then
				send_input(":IN.5", 0x01, 0.6) -- Change Color
				send_input(":IN.1", 0x04, 0.6) -- <-
			elseif (j ~= 3 and j ~= 6) then
				local k = 0
				if     (j == 1 or j == 4) then k = 0x05
				elseif (j == 2 or j == 5) then k = 0x06
				elseif (j == 7) then k = 0x40
				elseif (j == 8) then k = 0x41
				end
				local d = tonumber(level:sub(i,i)) - tonumber(interface.getdigit(k))
				if (j == 7) then
					if (d > 3) then
						d = d - 6
					elseif (d < -3) then
						d = d + 6
					end
				else
					if (d > 5) then
						d = d - 10
					elseif (d < -5) then
						d = d + 10
					end
				end
				for n=1,math.abs(d) do
					if (d > 0) then
						send_input(":IN.0", 0x04, 0.3) -- ->
					else
						send_input(":IN.1", 0x04, 0.3) -- <-
					end
				end
				send_input(":IN.2", 0x04, 0.6) -- Yes
			end
		end
	end
	send_input(":IN.0", 0x01, 0.6) -- Go
	send_input(":IN.5", 0x02, 0.6) -- Sound (on)
	send_input(":IN.1", 0x01, 0.6) -- Set Level
	send_input(":IN.0", 0x01, 0.6) -- Go
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(5)
	send_input(":IN.7", 0x01, 0.6) -- New Game
	emu.wait(1)

	interface.cur_level = "a1"
	interface.cur_sel = 3
	interface.setlevel()
end

function interface.get_options()
	return { { "string", "Level", "a1"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = value:lower():match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		local num = tonumber(level:sub(1,2))
		if (num ~= nil and num >= 1 and num <= 64) then
			local mod = (num - 1) % 8 + 1
			local div = (num - mod) / 8 + 1
			level = string.char(div + 96) .. tostring(mod) .. level:sub(3)
		end
		local n = level:find("%ss[0-7]")
		if (n ~= nil) then
			interface.sel = tonumber(level:sub(n+2))
			level = level:sub(1,n-1)
		end
		if (level:match("^[a-h][1-8]$")
		or  level:match("^b8%s%d%d/%d%d:[0-5]%d$") or level:match("^b8%s%d%d/%d%d:[0-5]%d%s%d%d/%d%d:[0-5]%d$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

return interface
