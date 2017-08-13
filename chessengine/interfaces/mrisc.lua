-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("polgar")

function interface.setup_machine()
	local boot_time = 10.0
	-- setup board pieces
	for y=0,7 do
		local port_tag = ":board:IN." .. tostring(y)
		local port_val = machine:ioport().ports[port_tag]:read()
		for x=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - x)) ~= 0) or (req_pos == false and port_val & (1 << (7 - x)) == 0)) then
				send_input(port_tag, 1 << (7 - x), 0.10)
				boot_time = boot_time - 0.10
			end
		end
	end

	emu.wait(boot_time)
end

return interface
