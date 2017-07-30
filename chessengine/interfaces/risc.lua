-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(5) -- boot time
end

function interface.start_play()
	send_input(":P5", 0x80000000, 1)
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_indexed_value("led", 8 + (x - 1)) == 0
	local yval = machine:outputs():get_indexed_value("led", (y - 1)) == 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if (event ~= "capture") then
		send_input(":P" .. tostring(y - 1), 0x80 >> (x - 1), 1)
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":P4", 0x40000000, 1)
	elseif (piece == "r") then	send_input(":P3", 0x40000000, 1)
	elseif (piece == "b") then	send_input(":P2", 0x40000000, 1)
	elseif (piece == "n") then	send_input(":P1", 0x40000000, 1)
	end
end

return interface
