-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("sfortea")

function interface.setup_machine()
	send_input(":IN.7", 0x01, 1) -- New Game
	emu.wait(5)

	interface.cur_level = ""
	interface.setlevel()
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_value(tostring(8 - x) .. ".8") ~= 0
	local yval = machine:outputs():get_value(tostring(y - 1) .. ".9") ~= 0
	return xval and yval
end

return interface
