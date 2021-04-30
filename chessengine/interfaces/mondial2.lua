-- license:BSD-3-Clause

interface = {}

interface.invert = false
interface.level = 2
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local tmp = 0
	if (interface.level > 8) then
		tmp = 1
	end
	send_input(":KEY.3", 0x02, 1) -- LEV
	emu.wait(1)
	if (output:get_value("0." .. 2-tmp) == 0) then
		send_input(":KEY.3", 0x02, 1) -- LEV
		emu.wait(0.5)
	end
	send_input(":KEY." .. (((interface.level-1) >> 2) & 1), 0x01 << ((interface.level-1) % 4), 1)
	emu.wait(1)
	send_input(":KEY.3", 0x04, 1) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
	send_input(":KEY.3", 0x08, 1) -- RES
	emu.wait(1.0)

	interface.cur_level = 2
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		sb_rotate_board(":board")
		interface.invert = true
	end
	send_input(":KEY.2", 0x01, 1) -- PLAY
end

function interface.is_selected(x, y)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	local xval = output:get_value((x - 1) .. ".1") ~= 0
	local yval = output:get_value((y - 1) .. ".2") ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "2", "1", "16"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 16) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion_led()
	if     (output:get_value("4.0") ~= 0) then	return 'q'
	elseif (output:get_value("3.0") ~= 0) then	return 'r'
	elseif (output:get_value("2.0") ~= 0) then	return 'b'
	elseif (output:get_value("1.0") ~= 0) then	return 'n'
	end
	return nil
end

function interface.get_promotion(x, y)
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
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	sb_promote(":board", x, y, piece)
	if     (piece == "q") then	send_input(":KEY.1", 0x01, 1)
	elseif (piece == "r") then	send_input(":KEY.0", 0x08, 1)
	elseif (piece == "b") then	send_input(":KEY.0", 0x04, 1)
	elseif (piece == "n") then	send_input(":KEY.0", 0x02, 1)
	elseif (piece == "Q" or piece == "R" or piece == "B" or piece == "N") then
		sb_press_square(":board", 1, x, y)
	end
end

return interface
