-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("chessmst")

function interface.setup_machine()
	emu.wait(2.0)
end

function interface.start_play()
	send_input(":BUTTONS", 0x80, 1)
end

function interface.promote(x, y, piece)
	local right = 0
	if     (piece == "q") then	right = 0
	elseif (piece == "r") then	right = 1
	elseif (piece == "b") then	right = 2
	elseif (piece == "n") then	right = 3
	end

	for i=1,right do
		send_input(":BUTTONS", 0x01, 1)
	end

	send_input(":BUTTONS", 0x80, 1)
end

return interface
