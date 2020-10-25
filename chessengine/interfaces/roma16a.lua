interface = load_interface("glasgow")

interface.level = "02"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local level = interface.level
	send_input(":LINE1", 0x20, 0.25) -- LEV
	for i=1,level:len() do
		local n = level:sub(i,i)
		if (n == " " or n == ":" or n == "/") then
			send_input(":LINE0", 0x08, 0.25) -- ENT
			if (n == " " and (machine:outputs():get_value("digit3") & 0x7f) == 0x54) then
				send_input(":LINE0", 0x08, 0.25) -- ENT
			end
		else
			interface.setdigit(tonumber(n))
		end
	end
	send_input(":LINE0", 0x08, 0.25) -- ENT
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)

	interface.cur_level = "02"
	interface.setlevel()
end

function interface.get_options()
	return { { "string", "Level", "02"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," ") -- trim
		if (level:match("^%d$")) then
			level = "0" .. level
		end
		local lev = tonumber(level:sub(1,2))
		if (level:match("^%d%d$")) then
			if (lev <= 37 or (lev >= 40 and lev <= 49) or lev >= 61) then
				interface.level = level
				interface.setlevel()
			end
		elseif (level:match("^%d%d%s") and (level:match("00/") == nil)) then
			local hm  = "%s%d%d:[0-5]%d"
			local hms = "%s%d%d:[0-5]%d:[0-5]%d"
			local nhm = "%s%d%d/%d%d:[0-5]%d"
			if (((lev == 38 or lev == 50 or lev == 58) and (level:len() == 11) and level:match(hms))
			or  ((lev == 39 or lev == 51) and (level:len() == 20) and level:match(hms .. hms))
			or  ((lev == 52) and (level:len() == 11) and level:match(nhm))
			or  ((lev == 53 or lev == 54 or lev == 59) and (level:len() == 20) and level:match(nhm .. nhm))
			or  ((lev == 55) and (level:len() == 38) and level:match(nhm .. nhm .. nhm .. nhm))
			or  ((lev == 56) and (level:len() == 17) and level:match(nhm .. hm))
			or  ((lev == 57) and (level:len() == 32) and level:match(nhm .. hm .. nhm .. hm))
			or  ((lev == 60) and (level:len() == 4) and level:match("%s%d"))) then
				interface.level = level
				interface.setlevel()
			end
		end
	end
end

return interface
