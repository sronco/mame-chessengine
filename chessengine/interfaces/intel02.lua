-- load interface for the cartridge
local module = machine.images['cart']:filename()
if (module == "chess2") then
	return load_interface("intel02_chess2")
elseif (module == "chess") then
	return load_interface("intel02_chess")
end

return nil


