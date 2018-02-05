-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":BUTTONS", 0x80, 1)
end

function interface.start_play()
	send_input(":BUTTONS", 0x20, 1)
end

function interface.is_selected(x, y)
	local led_tag = { "a", "b", "c", "d", "e", "f", "g", "h" }
	return machine:outputs():get_indexed_value("led_" .. led_tag[x], 9 - y) == 0
end

function interface.select_piece(x, y, event)
	local port_tags = { "A", "B", "C", "D", "E", "F", "G", "H" }
	send_input(":COL_" .. port_tags[x], 1 << (y - 1), 1)
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "8"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 8) then
			return
		end
		send_input(":BUTTONS", 0x40, 1)
		send_input(":BUTTONS", 0x80 >> (level - 1), 1)
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	-- TODO
end

return interface
