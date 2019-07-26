-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("alm32")

interface.level = "NORML 01"
interface.cur_level = nil

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)
	send_input(":KEY1", 0x8000, 0.6)	-- CL
	send_input(":KEY1", 0x8000, 0.6)	-- CL
	send_input(":KEY2", 0x4000, 0.6)	-- DOWN
	send_input(":KEY1", 0x4000, 0.6)	-- RIGHT
	send_input(":KEY3", 0x8000, 0.6)	-- ENT

	interface.cur_level = ""
	interface.setlevel()
end

function interface.stop_play()
	send_input(":KEY1", 0x8000, 0.6)	-- CL
	send_input(":KEY1", 0x8000, 0.6)	-- CL
	send_input(":KEY3", 0x8000, 0.6)	-- ENT
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value("led", (y - 1) * 8 + (x - 1)) ~= 0
end

function interface.get_options()
	return { { "string", "Level", "NORML 01"}, }
end

return interface
