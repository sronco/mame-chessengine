-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("fexcel")

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":IN.0", 0x80, 1) -- NEW GAME
	emu.wait(1.0)

	interface.cur_level = 6
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x02, 1) -- MOVE
	emu.wait(1.0)
end

return interface
