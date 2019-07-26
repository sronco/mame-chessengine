-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("polgar")

function interface.setup_machine()
	emu.wait(10)
end

return interface
