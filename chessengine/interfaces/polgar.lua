-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	-- setup board pieces
	for y=0,7 do
		local port_tag = ":board:IN." .. tostring(y)
		local port_val = machine:ioport().ports[port_tag]:read()
		for x=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - x)) ~= 0) or (req_pos == false and port_val & (1 << (7 - x)) == 0)) then
				send_input(port_tag, 1 << (7 - x), 0.10)
			end
		end
	end

	emu.wait(1.0)
end

function interface.start_play()
	send_input(":KEY", 0x40, 1)
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value("led", (y - 1) * 8 + (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	send_input(":board:IN." .. tostring(y - 1), 1 << (x - 1), 1)
end

function interface.get_promotion()
	-- HD44780 Display Data RAM
	local ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram']):read_block(0x00, 0x80)

	if     (ddram:sub(65,81):find('\x04') or ddram:sub(65,81):find('\x0c')) then	return 'q'
	elseif (ddram:sub(65,81):find('\x03') or ddram:sub(65,81):find('\x0b')) then	return 'r'
	elseif (ddram:sub(65,81):find('\x02') or ddram:sub(65,81):find('\x0a')) then	return 'b'
	elseif (ddram:sub(65,81):find('\x01') or ddram:sub(65,81):find('\x09')) then	return 'n'
	end

	return nil
end

function interface.promote(x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":KEY", 0x10, 1)
	elseif (piece == "r") then	send_input(":KEY", 0x08, 1)
	elseif (piece == "b") then	send_input(":KEY", 0x02, 1)
	elseif (piece == "n") then	send_input(":KEY", 0x04, 1)
	end
end

return interface
