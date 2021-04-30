-- license:BSD-3-Clause

interface = load_interface("concstd")

function interface.get_options()
	return { { "string", "Level", "L2"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," "):upper() -- trim
		if (level:match("^L[1-5]$")) then
			level = "P" .. level:sub(2,2)
		elseif (level:match("^L[6-9]$") or level == "L10") then
			level = "T" .. tostring(tonumber(level:sub(2,3)) - 5)
		elseif (level:match("^[PT][1-5]$") == nil and level:match("^[AM]$") == nil) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

return interface
