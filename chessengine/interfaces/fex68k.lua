-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}
local opt_clear_announcements = false

function interface.setup_machine()
	emu.wait(3.0)

	-- new game
	send_input(":IN.8", 0x80, 1)
end

function interface.start_play()
	emu.wait(1.0)
	send_input(":IN.8", 0x02, 1)
end

function interface.clear_announcements()
	local d0 = machine:outputs():get_value("digit0")
	local d2 = machine:outputs():get_value("digit2")
	local d4 = machine:outputs():get_value("digit4")
	local d6 = machine:outputs():get_value("digit6")

	-- clear announcements to continue the game
	if ((d4 == 0x37 and d2 == 0x00) or					--  'M ' forced checkmate found in X moves
	    (d6 == 0x5e and d4 == 0x50 and d2 == 0x39 and d0 == 0x4f) or	--  'drC3' threefold repetition
	    (d6 == 0x5e and d4 == 0x50 and d2 == 0x6d and d0 == 0x3f)) then	--  'dr50' fifty-move rule
		send_input(":IN.8", 0x01, 1)
	end
end

function interface.is_selected(x, y)
	if (opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	-- the first line of LEDs is also used for announcements, so we need to be sure that the LED does not flash
	if (y == 1) then
		for i=1,5 do
			if (machine:outputs():get_indexed_value(tostring(x - 1) .. ".", 7 + y) == 0) then
				return false
			end
			emu.wait(0.15)
		end

		return true
	else
		return machine:outputs():get_indexed_value(tostring(x - 1) .. ".", 7 + y) ~= 0
	end
end

function interface.select_piece(x, y, event)
	if (event ~= "capture") then
		send_input(":IN." .. tostring(x - 1), 1 << (y - 1), 1)
	end
end

function interface.get_options()
	return { { "check", "Clear announcements", "0"}, }
end

function interface.set_option(name, value)
	if (name == "clear announcements") then
		opt_clear_announcements = tonumber(value) == 1
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.8", 0x20, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x04, 1)
	end
end

return interface
