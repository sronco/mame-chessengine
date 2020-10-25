interface = load_interface("alm16")

function interface.stop_play()
	send_input(":KEY3", 0x0200, 0.5)	-- CL
	send_input(":KEY3", 0x0200, 0.5)	-- CL
	send_input(":KEY1", 0x0200, 0.5)	-- ENT
end

return interface
