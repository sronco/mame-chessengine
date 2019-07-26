-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.level = 0
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	if (machine:outputs():get_value("digit0") ~= 0x38) then
		send_input(":IN.0", 0x040, 1) -- LEVEL
	end
	interface.send_pos(interface.level)
	send_input(":IN.0", 0x200, 1) -- ENTER
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":IN.0", 0x010, 1) -- RESTORE
	send_input(":IN.0", 0x200, 1) -- ENTER
	emu.wait(1.0)

	interface.cur_level = 0
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x001, 1) -- GO
end

function interface.stop_play()
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_value("4." .. tostring(x - 1)) ~= 0
	local yval = machine:outputs():get_value("5." .. tostring(y - 1)) ~= 0
	return xval and yval
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.0", 0x002, 1)
	elseif (p == 2)	then	send_input(":IN.1", 0x002, 1)
	elseif (p == 3)	then	send_input(":IN.1", 0x100, 1)
	elseif (p == 4)	then	send_input(":IN.0", 0x004, 1)
	elseif (p == 5)	then	send_input(":IN.1", 0x004, 1)
	elseif (p == 6)	then	send_input(":IN.1", 0x080, 1)
	elseif (p == 7)	then	send_input(":IN.0", 0x008, 1)
	elseif (p == 8)	then	send_input(":IN.1", 0x008, 1)
	end
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "0", "0", "8"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 8) then
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
