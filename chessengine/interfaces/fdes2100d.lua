-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("chesster")
local opt_clear_announcements = false

function interface.clear_announcements()
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	local d4 = machine:outputs():get_value("digit4")
	local d5 = machine:outputs():get_value("digit5")

	-- clear announcements to continue the game
	if (((d3 == 0x54 or d3 == 0x37) and d4 == 0x00) or			--  'M ' forced checkmate found in X moves
	     (d2 == 0x5e and d3 == 0x50 and d4 == 0x39 and d5 == 0x4f) or	--  'drC3' threefold repetition
	     (d2 == 0x5e and d3 == 0x50 and d4 == 0x6d and d5 == 0x3f)) then	--  'dr50' fifty-move rule
		send_input(":IN.8", 0x01, 1)
	end
end

function interface.is_selected(x, y)
	if (opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return (machine:outputs():get_indexed_value("0.", (y - 1)) ~= 0) and (machine:outputs():get_indexed_value("1.", (x - 1)) ~= 0)
end

function interface.select_piece(x, y, event)
	if (opt_clear_announcements) then
		interface.clear_announcements()
	end

	if (event ~= "capture") then
		send_input(":IN." .. tostring(8 - y), 1 << (8 - x), 1)
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

return interface
