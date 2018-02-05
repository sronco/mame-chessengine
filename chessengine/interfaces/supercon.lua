-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	send_input(":IN.0", 0x100, 1)
	emu.wait(1.0)
end

function interface.start_play()
	send_input(":IN.7", 0x100, 1)
end

function interface.is_selected(x, y)
	return (machine:outputs():get_indexed_value("1.", (8 - y)) ~= 0) and (machine:outputs():get_indexed_value("2.", (x - 1)) ~= 0)
end

function interface.select_piece(x, y, event)
	if (event ~= "capture") then
		send_input(":IN." .. tostring(8 - y), 1 << (8 - x), 1)
	end
end

function interface.get_promotion_led()
	if     (machine:outputs():get_value("0.1") ~= 0) then	return 'q'
	elseif (machine:outputs():get_value("0.4") ~= 0) then	return 'r'
	elseif (machine:outputs():get_value("0.2") ~= 0) then	return 'b'
	elseif (machine:outputs():get_value("0.3") ~= 0) then	return 'n'
	end
	return nil
end

function interface.get_promotion()
	-- try a couple of times because the LEDs flashes
	for i=1,5 do
		local p = interface.get_promotion_led()
		if (p ~= nil) then
			return p
		end
		emu.wait(0.25)
	end

	return nil
end

function interface.promote(x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.1", 0x200, 1)
	elseif (piece == "r") then	send_input(":IN.4", 0x200, 1)
	elseif (piece == "b") then	send_input(":IN.2", 0x200, 1)
	elseif (piece == "n") then	send_input(":IN.3", 0x200, 1)
	end
end

return interface
