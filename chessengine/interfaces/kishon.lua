-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("chesster")

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)
	send_input(":IN.0", 0x20, 1) -- OPTION
	emu.wait(1.0)
	sb_press_square(":board", 1, 8, 1) -- h1
	emu.wait(1.0)
	sb_press_square(":board", 1, 2, 1) -- b1
	emu.wait(1.0)
	send_input(":IN.0", 0x01, 0.5) -- CLEAR
	emu.wait(1.0)

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.select_piece(x, y, event)
	if (event == "get_castling") then
		emu.wait(1)
	end
	sb_select_piece(":board", 1, x, y, event)
	emu.wait(0.5)
end

return interface
