-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	-- setup board pieces
	for y=0,7 do
		local port_tag = ":IN." .. tostring(y)
		local port_val = machine:ioport().ports[port_tag]:read()
		for x=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - x)) == 0) or (req_pos == false and port_val & (1 << (7 - x)) ~= 0)) then
				send_input(port_tag, 1 << (7 - x), 0.10)
			end
		end
	end
	send_input(":IN.2", 0x100, 1)

	emu.wait(1.0)
end

function interface.start_play()
	send_input(":IN.8", 0x80, 1) -- should be 0x01 according to the layout file, but mirroring the bits (0x80) is needed
end

function interface.is_selected(x, y)
	return machine:outputs():get_value((y - 1) .. "." .. (16 - x)) ~= 0
end

function interface.select_piece(x, y, event)
	send_input(":IN." .. tostring(y - 1), 1 << (8 - x), 1)
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	emu.wait(1.0)     -- bits need to be mirrored here for some reason too
	if     (piece == "q") then	send_input(":IN.8", 0x02, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x04, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x10, 1)
	end
end

return interface

