-- license:BSD-3-Clause

interface = load_interface("mondial2")

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local tmp = 0
	if (interface.level > 8) then
		tmp = 1
	end
	send_input(":KEY.1", 0x20, 1) -- LEV
	emu.wait(1)
	if (output:get_value("0." .. 2-tmp) == 0) then
		send_input(":KEY.1", 0x20, 1) -- LEV
		emu.wait(0.5)
	end
	send_input(":KEY.0", 0x01 << ((interface.level-1) % 8), 1)
	emu.wait(1)
	send_input(":KEY.1", 0x40, 1) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
	send_input(":KEY.1", 0x80, 1) -- RES
	emu.wait(1.0)

	interface.cur_level = 2
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":KEY.1", 0x01, 1) -- PLAY
end

function interface.promote(x, y, piece)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	sb_promote(":board", x, y, piece)
	if     (piece == "q") then	send_input(":KEY.0", 0x10, 1)
	elseif (piece == "r") then	send_input(":KEY.0", 0x08, 1)
	elseif (piece == "b") then	send_input(":KEY.0", 0x04, 1)
	elseif (piece == "n") then	send_input(":KEY.0", 0x02, 1)
	elseif (piece == "Q" or piece == "R" or piece == "B" or piece == "N") then
		sb_press_square(":board", 1, x, y)
	end
end

return interface
