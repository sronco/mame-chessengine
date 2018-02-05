-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("fscc9")
local opt_clear_announcements = false

function interface.is_led_on(tag, idx)
	-- returns false if the LED is off or flashing
	for i=1,4 do
		if (machine:outputs():get_indexed_value(tag, idx) == 0) then
			return false
		end
		emu.wait(0.15)
	end

	return true
end

function interface.clear_announcements()
	local lastval = {}
	for i=1,6 do
		lastval[i] = machine:outputs():get_indexed_value("0.", i)
	end

	emu.wait(0.25)

	for i=1,6 do
		if (machine:outputs():get_indexed_value("0.", i) ~= lastval[i]) then
			-- clear announcements to continue the game
			send_input(":IN.8", 0x40, 1)
		end
	end
end

function interface.is_selected(x, y)
	if (opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_indexed_value("1.", 8 - y) ~= 0 and interface.is_led_on("0.", x - 1)
end

function interface.get_options()
	return { { "check", "Clear announcements", "0"}, }
end

function interface.set_option(name, value)
	if (name == "clear announcements") then
		opt_clear_announcements = tonumber(value) == 1
	end
end

return interface
