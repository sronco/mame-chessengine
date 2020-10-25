interface = load_interface("megaiv")

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
	send_input(":KEY.1", 0x08, 1)  -- LEV
	emu.wait(0.5)
	sb_press_square(":board:board", 1, x, y)
	emu.wait(0.5)
	send_input(":KEY.1", 0x80, 1) -- CL
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

return interface
