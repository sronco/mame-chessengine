-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

-- load interface for the cartridge
if (string.find(machine.images['cart']:filename(), 'sargon25') ~= nil) then
	return load_interface("arb_sargon25")
elseif (string.find(machine.images['cart']:filename(), 'gms40') ~= nil) then
	return load_interface("arb_gms40")
end

return nil



