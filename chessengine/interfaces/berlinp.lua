-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.level = "NORML 01"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x08, 0.6)	-- DOWN
	send_input(":KEY", 0x20, 0.6)	-- RIGHT
	send_input(":KEY", 0x20, 0.6)	-- RIGHT
	send_input(":KEY", 0x01, 0.6)	-- ENT
	send_input(":KEY", 0x01, 0.6)	-- ENT
	local ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram']):read_block(0x07, 0x03)
	while (ddram:match(interface.level:sub(1,3)) == nil) do
		send_input(":KEY", 0x08, 0.6)	-- DOWN
		ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram']):read_block(0x07, 0x03)
	end
	ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram']):read_block(0x0c, 0x03)
	while (tonumber(ddram) ~= tonumber(interface.level:sub(6,8))) do
		send_input(":KEY", 0x20, 0.6)	-- RIGHT
		ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram']):read_block(0x0c, 0x03)
	end
	send_input(":KEY", 0x01, 0.6)	-- ENT
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x02, 0.6)	-- CL
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x08, 0.6)	-- DOWN
	send_input(":KEY", 0x20, 0.6)	-- RIGHT
	send_input(":KEY", 0x01, 0.6)	-- ENT

	interface.cur_level = ""
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x20, 0.6)	-- RIGHT
	send_input(":KEY", 0x01, 0.6)	-- ENT
end

function interface.stop_play()
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x02, 0.6)	-- CL
	send_input(":KEY", 0x01, 0.6)	-- ENT
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value("led", (y - 1) * 8 + (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board:board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "NORML 01"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local levstr = value:sub(1,5)
		levstr = levstr:upper()
		levstr = levstr:gsub("\xc4", "A"):gsub("\xe4", "A"):gsub("ä", "A"):gsub("Ä", "A")
		local levnum = tonumber(value:sub(6,8))
		if (levstr == "PROGR" or levstr == "DAUER") then
			levnum=-1
		elseif (levstr == "NORML" or levstr == "TURN " or levstr == "ANFAN" or levstr == "HANDC" or levstr == "BLITZ") then
			if (levnum<0 or levnum>9) then
				return
			end
		elseif (levstr == "MATT ") then
			if (levnum<1 or levnum>16) then
				return
			end
		elseif (levstr == "TIEFE") then
			if (levnum<0 or levnum>30) then
				return
			end
		else
			return
		end
		if (levnum == -1) then
			interface.level = levstr
		else
			interface.level = levstr .. " " .. tostring(levnum)
		end

		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	-- HD44780 Display Data RAM
	local ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram']):read_block(0x00, 0x80)
	local line0 = ddram:sub(0x01,0x10)
	local line1 = ddram:sub(0x41,0x50)

	if     (line1:find('\x01') or line1:find('\x09')) then	return 'q'
	elseif (line1:find('\x02') or line1:find('\x0a')) then	return 'r'
	elseif (line1:find('\x03') or line1:find('\x0b')) then	return 'b'
	elseif (line1:find('\x04') or line1:find('\x0c')) then	return 'n'
	elseif (line0:find('\x01') or line0:find('\x09')) then	return 'q'
	elseif (line0:find('\x02') or line0:find('\x0a')) then	return 'r'
	elseif (line0:find('\x03') or line0:find('\x0b')) then	return 'b'
	elseif (line0:find('\x04') or line0:find('\x0c')) then	return 'n'
	end

	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board:board", x, y, piece)
	local right = -1
	if     (piece == "q") then	right = 0
	elseif (piece == "r") then	right = 1
	elseif (piece == "b") then	right = 2
	elseif (piece == "n") then	right = 3
	end

	if (right ~= -1) then
		for i=1,right do
			send_input(":KEY", 0x20, 1)	-- RIGHT
		end

		send_input(":KEY", 0x01, 1)	-- ENT
	end
end

return interface
