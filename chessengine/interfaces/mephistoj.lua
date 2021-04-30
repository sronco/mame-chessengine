-- license:BSD-3-Clause

interface = load_interface("mephisto")

interface.turn = true
interface.level = "a3"
interface.cur_level = nil

function interface.setup_machine()
	interface.turn = true
--	send_input(":RESET", 0x01, 0.5)  -- RES
	emu.wait(1.0)
	send_input(":IN.0", 0x01, 0.5) -- CL

	interface.cur_level = "a3"
	interface.setlevel()
end

function interface.get_options()
	return { { "string", "Level", "a3"}, }
end

return interface
