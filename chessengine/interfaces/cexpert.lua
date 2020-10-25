interface = {}

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = math.abs(interface.level)
	send_input(":IN.6", 0x02, 1) -- Set Level
	local infinite = machine:outputs():get_value("0.6") == 0 and machine:outputs():get_value("0.5") ~= 0
	local training = machine:outputs():get_value("8.1") ~= 0
	if (level == 0) then
		if (not infinite) then
			send_input(":IN.3", 0x02, 1) -- Infinite
		end
	else
		if (level < 9) then
			sb_press_square(":board", 0.5, 1, level)
		else
			sb_press_square(":board", 0.5, 1, 8)
			for i=1,level-8 do		
				send_input(":IN.6", 0x02, 0.5) -- Set Level
			end
		end
		if (interface.level < 0 ~= training) then
			send_input(":IN.1", 0x02, 1) -- Training Level
		end
	end
	send_input(":IN.7", 0x01, 1) -- Go
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":IN.0", 0x01, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = ""
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.7", 0x01, 1) -- Go
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value(tostring(x - 1) .. ".", 8 - y) ~= 0 
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "1", "-14", "14"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < -14 or level > 14) then
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
	sb_promote(":board", x, y, piece)       -- TODO
--	emu.wait(1.0)
	if     (piece == "q") then send_input(":IN.1", 0x02, 1)
	elseif (piece == "r") then send_input(":IN.4", 0x02, 1)
	elseif (piece == "b") then send_input(":IN.2", 0x02, 1)
	elseif (piece == "n") then send_input(":IN.3", 0x02, 1)
	end
end

return interface
