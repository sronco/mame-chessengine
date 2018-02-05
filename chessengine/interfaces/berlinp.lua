-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x01, 0.5)	-- ENT
end

function interface.start_play()
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x01, 0.5)	-- ENT
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value("led", (y - 1) * 8 + (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	if (event ~= "capture") then
		send_input(":board:IN." .. tostring(y - 1), 1 << (x - 1), 1)
	end
end

function interface.get_promotion()
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
