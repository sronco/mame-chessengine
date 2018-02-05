-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("csc")

function interface.start_play()
	send_input(":IN.4", 0x80, 1)
end

function interface.select_piece(x, y, event)
	if (event ~= "en_passant" and event ~= "capture" and event ~= "get_castling" and event ~= "put_castling") then
		send_input(":IN." .. tostring(x - 1), 1 << (y - 1), 1)
	end
end

function interface.get_promotion()
	emu.wait(1)
	return 'q'	-- TODO
end

return interface
