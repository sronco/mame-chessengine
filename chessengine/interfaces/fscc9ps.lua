-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("fscc9")

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)
	send_input(":IN.0", 0x40, 0.5) -- CL
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

return interface
