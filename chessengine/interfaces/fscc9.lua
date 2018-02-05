-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}
local opt_clear_announcements = false

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":IN.8", 0x40, 1)
end

function interface.start_play()
	send_input(":IN.8", 0x01, 1)
end

function interface.clear_announcements()
	-- machine turns on all LEDs on the first line for mate/draw announcements
	if (machine:outputs():get_value("0.7") ~= 0 and machine:outputs():get_value("1.7") ~= 0 and machine:outputs():get_value("2.7") ~= 0 and machine:outputs():get_value("3.7") ~= 0 and
	    machine:outputs():get_value("4.7") ~= 0 and machine:outputs():get_value("5.7") ~= 0 and machine:outputs():get_value("6.7") ~= 0 and machine:outputs():get_value("7.7") ~= 0) then
		send_input(":IN.8", 0x40, 1)
	end
end

function interface.is_selected(x, y)
	if (opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_indexed_value(tostring(x - 1) .. ".", 8 - y) ~= 0
end

function interface.select_piece(x, y, event)
	if (event ~= "capture") then
		send_input(":IN." .. tostring(x - 1), 1 << (y - 1), 1.5)
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
	if     (piece == "q") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x04, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x02, 1)
	end
end

return interface
