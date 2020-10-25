interface = load_interface("sexpertb")

interface.sel = 5
interface.cur_sel = 5

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(5)
	send_input(":IN.7", 0x01, 0.6) -- New Game
	emu.wait(1)

	interface.cur_level = "a1"
	interface.cur_sel = 5
	interface.setlevel()
end

return interface
