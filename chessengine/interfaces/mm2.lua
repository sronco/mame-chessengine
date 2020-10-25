interface = load_interface("mm4")

interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":KEY1_4", 0x80, 1) -- LEV
	local n = tonumber(interface.level)
	if     (n == 1) then send_input(":KEY2_3", 0x80, 1)
	elseif (n == 2) then send_input(":KEY2_5", 0x80, 1)
	elseif (n == 3) then send_input(":KEY2_6", 0x80, 1)
	elseif (n == 4) then send_input(":KEY2_7", 0x80, 1)
	elseif (n == 5) then send_input(":KEY2_0", 0x80, 1)
	elseif (n == 6) then send_input(":KEY2_1", 0x80, 1)
	elseif (n == 7) then send_input(":KEY2_2", 0x80, 1)
	elseif (n == 8) then send_input(":KEY2_4", 0x80, 1)
	elseif (n == 9) then send_input(":KEY1_7", 0x80, 1)
	elseif (n == 10) then send_input(":KEY1_6", 0x80, 1)
	end
	send_input(":KEY1_5", 0x80, 1) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)
	while (machine:outputs():get_indexed_value("led", 105) == 0 or machine:outputs():get_value("digit0") ~= 0x73) do
		machine:soft_reset()
		emu.wait(1.0)
	end

	interface.cur_level = 1
	interface.setlevel()
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "10"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 10) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	local d0 = machine:outputs():get_value("digit0") & 0x7f
	local d1 = machine:outputs():get_value("digit1") & 0x7f
	local d3 = machine:outputs():get_value("digit3") & 0x7f

	if (d0 == 0x73 and d1 == 0x50) then	-- display shows 'Pr'
		if     (d3 == 0x5e) then	return "q"
		elseif (d3 == 0x31) then	return "r"
		elseif (d3 == 0x38) then	return "b"
		elseif (d3 == 0x6d) then	return "n"
		end
	end

	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board:board", x, y, piece)
	if     (piece == "q" or piece == "Q") then	send_input(":KEY2_0", 0x80, 1)
	elseif (piece == "r" or piece == "R") then	send_input(":KEY2_7", 0x80, 1)
	elseif (piece == "b" or piece == "B") then	send_input(":KEY2_6", 0x80, 1)
	elseif (piece == "n" or piece == "N") then	send_input(":KEY2_5", 0x80, 1)
	end
end

return interface
