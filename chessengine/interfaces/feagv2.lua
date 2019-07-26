-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.opt_clear_announcements = true
interface.level = "a1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = tostring(tonumber(interface.level:sub(2, 2)))
	send_input(":IN.0", 0x20, 1)  -- LV
	sb_press_square(":board", 1, x, y)
	send_input(":IN.1", 0x01, 1) -- CL
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(3.0)
	send_input(":IN.1", 0x04, 1) -- New Game
	emu.wait(1.0)

	interface.cur_level = ""
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x80, 1) -- RV
end

function interface.clear_announcements()
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	local d5 = machine:outputs():get_value("digit5")
	local d6 = machine:outputs():get_value("digit6")
	local d7 = machine:outputs():get_value("digit7")
	local d8 = machine:outputs():get_value("digit8")

	-- clear announcements to continue the game
	if ((d5 == 0x37 and d7 == 0x00) or (d0 == 0x37 and d2 == 0x00) or									--  'M '   = forced checkmate found in X moves
	    (d6 == 0x5e and d5 == 0x50 and d7 == 0x39 and d8 == 0x4f) or (d1 == 0x5e and d0 == 0x50 and d2 == 0x39 and d3 == 0x4f) or		--  'drC3' = threefold repetition
	    (d6 == 0x5e and d5 == 0x50 and d7 == 0x6d and d8 == 0x3f) or (d1 == 0x5e and d0 == 0x50 and d2 == 0x6d and d3 == 0x3f)) then	--  'dr50' = fifty-move rule
		send_input(":IN.1", 0x01, 1)
	end
end

function interface.is_selected(x, y)
	if (interface.opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_value((y - 1) .. "." .. (16 - x)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a1"}, { "check", "Clear announcements", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
		interface.setlevel()
	end
	if (name == "clear announcements") then
		interface.opt_clear_announcements = tonumber(value) == 1
	end
end

function interface.get_promotion_led()
	if     (machine:outputs():get_value("8.11") ~= 0) then	return 'q'
	elseif (machine:outputs():get_value("8.12") ~= 0) then	return 'r'
	elseif (machine:outputs():get_value("8.13") ~= 0) then	return 'b'
	elseif (machine:outputs():get_value("8.14") ~= 0) then	return 'n'
	end
	return nil
end

function interface.get_promotion(x, y)
	if (interface.opt_clear_announcements) then
		interface.clear_announcements()
	end
	interface.select_piece(x, y, "")
	emu.wait(0.25)

	local new_type = nil
	for i=1,5 do
		local ntype = interface.get_promotion_led()
		if (new_type ~= nil and new_type == ntype) then
			break
		end

		new_type = ntype
		emu.wait(0.25)
	end

	interface.select_piece(x, y, "")

	return new_type
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	sb_press_square(":board", 1, x, y)

	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.0", 0x02, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x04, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.0", 0x10, 1)
	end
end

return interface
