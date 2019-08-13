-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("glasgow")

interface.level = 2
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	if (interface.level == 38 or interface.level == 39 or interface.level > 49) then
		return
	end
	local lev = tostring(interface.level)
	if (interface.level < 10) then
		lev = "0" .. lev
	end
	send_input(":LINE1", 0x20, 1) -- LEV
	for i=1,2 do
		local dig = tonumber(lev:sub(i,i))
		if     (dig == 0) then	send_input(":LINE1", 0x04, 1)
		elseif (dig == 1) then	send_input(":LINE0", 0x20, 1)
		elseif (dig == 2) then	send_input(":LINE0", 0x80, 1)
		elseif (dig == 3) then	send_input(":LINE0", 0x04, 1)
		elseif (dig == 4) then	send_input(":LINE0", 0x10, 1)
		elseif (dig == 5) then	send_input(":LINE1", 0x01, 1)
		elseif (dig == 6) then	send_input(":LINE0", 0x40, 1)
		elseif (dig == 7) then	send_input(":LINE1", 0x40, 1)
		elseif (dig == 8) then	send_input(":LINE1", 0x10, 1)
		elseif (dig == 9) then	send_input(":LINE0", 0x01, 1)
		end
	end
	send_input(":LINE0", 0x08, 1) -- ENT
end

function interface.get_options()
	return { { "spin", "Level", "2", "0", "99"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 99) then
			return
		end
		interface.level = level
		interface.setlevel()
	end
end

return interface
