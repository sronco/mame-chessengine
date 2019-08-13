-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("stratos")
interface.level = "a3"

function interface.is_selected(x, y)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	return machine:outputs():get_indexed_value(tostring(2 + x) .. ".", y - 1) ~= 0
end

function interface.get_options()
	return { { "string", "Level", "a3"}, }
end

return interface
