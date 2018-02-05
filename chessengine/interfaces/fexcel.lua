-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}
local opt_clear_announcements = false

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":IN.8", 0x80, 1)
end

function interface.start_play()
	send_input(":IN.8", 0x02, 1)
end

function interface.clear_announcements()
	-- clear announcements to continue the game
	local lastval2 = machine:outputs():get_value("1.2")
	local lastval6 = machine:outputs():get_value("1.6")
	emu.wait(0.3)
	if (lastval2 ~= machine:outputs():get_value("1.2") or lastval6 ~= machine:outputs():get_value("1.6")) then
		send_input(":IN.8", 0x01, 1)
		emu.wait(1)
	end
end

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

function interface.is_selected(x, y)
	if (opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_indexed_value("0.", y - 1) ~= 0 and interface.is_led_on("1.", x - 1)
end

function interface.select_piece(x, y, event)
	if (event ~= "capture") then
		send_input(":IN." .. tostring(x - 1), 1 << (y - 1), 1)
	end
end

function interface.get_options()
	return { { "check", "Clear announcements", "0"}, }
end

function interface.set_option(name, value)
	if (name == "clear announcements") then
		opt_clear_announcements = tonumber(value) == 1
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":IN.8", 0x20, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x04, 1)
	end
end

return interface
