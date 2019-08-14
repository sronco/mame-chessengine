-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.level = 2
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":IN.0", 0x08, 0.5) -- LEV
	emu.wait(1)
	if     (interface.cur_level == 1) then	send_input(":IN.0", 0x01, 1)
	elseif (interface.cur_level == 2) then	send_input(":IN.1", 0x01, 1)
	elseif (interface.cur_level == 3) then	send_input(":IN.2", 0x01, 1)
	elseif (interface.cur_level == 4) then	send_input(":IN.3", 0x01, 1)
	elseif (interface.cur_level == 5) then	send_input(":IN.0", 0x02, 1)
	elseif (interface.cur_level == 6) then	send_input(":IN.1", 0x02, 1)
	elseif (interface.cur_level == 7) then	send_input(":IN.2", 0x02, 1)
	elseif (interface.cur_level == 8) then	send_input(":IN.3", 0x02, 1)
	elseif (interface.cur_level == 9) then	send_input(":IN.0", 0x04, 1)
	elseif (interface.cur_level == 0) then	send_input(":IN.1", 0x04, 1)
	end
	send_input(":IN.3", 0x08, 0.5) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(2.0)

	interface.cur_level = 2
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.3", 0x08, 1) -- ENT
	emu.wait(1.0)
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_indexed_value("led", 8 + (x - 1)) ~= 0
	local yval = machine:outputs():get_indexed_value("led", (y - 1)) ~= 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1.0, x, y, event)
end

function interface.get_options()
	return { { "spin", "Level", "2", "0", "9"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 9) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	send_input(":IN.2", 0x04, 0.5) -- INFO
	send_input(":IN.0", 0x01, 0.5) -- 1
	send_input(":IN.1", 0x04, 0.5) -- 0
	local d0 = machine:outputs():get_value("digit0") & 0x7f
	local d1 = machine:outputs():get_value("digit1") & 0x7f
	local d3 = machine:outputs():get_value("digit3") & 0x7f

	local piece = nil
	if (d0 == 0x73 and d1 == 0x50) then	-- display shows 'Pr'
		if     (d3 == 0x5e) then	piece = "q"
		elseif (d3 == 0x31) then	piece = "r"
		elseif (d3 == 0x38) then	piece = "b"
		elseif (d3 == 0x6d) then	piece = "n"
		end
	end

	send_input(":IN.2", 0x08, 0.5) -- CL

	return piece
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	if     (piece == "q") then	send_input(":IN.1", 0x02, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x02, 1)
	elseif (piece == "b") then	send_input(":IN.3", 0x01, 1)
	elseif (piece == "n") then	send_input(":IN.2", 0x01, 1)
	end
	if (piece == "q" or piece == "r" or piece == "b" or piece == "n") then
		send_input(":IN.3", 0x08, 0.5) -- ENT
	end
end

return interface
