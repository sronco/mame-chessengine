-- load interface for the cartridge
local module = machine.images['cart']:filename()
if (module == "sargon25") then
	return load_interface("arb_sargon25")
elseif (module == "gms40") then
	return load_interface("arb_gms40")
end

return nil
