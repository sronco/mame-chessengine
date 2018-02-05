-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}
local invert = false

function interface.setup_machine()
	invert = false
	emu.wait(1.0)
end

function interface.start_play()
	invert = true
	send_input(":KEY.0", 0x01, 1)
end

function interface.is_selected(x, y)
	if invert then
		x = 9 - x
		y = 9 - y
	end
	local xval = machine:outputs():get_indexed_value("led", 8 + (x - 1)) ~= 0
	local yval = machine:outputs():get_indexed_value("led", (y - 1)) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if invert then
		x = 9 - x
		y = 9 - y
	end
	if (event ~= "capture") then
		send_input(":board:IN." .. tostring(y - 1), 1 << (x - 1), 1)
	end
end

function interface.get_promotion_led()
	if     (machine:outputs():get_value("led104") ~= 0) then 	return 'q'
	elseif (machine:outputs():get_value("led103") ~= 0) then 	return 'r'
	elseif (machine:outputs():get_value("led102") ~= 0) then 	return 'b'
	elseif (machine:outputs():get_value("led101") ~= 0) then 	return 'n'
	end
	return nil
end

function interface.get_promotion()
	-- try a couple of times because the LEDs flashes
	for i=1,5 do
		local p = interface.get_promotion_led()
		if (p ~= nil) then
			return p
		end
		emu.wait(0.25)
	end

	return nil
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":KEY.1", 0x10, 1)
	elseif (piece == "r") then	send_input(":KEY.1", 0x08, 1)
	elseif (piece == "b") then	send_input(":KEY.1", 0x04, 1)
	elseif (piece == "n") then	send_input(":KEY.1", 0x02, 1)
	elseif (piece == "Q" or piece == "R" or piece == "B" or piece == "N") then
		interface.select_piece(x, y, nil)
	end
end

return interface
