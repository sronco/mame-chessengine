interface = load_interface("fex68k")

interface.level = "a1"
interface.cur_level = nil

function interface.setup_machine()
	sb_reset_board(":board")
--	send_input(":IN.0", 0x80, 0.5) -- NEW GAME
	emu.wait(0.5)
	send_input(":IN.0", 0x01, 2.0) -- CLEAR
	emu.wait(0.5)

	interface.cur_level = "a1"
	interface.setlevel()
end

return interface
