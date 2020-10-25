interface = {}

interface.level = "1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local lcd_lev = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x79, 0x71, 0x3d, 0x76 }
	local lcd_num = { 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67 }
	local level = interface.level
	local lev = "12345678EFGH"
	lev = lev:find(level:sub(1,1))
	if (lev < 9 or lev > 10) then
		repeat
			send_input(":IN.3", 0x100, 0.6) -- LV
		until machine:outputs():get_value("digit0") == lcd_lev[lev]
	else
		repeat
			send_input(":IN.3", 0x100, 0.6) -- LV
		until machine:outputs():get_value("digit0") == lcd_lev[lev-1]
		send_input(":IN.3", 0x100, 0.6) -- LV
		level = level:sub(3)
		local d1,d2,d3
		for i=1,2 do
			if (lev == 9) then
				send_input(":IN.4", 0x100, 0.6) -- DM
				if (level:sub(1,2) ~= "00") then
					d1=lcd_num[tonumber(level:sub(1,1))+1]
					d2=lcd_num[tonumber(level:sub(2,2))+1]
					machine:ioport().ports[":IN.5"]:field(0x100):set_value(1) -- ST
					repeat
						emu.wait(0.05)
					until (machine:outputs():get_value("digit1") == d1 and machine:outputs():get_value("digit0") == d2)
				end
				machine:ioport().ports[":IN.5"]:field(0x100):set_value(0) -- ST
				emu.wait(0.5)
				level = level:sub(4)
			end
			send_input(":IN.2", 0x100, 0.6) -- TM
			if (level:sub(1,4) ~= "0:00") then
				d1=lcd_num[tonumber(level:sub(1,1))+1]
				d2=lcd_num[tonumber(level:sub(3,3))+1]
				d3=lcd_num[tonumber(level:sub(4,4))+1]
				machine:ioport().ports[":IN.5"]:field(0x100):set_value(1) -- ST
				repeat
					emu.wait(0.05)
				until (machine:outputs():get_value("digit2") == d1 and machine:outputs():get_value("digit1") == d2 and machine:outputs():get_value("digit0") == d3)
			end
			machine:ioport().ports[":IN.5"]:field(0x100):set_value(0) -- ST
			emu.wait(0.5)
			level = level:sub(6)
		end
		send_input(":IN.2", 0x100, 0.6) -- TM
	end
	send_input(":IN.2", 0x100, 0.6) -- TM
end

function interface.setup_machine()
	sb_reset_board(":board")
--	send_input(":IN.8", 0x80, 1) -- RE
	emu.wait(1.0)
	send_input(":IN.8", 0x40, 1) -- CL
	emu.wait(1.0)

	interface.cur_level = "1"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.4", 0x100, 1) -- DM
	send_input(":IN.1", 0x100, 1) -- RV
end

function interface.stop_play()
	send_input(":IN.5", 0x100, 1) -- ST
end

function interface.is_selected(x, y)
	return machine:outputs():get_value(tostring(x - 1) .. "." .. tostring(y - 1 + 8)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:upper():match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		if (level:match("^[1-8GH]$")
		or  level:match("^E%s%d%d/%d:[0-5]%d%s%d%d/%d:[0-5]%d$")
		or  level:match("^F%s%d:[0-5]%d%s%d:[0-5]%d$")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x02, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x04, 1)
	end
end

return interface
