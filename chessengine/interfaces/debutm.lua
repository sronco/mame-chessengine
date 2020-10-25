interface = {}

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local lcd_num = { 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f }
	repeat
		send_input(":IN.0", 0x40, 0.5) -- Level
	until machine:outputs():get_value("digit3") == lcd_num[interface.level + 1]
	send_input(":IN.0", 0x01, 1) -- Analysis
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":RESET", 0x01, 1) -- Reset
	emu.wait(1.0)

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x02, 1) -- Force Move
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_indexed_value("1.", x) ~= 0
	local yval = machine:outputs():get_indexed_value("0.", y) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "1", "0", "9"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 9) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	-- TODO
end

return interface
