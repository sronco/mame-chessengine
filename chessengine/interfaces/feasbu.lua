-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}
local last_put = nil
local opt_clear_announcements = false

function interface.setup_machine()
	-- setup board pieces
	for x=0,7 do
		local port_tag = ":IN." .. tostring(x)
		local port_val = machine:ioport().ports[port_tag]:read()
		for y=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - y)) == 0) or (req_pos == false and port_val & (1 << (7 - y)) ~= 0)) then
				send_input(port_tag, 1 << (7 - y), 0.10)
			end
		end
	end

	last_put = nil
	emu.wait(1)
	send_input(":IN.8", 0x01, 1)	-- Game Control
	emu.wait(3)
	send_input(":IN.3", 0x01, 1)	-- D8
	send_input(":IN.3", 0x01, 1)	-- D8
	send_input(":IN.1", 0x100, 1)	-- CL
end

function interface.start_play()
	send_input(":IN.2", 0x100, 1)
end

function interface.clear_announcements()
	-- machine turns on all LEDs on the first line for mate/draw announcements
	if (machine:outputs():get_value("0.15") ~= 0 and machine:outputs():get_value("1.15") ~= 0 and machine:outputs():get_value("2.15") ~= 0 and machine:outputs():get_value("3.15") ~= 0 and
	    machine:outputs():get_value("4.15") ~= 0 and machine:outputs():get_value("5.15") ~= 0 and machine:outputs():get_value("6.15") ~= 0 and machine:outputs():get_value("7.15") ~= 0) then
		send_input(":IN.1", 0x100, 1)
	end
end
function interface.is_selected(x, y)
	if (opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return machine:outputs():get_indexed_value(tostring(x - 1) .. ".", 16 - y) ~= 0
end

function interface.select_piece(x, y, event)
	send_input(":IN." .. tostring(x - 1), 1 << (8 - y), 1)

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

function interface.get_promotion()
	if (last_put == nil) then
		return nil
	end

	local promo_pos = last_put
	last_put = nil
	interface.clear_announcements()
	interface.select_piece(promo_pos.x, promo_pos.y, "")

	local new_type = nil
	if     (machine:outputs():get_value("8.9")  ~= 0) then 	new_type = 'q'
	elseif (machine:outputs():get_value("8.10") ~= 0) then 	new_type = 'r'
	elseif (machine:outputs():get_value("8.11") ~= 0) then 	new_type = 'b'
	elseif (machine:outputs():get_value("8.12") ~= 0) then 	new_type = 'n'
	end

	interface.select_piece(promo_pos.x, promo_pos.y, "")
	return new_type
end

function interface.promote(x, y, piece)
	interface.select_piece(x, y, "")
	interface.select_piece(x, y, "")
	if     (piece == "q") then	send_input(":IN.8", 0x08, 1)
	elseif (piece == "r") then	send_input(":IN.8", 0x10, 1)
	elseif (piece == "b") then	send_input(":IN.8", 0x20, 1)
	elseif (piece == "n") then	send_input(":IN.8", 0x40, 1)
	end
end

return interface
