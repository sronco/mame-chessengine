interface = load_interface("mm4")

interface.level = "1"
interface.cur_level = nil

function setdigit(n)
	if     (n == 0) then send_input(":KEY1_6", 0x80, 0.5)
	elseif (n == 1) then send_input(":KEY2_3", 0x80, 0.5)
	elseif (n == 2) then send_input(":KEY2_5", 0x80, 0.5)
	elseif (n == 3) then send_input(":KEY2_6", 0x80, 0.5)
	elseif (n == 4) then send_input(":KEY2_7", 0x80, 0.5)
	elseif (n == 5) then send_input(":KEY2_0", 0x80, 0.5)
	elseif (n == 6) then send_input(":KEY2_1", 0x80, 0.5)
	elseif (n == 7) then send_input(":KEY2_2", 0x80, 0.5)
	elseif (n == 8) then send_input(":KEY2_4", 0x80, 0.5)
	elseif (n == 9) then send_input(":KEY1_7", 0x80, 0.5)
	end
end

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":KEY1_4", 0x80, 1) -- LEV
	if (interface.level:sub(1,1) == "8") then
		setdigit(8)
		for i=3,5 do
			setdigit(tonumber(interface.level:sub(i,i)))
		end
		send_input(":KEY1_5", 0x80, 1) -- ENT
		send_input(":KEY1_0", 0x80, 1) -- CL
	else
		setdigit(tonumber(interface.level))
		send_input(":KEY1_5", 0x80, 1) -- ENT
	end
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)
--	send_input(":KEY1_0", 0x80, 1) -- CL
--	emu.wait(1.0)

	interface.cur_level = "1"
	interface.setlevel()
end

function interface.is_selected(x, y)
	if (machine:outputs():get_value("led105") == 0) then
		return false
	end
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0") & 0x7f
	local d1 = machine:outputs():get_value("digit1") & 0x7f
	local d2 = machine:outputs():get_value("digit2") & 0x7f
	local d3 = machine:outputs():get_value("digit3") & 0x7f
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3) or machine:outputs():get_value("led" .. tostring(8 * (y - 1) + (x - 1))) ~= 0
end

function interface.get_options()
	return { { "string", "Level", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		if (string.match(value,"%d") and value:len() == 1) then
			if (value == "8") then
				value = "8 600"
			end
		elseif (string.find(value .. string.char(0),"8[-,;:/%s%.]%d%d?%d?%z") == 1) then
			if (value:len() == 3) then value = "8 00" .. value:sub(3,3)
			elseif (value:len() == 4) then value = "8 0" .. value:sub(3,4)
			else value = "8 " .. value:sub(3,5)
			end
		else
			return
		end
		interface.level = value
		interface.setlevel()
	end
end

return interface
