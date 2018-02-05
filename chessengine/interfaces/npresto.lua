-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(1)
end

function interface.start_play()
	emu.wait(1)
	send_input(":IN.8", 0x80, 0.6)
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_indexed_value("1.", (x - 1)) ~= 0
	local yval = machine:outputs():get_indexed_value("0.", (y - 1)) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		send_input(":IN." .. tostring(y - 1), 1 << (x - 1), 0.6)
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "8"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		repeat
			send_input(":IN.8", 0x10, 0.5)
			local cur_level = 0
			for y=1,8 do
				if machine:outputs():get_indexed_value("0.", (y - 1)) ~= 0 then
					cur_level = cur_level + 1
				end
			end
		until cur_level == level
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)

end

return interface
