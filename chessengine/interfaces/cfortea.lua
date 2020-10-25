interface = load_interface("supercon")

interface.level = "a1"
interface.cur_level = nil

function interface.getdigit(n)
	local ddram = emu.item(machine.devices[':maincpu'].items['0/00000000-0000ffff'])
	local d = ddram:read(0xc20 + n) & 0x7f
	while (d == 0x20) do
		emu.wait(0.5)
		d = ddram:read(0xc20 + n) & 0x7f
	end
	return d
end

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[level:sub(1, 1)]
	local y = level:sub(2, 2)
	send_input(":IN.2", 0x02, 0.5) -- Sound (off)
	send_input(":IN.6", 0x02, 0.5) -- Set Level
	sb_press_square(":board", 0.5, x, y)
	level = level:sub(4)
	for i=1,level:len() do
		if (i == 1) then
			send_input(":IN.2", 0x01, 0.5) -- Time Control
		end
		local j = i % 9
		if (j == 0) then
			send_input(":IN.3", 0x01, 0.5) -- Flip Display
			send_input(":IN.2", 0x01, 0.5) -- Time Control
		elseif (j ~= 3 and j ~= 6) then
			local k = 0
			if     (j == 1 or j == 4) then k = 0x04
			elseif (j == 2 or j == 5) then k = 0x05
			elseif (j == 7) then k = 0x06
			elseif (j == 8) then k = 0x07
			end
			local d = tonumber(level:sub(i,i)) - interface.getdigit(k)
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
					send_input(":IN.7", 0x01, 0.25) -- ->
				else
					send_input(":IN.7", 0x02, 0.25) -- <-
				end
			end
			send_input(":IN.6", 0x01, 0.5) -- Yes
		end
	end
	send_input(":IN.7", 0x01, 0.5) -- Go
	send_input(":IN.2", 0x02, 0.5) -- Sound (on)
	send_input(":IN.6", 0x02, 0.5) -- Set Level
	send_input(":IN.7", 0x01, 0.5) -- Go
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(2)
	send_input(":IN.0", 0x01, 1) -- New Game
	emu.wait(1)

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.get_options()
	return { { "string", "Level", "a1"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = value:lower():match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		local num = tonumber(level:sub(1,2))
		if (num ~= nil and num >= 1 and num <= 16) then
			local mod = (num - 1) % 8 + 1
			local div = (num - mod) / 8 + 1
			level = string.char(div + 96) .. tostring(mod) .. level:sub(3)
		end
		if (level:match("^[ab][1-8]$")
		or level:match("^b8%s%d%d/%d%d:[0-5]%d$") or level:match("^b8%s%d%d/%d%d:[0-5]%d%s%d%d/%d%d:[0-5]%d$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	local d8 = machine:outputs():get_value("digit8")

	if     (d8 == 0x67) then	return "q"
	elseif (d8 == 0x50) then	return "r"
	elseif (d8 == 0x7c) then	return "b"
	elseif (d8 == 0x54) then	return "n"
	end

	return nil
end

return interface
