-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("supercon")

function interface.setup_machine()
	send_input(":IN.0", 0x100, 1)
	emu.wait(2.0)
end

function interface.get_promotion()
	local d8 = machine:outputs():get_value("digit8")

	if     (d8 == 0x67) then	return "q"
	elseif (d8 == 0x50) then	return "r"
	elseif (d8 == 0x7c) then	return "b"
	elseif (d8 == 0x54) then	return "n"
	end

	return nil
end

return interface
