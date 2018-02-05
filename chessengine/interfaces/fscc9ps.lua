-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("fscc9")

function interface.setup_machine()
	-- setup board pieces
	for x=0,7 do
		local port_tag = ":IN." .. tostring(x)
		local port_val = machine:ioport().ports[port_tag]:read()
		for y=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - y)) == 0) or (req_pos == false and port_val & (1 << (7 - y)) ~= 0)) then
				send_input(port_tag, 1 << (7 - y), 0.10)
			end
		end
	end

	emu.wait(1.0)
	send_input(":IN.8", 0x40, 0.5)
end

function interface.select_piece(x, y, event)
	send_input(":IN." .. tostring(x - 1), 1 << (y - 1), 1)
end

return interface
