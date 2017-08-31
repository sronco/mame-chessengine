-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("mm4")

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
	send_input(":KEY1_0", 0x80, 1)
end

function interface.promote(x, y, piece)
	-- TODO: this doesn't work
	if     (piece == "q") then	send_input(":KEY2_0", 0x80, 1)
	elseif (piece == "r") then	send_input(":KEY2_7", 0x80, 1)
	elseif (piece == "b") then	send_input(":KEY2_6", 0x80, 1)
	elseif (piece == "n") then	send_input(":KEY2_5", 0x80, 1)
	end
	send_input(":KEY1_5", 0x80, 1)
end

return interface
