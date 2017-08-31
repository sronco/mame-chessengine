-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(1.0)
end

function interface.start_play()
	send_input(":KEY", 0x40, 1)
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_indexed_value("led", (x - 1)) ~= 0
	local yval = machine:outputs():get_indexed_value("led", 8 + (y - 1)) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "en_passant") then
		send_input(":board:IN." .. tostring(y - 1), 1 << (x - 1), 1)
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":KEY", 0x10, 1)
	elseif (piece == "r") then	send_input(":KEY", 0x08, 1)
	elseif (piece == "b") then	send_input(":KEY", 0x02, 1)
	elseif (piece == "n") then	send_input(":KEY", 0x04, 1)
	end
end

return interface
