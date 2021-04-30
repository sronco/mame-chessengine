-- license:BSD-3-Clause

-- load interface for the cartridge
local module = machine.images[':cartslot'].filename
if (module == "chess2") then
	return load_interface("intel02_chess2")
elseif (module == "chess") then
	return load_interface("intel02_chess")
end

return nil


