-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

-- load interface for the cartridge
if (string.find(machine.images['cart']:filename(), 'chess2') ~= nil) then
	return load_interface("intel02_chess2")
elseif (string.find(machine.images['cart']:filename(), 'chess') ~= nil) then
	return load_interface("intel02_chess")
end

return nil


