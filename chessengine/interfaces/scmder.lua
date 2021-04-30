-- license:BSD-3-Clause

interface = load_interface("sdtor")

interface.level = "a3"
interface.cur_level = nil

function interface.setup_machine()
	sb_reset_board(":board")
--	send_input(":IN.1", 0x80, 0.5) -- New Game
	emu.wait(1.0)

	interface.cur_level = "a3"
	interface.setlevel()
end

function interface.get_options()
	return { { "string", "Level", "a3"}, }
end

return interface
