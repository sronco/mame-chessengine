-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(3)
	send_input(":IN.7", 0x100, 1)
end

function interface.start_play()
	emu.wait(2)
	send_input(":IN.0", 0x100, 1)
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_value(tostring(8 - x) .. ".0") ~= 0
	local yval = machine:outputs():get_value(tostring(y - 1) .. ".1") ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if (event ~= "capture") then
		send_input(":IN." .. tostring(y - 1), 1 << (8 - x), 1)
	end
end

function interface.get_promotion()
	-- HD44780 Display Data RAM
	local ddram = emu.item(machine.devices[':hd44780'].items['0/m_ddram']):read_block(0x00, 0x80)
	local ch9 = ddram:sub(0x42,0x42)

	if     (ch9 == '\x02' or ch9 == '\x0a') then	return 'q'
	elseif (ch9 == '\x03' or ch9 == '\x0b') then	return 'r'
	elseif (ch9 == '\x04' or ch9 == '\x0c') then	return 'b'
	elseif (ch9 == '\x05' or ch9 == '\x0d') then	return 'n'
	end
	return nil
end

function interface.promote(x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.6", 0x200, 1)
	elseif (piece == "r") then	send_input(":IN.3", 0x200, 1)
	elseif (piece == "b") then	send_input(":IN.5", 0x200, 1)
	elseif (piece == "n") then	send_input(":IN.4", 0x200, 1)
	end
end

return interface
