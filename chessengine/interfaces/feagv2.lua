-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}
local last_put = nil
local opt_clear_announcements = false

function interface.setup_machine()
	-- setup board pieces
	for y=0,7 do
		local port_tag = ":IN." .. tostring(y)
		local port_val = machine:ioport().ports[port_tag]:read()
		for x=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - x)) == 0) or (req_pos == false and port_val & (1 << (7 - x)) ~= 0)) then
				send_input(port_tag, 1 << (7 - x), 0.10)
			end
		end
	end
	send_input(":IN.2", 0x100, 1)

	last_put = nil
	emu.wait(3.0)
end

function interface.start_play()
	send_input(":IN.8", 0x80, 1)
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
		send_input(":IN.0", 0x100, 1)
	end
end

function interface.is_selected(x, y)
	if (opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_value((y - 1) .. "." .. (16 - x)) ~= 0
end

function interface.select_piece(x, y, event)
	send_input(":IN." .. tostring(y - 1), 1 << (8 - x), 1)

	if (event == "put") then
		last_put = {x = x, y = y}
	else
		last_put = nil
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

function interface.get_promotion_led()
	if     (machine:outputs():get_value("8.11") ~= 0) then 	return 'q'
	elseif (machine:outputs():get_value("8.12") ~= 0) then 	return 'r'
	elseif (machine:outputs():get_value("8.13") ~= 0) then 	return 'b'
	elseif (machine:outputs():get_value("8.14") ~= 0) then 	return 'n'
	end
	return nil
end

function interface.get_promotion()
	if (last_put == nil) then
		return nil
	end

	local promo_pos = last_put
	last_put = nil
	if (opt_clear_announcements) then
		interface.clear_announcements()
	end
	interface.select_piece(promo_pos.x, promo_pos.y, "")
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

	interface.select_piece(promo_pos.x, promo_pos.y, "")

	return new_type
end

function interface.promote(x, y, piece)
	interface.select_piece(x, y, "")
	interface.select_piece(x, y, "")

	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.8", 0x02, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x04, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x10, 1)
	end
end

return interface

