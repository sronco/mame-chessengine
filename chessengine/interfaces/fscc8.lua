-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":IN.8", 0x40, 1)
end

function interface.start_play()
	send_input(":IN.4", 0x80, 1)
end

function interface.is_selected(x, y)
	if (machine:outputs():get_value("0.0") ~= 0 and machine:outputs():get_value("1.0") ~= 0 and machine:outputs():get_value("2.0") ~= 0 and machine:outputs():get_value("3.0") ~= 0 or
	    machine:outputs():get_value("4.0") ~= 0 and machine:outputs():get_value("5.0") ~= 0 and machine:outputs():get_value("6.0") ~= 0 and machine:outputs():get_value("7.0") ~= 0) then
		-- TODO: machine turns on all LEDs for mate announcement
		return false
	end

	return machine:outputs():get_value(tostring(x - 1) .. "." .. tostring(y - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling") then
		send_input(":IN." .. tostring(x - 1), 1 << (y - 1), 1.5)
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x02, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x04, 1)
	end
end

return interface
