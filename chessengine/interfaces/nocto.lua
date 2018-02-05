-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("npresto")

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		send_input(":IN." .. tostring(y - 1), 1 << (x - 1), 0.3)
	end
end

return interface
