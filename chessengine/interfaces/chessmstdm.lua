-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("chessmst")

interface.level = 0
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local lcd_num = { 0x00ff, 0x400c, 0x377, 0x023f, 0x38c, 0x03bb, 0x03fb, 0x020f, 0x3ff, 0x03bf }
	send_input(":BUTTONS", 0x10, 0.5) -- Parameter / Information
	send_input(":BUTTONS", 0x80, 0.5) -- Enter
	while machine:outputs():get_value("digit0") ~= lcd_num[interface.level+1] do
		send_input(":BUTTONS", 0x01, 0.5) -- Move Fore
	end
	send_input(":EXTRA", 0x01, 0.5) -- Monitor
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)

	interface.cur_level = 0
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":BUTTONS", 0x80, 1) -- Enter
end

function interface.get_options()
	return { { "spin", "Level", "0", "0", "9"}, }
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
	local d0 = machine:outputs():get_value("digit0") & 0xffff
	if     (d0 == 0xf730) then	return "q"
	elseif (d0 == 0x93b4) then	return "r"
	elseif (d0 == 0xd432) then	return "b"
	elseif (d0 == 0x91bf) then	return "n"
	end

	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	local right = -1
	if     (piece == "q") then	right = 0
	elseif (piece == "r") then	right = 1
	elseif (piece == "b") then	right = 2
	elseif (piece == "n") then	right = 3
	elseif (piece == "Q" or piece == "R" or piece == "B" or piece == "N") then
		interface.select_piece(x, y, "")
		send_input(":BUTTONS", 0x80, 1)
		interface.select_piece(x, y, "")
	end

	if (right ~= -1) then
		for i=1,right do
			send_input(":BUTTONS", 0x01, 1)
		end

		send_input(":BUTTONS", 0x80, 1)
	end
end

return interface
