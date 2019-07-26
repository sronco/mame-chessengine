-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("supercon")

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local x = 1
	local y = interface.level
	if (interface.level > 8) then
		x = 2
		y = y - 8
	end
	send_input(":IN.6", 0x02, 1) -- Set Level
	sb_press_square(":board", 1, x, y)
	send_input(":IN.7", 0x01, 1) -- Go
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(2.0)
	send_input(":IN.0", 0x01, 1) -- New Game
	send_input(":IN.6", 0x02, 1) -- Set Level
	send_input(":IN.7", 0x01, 1) -- Go
	emu.wait(1.0)

	interface.cur_level = ""
	interface.setlevel()
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "16"}, }
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

function interface.get_promotion(x, y)
	local d8 = machine:outputs():get_value("digit8")

	if     (d8 == 0x67) then	return "q"
	elseif (d8 == 0x50) then	return "r"
	elseif (d8 == 0x7c) then	return "b"
	elseif (d8 == 0x54) then	return "n"
	end

	return nil
end

return interface
