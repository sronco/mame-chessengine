-- license:BSD-3-Clause

interface = load_interface("mm4")

interface.level = "1"
interface.cur_level = nil

local function setdigit(n)
	if     (n == 0) then send_input(":KEY.0", 0x40, 0.5)
	elseif (n == 1) then send_input(":KEY.1", 0x08, 0.5)
	elseif (n == 2) then send_input(":KEY.1", 0x20, 0.5)
	elseif (n == 3) then send_input(":KEY.1", 0x40, 0.5)
	elseif (n == 4) then send_input(":KEY.1", 0x80, 0.5)
	elseif (n == 5) then send_input(":KEY.1", 0x01, 0.5)
	elseif (n == 6) then send_input(":KEY.1", 0x02, 0.5)
	elseif (n == 7) then send_input(":KEY.1", 0x04, 0.5)
	elseif (n == 8) then send_input(":KEY.1", 0x10, 0.5)
	elseif (n == 9) then send_input(":KEY.0", 0x80, 0.5)
	end
end

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":KEY.0", 0x10, 1) -- LEV
	if (interface.level:sub(1,1) == "8") then
		setdigit(8)
		for i=3,5 do
			setdigit(tonumber(interface.level:sub(i,i)))
		end
		send_input(":KEY.0", 0x20, 1) -- ENT
		send_input(":KEY.0", 0x01, 1) -- CL
	else
		setdigit(tonumber(interface.level))
		send_input(":KEY.0", 0x20, 1) -- ENT
	end
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)
--	send_input(":KEY.0", 0x01, 1) -- CL
--	emu.wait(1.0)

	interface.cur_level = "1"
	interface.setlevel()
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
