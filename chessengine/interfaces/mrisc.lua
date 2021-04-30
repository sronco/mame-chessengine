-- license:BSD-3-Clause

interface = load_interface("polgar")

function interface.setup_machine()
	emu.wait(10)

	interface.cur_level = ""
	interface.setlevel()
end

return interface
