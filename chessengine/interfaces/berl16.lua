-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("berlinp")

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x01, 0.5)	-- ENT

	interface.cur_level = ""
	interface.setlevel()
end

return interface
