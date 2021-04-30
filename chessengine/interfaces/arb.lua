-- license:BSD-3-Clause

-- load interface for the cartridge
local module = machine.images[':cartslot'].filename
if (module == "sargon25") then
	return load_interface("arb_sargon25")
elseif (module == "gms40") then
	return load_interface("arb_gms40")
end

return nil
