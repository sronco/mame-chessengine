-- license:BSD-3-Clause

interface = load_interface("cc10")

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local lcd_num = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67, 0x76 }
	repeat
		send_input(":IN.0", 0x02, 0.5) -- LV
	until output:get_value("digit3") == lcd_num[interface.level]
	send_input(":IN.2", 0x01, 0.5) -- CL
end

function interface.start_play(init)
	interface.turn = false
	send_input(":IN.2", 0x01, 0.5) -- CL
	send_input(":IN.1", 0x02, 0.5) -- DM
	send_input(":IN.2", 0x02, 0.5) -- PB
end

return interface
