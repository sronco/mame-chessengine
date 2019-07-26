-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("fexcel")

interface.level = 2
interface.cur_level = nil

function interface.setup_machine()
	sb_reset_board(":board")
--	send_input(":IN.0", 0x80, 0.5) -- NEW GAME
--	emu.wait(1.0)
--	send_input(":IN.0", 0x01, 0.5) -- CLEAR
	emu.wait(1.0)

	interface.cur_level = 2
	interface.setlevel()
end

function interface.get_options()
	return { { "spin", "Level", "2", "1", "12"}, { "check", "Clear announcements", "1"}, }
end

return interface
