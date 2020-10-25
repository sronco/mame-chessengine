interface = {}

interface.level = "a2"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	if (x > 6) then
		return
	end
	local y = interface.level:sub(2, 2)
	send_input(":KEY.1", 0x20, 1) -- LEV
	emu.wait(0.5)
	sb_press_square(":board:board", 1, x, y)
	emu.wait(0.5)
	send_input(":KEY.1", 0x10, 1) -- CL
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(2.0)
--	send_input(":KEY.0", 0x80, 1) -- RES
--	emu.wait(1.0)

	interface.cur_level = "a2"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":KEY.1", 0x40, 1) -- ENT
end

function interface.is_selected(x, y)
	if (machine:outputs():get_value("digit1") & 0x80 ~= 0 and machine:outputs():get_value("digit5") & 0x80 ~= 0) then
		return false
	end
	return machine:outputs():get_indexed_value("led", (y - 1) * 8 + (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board:board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a2"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	local d0 = machine:outputs():get_value("digit0") & 0x7f
	local d1 = machine:outputs():get_value("digit1") & 0x7f
	local d4 = machine:outputs():get_value("digit4") & 0x7f
	local d5 = machine:outputs():get_value("digit5") & 0x7f
	local d3 = nil

	if (d0 == 0x73 and d1 == 0x50) then	-- UPper display shows 'Pr'
		d3 = machine:outputs():get_value("digit3") & 0x7f
	end
	if (d4 == 0x73 and d5 == 0x50) then	-- lower display shows 'Pr'
		d3 = machine:outputs():get_value("digit7") & 0x7f
	end

	if     (d3 == 0x5e) then	return "q"
	elseif (d3 == 0x31) then	return "r"
	elseif (d3 == 0x38) then	return "b"
	elseif (d3 == 0x6d) then	return "n"
	end

	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board:board", x, y, piece)
	if     (piece == "q") then	send_input(":KEY.0", 0x10, 1)
	elseif (piece == "r") then	send_input(":KEY.0", 0x08, 1)
	elseif (piece == "b") then	send_input(":KEY.0", 0x04, 1)
	elseif (piece == "n") then	send_input(":KEY.0", 0x02, 1)
	end
end

return interface
