interface = load_interface("stratos")

interface.invert = false
interface.level = "a3"
interface.cur_level = nil

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
	if (machine:system().name == "coronaa") then
		emu.wait(5)
	end
	emu.wait(3)
	send_input(":IN.1", 0x04, 1)	-- New Game
	emu.wait(1)

	interface.cur_level = "a3"
	interface.setlevel()
end

function interface.is_selected(x, y)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	return machine:outputs():get_indexed_value(tostring(2 + x) .. ".", y - 1) ~= 0
end

function interface.get_options()
	return { { "string", "Level", "a3"}, }
end

return interface
