-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	-- setup board pieces
	for x=0,7 do
		local port_tag = ":IN." .. tostring(x)
		local port_val = machine:ioport().ports[port_tag]:read()
		for y=0,7 do
			local req_pos = (y == 0 or y == 1 or y == 6 or y == 7)
			if ((req_pos == true and port_val & (1 << (7 - y)) == 0) or (req_pos == false and port_val & (1 << (7 - y)) ~= 0)) then
				send_input(port_tag, 1 << (7 - y), 0.10)
			end
		end
	end

	send_input(":IN.9", 0x02, 1)
	emu.wait(1.0)
end

function interface.start_play()
	send_input(":IN.9", 0x20, 1)
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value(tostring(x - 1) .. ".", 8 - y) ~= 0
end

function interface.select_piece(x, y, event)
	send_input(":IN." .. tostring(x - 1), 1 << (8 - y), 1)
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":IN.8", 0x04, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x20, 1)
	end
end

return interface
