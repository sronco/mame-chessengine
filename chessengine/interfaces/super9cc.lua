-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("csc")
local opt_clear_announcements = false

function interface.clear_announcements()
	-- machine turns on all LEDs on the first line for mate/draw announcements
	if (machine:outputs():get_value("0.8") ~= 0 and machine:outputs():get_value("1.8") ~= 0 and machine:outputs():get_value("2.8") ~= 0 and machine:outputs():get_value("3.8") ~= 0 and
	    machine:outputs():get_value("4.8") ~= 0 and machine:outputs():get_value("5.8") ~= 0 and machine:outputs():get_value("6.8") ~= 0 and machine:outputs():get_value("7.8") ~= 0) then
		send_input(":IN.8", 0x40, 1)
	end
end

function interface.is_selected(x, y)
	if (opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_value(tostring(x - 1) .. "." .. tostring(y - 1 + 8)) ~= 0
end


function interface.get_options()
	return { { "check", "Clear announcements", "0"}, }
end

function interface.set_option(name, value)
	if (name == "clear announcements") then
		opt_clear_announcements = tonumber(value) == 1
	end
end

function interface.promote(x, y, piece)
	emu.wait(1)
	if     (piece == "q") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x04, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x02, 1)
	end
end

return interface
