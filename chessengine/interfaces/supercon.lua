interface = {}

interface.level = 2
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	repeat
		send_input(":IN.6", 0x02, 0.5) -- Set Level
		local cur_level = 0
		for y=0,7 do
			if machine:outputs():get_indexed_value("1.", y) ~= 0 then
				cur_level = cur_level + 1
			end
		end
	until cur_level == interface.level
	send_input(":IN.7", 0x01, 1) -- Go
end

function interface.setup_machine()
	sb_reset_board(":board")
	send_input(":IN.0", 0x01, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = 2
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.7", 0x01, 1) -- Go
end

function interface.is_selected(x, y)
	return (machine:outputs():get_indexed_value("1.", (8 - y)) ~= 0) and (machine:outputs():get_indexed_value("2.", (x - 1)) ~= 0)
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "2", "1", "8"}, }  -- default difficulty level is 2
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 8) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion_led()
	if     (machine:outputs():get_value("0.1") ~= 0) then	return 'q'
	elseif (machine:outputs():get_value("0.4") ~= 0) then	return 'r'
	elseif (machine:outputs():get_value("0.2") ~= 0) then	return 'b'
	elseif (machine:outputs():get_value("0.3") ~= 0) then	return 'n'
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
	sb_promote(":board", x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.1", 0x02, 1)
	elseif (piece == "r") then	send_input(":IN.4", 0x02, 1)
	elseif (piece == "b") then	send_input(":IN.2", 0x02, 1)
	elseif (piece == "n") then	send_input(":IN.3", 0x02, 1)
	end
end

return interface
