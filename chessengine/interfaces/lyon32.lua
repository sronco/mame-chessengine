interface = load_interface("alm32")

interface.level = "NORML 01"
interface.cur_level = nil

function interface.stop_play()
	send_input(":KEY1", 0x8000, 0.5)	-- CL
	send_input(":KEY1", 0x8000, 0.5)	-- CL
	send_input(":KEY3", 0x8000, 0.5)	-- ENT
end

function interface.get_options()
	return { { "string", "Level", "NORML 01"}, }
end

return interface
