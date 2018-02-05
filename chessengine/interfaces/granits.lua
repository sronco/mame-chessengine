-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("fexcel")

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":IN.8", 0x80, 1)
	emu.wait(1.0)
end

function interface.start_play()
	send_input(":IN.8", 0x02, 1)
	emu.wait(1.0)
end

function interface.select_piece(x, y, event)
	if (event ~= "capture") then
		send_input(":IN." .. tostring(x - 1), 1 << (y - 1), 0.15)
	end
end

return interface
