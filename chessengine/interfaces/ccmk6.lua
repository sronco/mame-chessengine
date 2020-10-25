interface = load_interface("ccmk5")

function interface.setup_machine()
	-- Disable the Sensory Board config
	if ((machine:ioport().ports[":IN.6"]:read() & 0x20) ~= 0) then
		machine:ioport().ports[":IN.6"]:field(0x20):set_value(1)
		machine:soft_reset()
	end
	interface.turn = true
	interface.color = "B"
	emu.wait(2.0)
	send_input(":IN.0", 0x02, 0.5) -- New Game
	emu.wait(0.5)
	send_input(":IN.3", 0x08, 0.5) -- Yes
	emu.wait(0.5)

	interface.cur_level = ""
	interface.setlevel()
end

return interface
