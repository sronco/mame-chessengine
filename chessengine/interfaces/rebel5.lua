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
	if     (n == 0) then send_input(":KEY1_6", 0x80, 1)
	elseif (n == 1) then send_input(":KEY2_3", 0x80, 1)
	elseif (n == 2) then send_input(":KEY2_5", 0x80, 1)
	elseif (n == 3) then send_input(":KEY2_6", 0x80, 1)
	elseif (n == 4) then send_input(":KEY2_7", 0x80, 1)
	elseif (n == 5) then send_input(":KEY2_0", 0x80, 1)
	elseif (n == 6) then send_input(":KEY2_1", 0x80, 1)
	elseif (n == 7) then send_input(":KEY2_2", 0x80, 1)
	elseif (n == 8) then send_input(":KEY2_4", 0x80, 1)
	elseif (n == 9) then send_input(":KEY1_7", 0x80, 1)
	end
	send_input(":KEY1_5", 0x80, 1) -- ENT
end

function interface.get_options()
	return { { "spin", "Level", "1", "0", "9"}, }
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

return interface
