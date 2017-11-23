-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
end

function interface.start_play()
	send_input(":IN.8", 0x02, 1)
end

function interface.is_selected(x, y)
	return (machine:outputs():get_indexed_value("0.", (y - 1)) ~= 0) and (machine:outputs():get_indexed_value("1.", (x - 1)) ~= 0)
end

function interface.select_piece(x, y, event)
	send_input(":IN." .. tostring(8 - y), 1 << (8 - x), 1)
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.8", 0x20, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x8,  1)
	elseif (piece == "n") then	send_input(":IN.8", 0x4,  1)
	end
end

return interface
