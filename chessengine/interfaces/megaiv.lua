-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(1.0)
end

function interface.start_play()
	send_input(":KEY.0", 0x08, 1)
end

function interface.is_selected(x, y)
	if (machine:outputs():get_value("digit1") & 0x80 ~= 0 and machine:outputs():get_value("digit5") & 0x80 ~= 0) then
		return false
	end
	local xval = machine:outputs():get_indexed_value("led", 8 + (x - 1)) ~= 0
	local yval = machine:outputs():get_indexed_value("led", (y - 1)) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "en_passant") then
		send_input(":board:IN." .. tostring(y - 1), 1 << (x - 1), 1)
	end
end

function interface.get_promotion()
	local d0 = machine:outputs():get_value("digit0") & 0x7f
	local d1 = machine:outputs():get_value("digit1") & 0x7f
	local d4 = machine:outputs():get_value("digit4") & 0x7f
	local d5 = machine:outputs():get_value("digit5") & 0x7f
	local d3 = nil

	if (d0 == 0x73 and d1 == 0x33) then	-- upper display shows 'Pr'
		d3 = machine:outputs():get_value("digit3") & 0x7f
	end
	if (d4 == 0x73 and d5 == 0x33) then	-- lower display shows 'Pr'
		d3 = machine:outputs():get_value("digit7") & 0x7f
	end

	if     (d3 == 0x5e) then	return "q"
	elseif (d3 == 0x31) then	return "r"
	elseif (d3 == 0x38) then	return "b"
	elseif (d3 == 0x6d) then	return "n"
	end

	return nil
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":KEY.1", 0x02, 1)
	elseif (piece == "r") then	send_input(":KEY.0", 0x10, 1)
	elseif (piece == "b") then	send_input(":KEY.0", 0x01, 1)
	elseif (piece == "n") then	send_input(":KEY.1", 0x10, 1)
	end
end

return interface
