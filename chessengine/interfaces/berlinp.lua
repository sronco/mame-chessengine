-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	emu.wait(1.0)
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x01, 0.5)	-- ENT
end

function interface.start_play()
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x02, 0.5)	-- CL
	send_input(":KEY", 0x20, 0.5)	-- RIGHT
	send_input(":KEY", 0x01, 0.5)	-- ENT
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value("led", (y - 1) * 8 + (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	if (event ~= "capture" and event ~= "en_passant") then
		send_input(":board:IN." .. tostring(y - 1), 1 << (x - 1), 1)
	end
end

function interface.get_promotion()
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	local right = 0
	if     (piece == "q") then	right = 0
	elseif (piece == "r") then	right = 1
	elseif (piece == "b") then	right = 2
	elseif (piece == "n") then	right = 3
	end

	for i=1,right do
		send_input(":KEY", 0x20, 1)	-- RIGHT
	end

	send_input(":KEY", 0x01, 1)	-- ENT
end

return interface
