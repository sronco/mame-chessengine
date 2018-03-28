-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("glasgow")

function interface.start_play()
	send_input(":LINE1", 0x20, 1)
end

function interface.get_promotion()
	send_input(":LINE1", 0x01, 0.5)	-- INFO
	send_input(":LINE0", 0x01, 0.5)	-- 1

	local d3 = 0
	for i=0,5 do
		local d0 = machine:outputs():get_value("digit0") & 0x7f
		local d1 = machine:outputs():get_value("digit1") & 0x7f

		if (d0 == 0x73 and d1 == 0x50) then	-- display shows 'Pr'
			d3 = machine:outputs():get_value("digit3") & 0x7f
			break
		end
		send_input(":LINE0", 0x80, 0.5)	-- 0
	end

	send_input(":LINE1", 0x10, 0.5)	-- CLR

	if     (d3 == 0x5e) then	return "q"
	elseif (d3 == 0x31) then	return "r"
	elseif (d3 == 0x38) then	return "b"
	elseif (d3 == 0x6d) then	return "n"
	end

	return nil
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":LINE0", 0x20, 1)
	elseif (piece == "r") then	send_input(":LINE0", 0x10, 1)
	elseif (piece == "b") then	send_input(":LINE0", 0x08, 1)
	elseif (piece == "n") then	send_input(":LINE0", 0x04, 1)
	end
	if (piece == "q" or piece == "r" or piece == "b" or piece == "n") then
		send_input(":LINE1", 0x20, 1)
	end
end

return interface
