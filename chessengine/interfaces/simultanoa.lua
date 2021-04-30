-- license:BSD-3-Clause

interface = load_interface("stratos")

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
	emu.wait(1)
	send_input(":IN.1", 0x04, 1)	-- New Game
	emu.wait(1)

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.is_selected(x, y)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	local xval = output:get_indexed_value("1.", x - 1) ~= 0
	local yval = output:get_indexed_value("0.", y - 1) ~= 0
	return xval and yval
end

local function getpiece()
	local piece = 0x00
	for i=1,7 do
		if (output:get_value("s" .. (i+8) .. ".12") ~= 0) then
			piece = piece | (1 << (i-1))
		end
	end
	return piece
end

function interface.get_promotion(x, y)
	local piece = getpiece()
	if     (piece == 0x3e) then return 'q'
	elseif (piece == 0x3f) then return 'r'
	elseif (piece == 0x36) then return 'b'
	elseif (piece == 0x7c) then return 'n'
	end
	return nil
end

return interface
