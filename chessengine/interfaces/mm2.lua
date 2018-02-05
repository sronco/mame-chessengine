-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("mm4")

function interface.setup_machine()
	-- setup board pieces
	for y=0,7 do
		local port_tag = ":board:IN." .. tostring(y)
		local port_val = machine:ioport().ports[port_tag]:read()
		for x=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - x)) ~= 0) or (req_pos == false and port_val & (1 << (7 - x)) == 0)) then
				send_input(port_tag, 1 << (7 - x), 0.10)
			end
		end
	end

	emu.wait(1.0)
	send_input(":KEY1_0", 0x80, 1)
end

function interface.get_promotion()
	local d0 = machine:outputs():get_value("digit0") & 0x7f
	local d1 = machine:outputs():get_value("digit1") & 0x7f
	local d3 = machine:outputs():get_value("digit3") & 0x7f

	if (d0 == 0x73 and d1 == 0x50) then	-- display shows 'Pr'
		if     (d3 == 0x5e) then	return "q"
		elseif (d3 == 0x31) then	return "r"
		elseif (d3 == 0x38) then	return "b"
		elseif (d3 == 0x6d) then	return "n"
		end
	end

	return nil
end

function interface.promote(x, y, piece)
	if     (piece == "q" or piece == "Q") then	send_input(":KEY2_0", 0x80, 1)
	elseif (piece == "r" or piece == "R") then	send_input(":KEY2_7", 0x80, 1)
	elseif (piece == "b" or piece == "B") then	send_input(":KEY2_6", 0x80, 1)
	elseif (piece == "n" or piece == "N") then	send_input(":KEY2_5", 0x80, 1)
	end
end

return interface
