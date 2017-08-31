-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	-- setup board pieces
	for y=0,7 do
		local port_tag = ":board:IN." .. tostring(y)
		local port_val = machine:ioport().ports[port_tag]:read()
		for x=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - x)) ~= 0) or (req_pos == false and port_val & (1 << (7 - x)) == 0)) then
				send_input(port_tag, 1 << (7 - x), 0.10)
			end
		end
	end

	emu.wait(1.0)
	send_input(":KEY3", 0x0200, 0.5)	-- CL
	send_input(":KEY3", 0x0200, 0.5)	-- CL
	send_input(":KEY2", 0x0100, 0.5)	-- RIGHT
	send_input(":KEY2", 0x0100, 0.5)	-- RIGHT
	send_input(":KEY2", 0x0100, 0.5)	-- RIGHT
	send_input(":KEY2", 0x0100, 0.5)	-- RIGHT
	send_input(":KEY1", 0x0200, 0.5)	-- ENT
end

function interface.start_play()
	send_input(":KEY3", 0x0200, 0.5)	-- CL
	send_input(":KEY3", 0x0200, 0.5)	-- CL
	send_input(":KEY2", 0x0100, 0.5)	-- RIGHT
	send_input(":KEY1", 0x0200, 0.5)	-- ENT
end

function interface.is_selected(x, y)
	return machine:outputs():get_indexed_value("led", (y - 1) * 8 + (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	send_input(":board:IN." .. tostring(y - 1), 1 << (x - 1), 1)
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
		send_input(":KEY2", 0x0100, 1)	-- RIGHT
	end

	send_input(":KEY1", 0x0200, 1)	-- ENT
end

return interface
