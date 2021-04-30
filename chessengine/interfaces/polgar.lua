-- license:BSD-3-Clause

interface = {}

interface.level = "NORMAL 0:10"
interface.cur_level = nil
interface.levelnum = 1

local function setdigits(n,r,s)
	local ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram'])
	send_input(":KEY", 0x40, 0.25) -- ENT
	for i=1,n do
		if (n == 3 and i == 2) then
			r = r + 1
			s = s + 1
		end
		while (string.char(ddram:read(0x40+r+i-1)) ~= interface.level:sub(s+i-1,s+i-1)) do
			if     (i == 1) then send_input(":KEY", 0x01, 0.25) -- TRN
			elseif (i == 2) then send_input(":KEY", 0x02, 0.25) -- INFO
			elseif (i == 3) then send_input(":KEY", 0x04, 0.25) -- MEM
			elseif (i == 4) then send_input(":KEY", 0x08, 0.25) -- POS
			end
		end
	end
	send_input(":KEY", 0x80, 0.25) -- CL
end

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level or interface.levelnum == 0) then
		return
	end
	send_input(":KEY", 0x10, 0.5) -- LEV
	emu.wait(0.5)
	local ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram']):read_block(0x40, 0x10)
	local temp = string.upper(ddram:sub(1,5))
	local n = 0
	if     (temp == " NORM" or temp == "NORMA") then n = 1
	elseif (temp == "TURN " or temp == "TOUR ") then n = 2
	elseif (temp == "BLITZ") then n = 3
	elseif (temp == "RECHE" or string.match(temp,"PLY[%-%s]D")) then n = 4
	elseif (temp == "MATT " or temp == "MATE ") then n = 5
	elseif (string.match(temp,"ELO[%-%s]T")) then n = 6
	elseif (string.match(temp,"ELO[%-%s]A")) then n = 7
	elseif (string.match(temp,"-- %u%u")) then n = 8
	else
		send_input(":KEY", 0x80, 0.5) -- CL
		return
	end
	interface.cur_level = interface.level
	n = (interface.levelnum - n + 8) % 8
	for i=1,n do
		send_input(":KEY", 0x10, 0.25) -- LEV
	end
	local s = 0
	if (interface.levelnum == 1) then
		s = string.find(interface.level,"%d:[0-5]%d")
		setdigits(3,12,s)
	elseif (interface.levelnum == 2) then
		s = string.find(interface.level,"%d%d")
		setdigits(2,5,s)
		s = string.find(interface.level,"%d:[0-5]%d",s+1)
		setdigits(3,12,s)
	elseif (interface.levelnum == 3) then
		s = string.find(interface.level,"%d:[0-5]%d")
		setdigits(3,7,s)
		s = string.find(interface.level,"%d:[0-5]%d",s+1)
		setdigits(3,12,s)
	elseif (interface.levelnum == 4) then
		s = string.find(interface.level,"%d%d")
		setdigits(2,12,s)
	elseif (interface.levelnum == 5) then
		s = string.find(interface.level,"[1-8]")
		setdigits(1,8,s)
	elseif (interface.levelnum == 6) then
		s = string.find(interface.level,"%d%d%d%d")
		setdigits(4,12,s)
	elseif (interface.levelnum == 7) then
		s = string.find(interface.level,"%d%d%d%d")
		setdigits(4,12,s)
	elseif (interface.levelnum == 8) then
		-- nothing to do
	end
	send_input(":KEY", 0x80, 0.5) -- CL
end

function interface.setup_machine()
	sb_reset_board(":board:board")
	emu.wait(1.0)

	interface.cur_level = ""
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":KEY", 0x40, 1)
end

function interface.is_selected(x, y)
	return output:get_indexed_value("led", (y - 1) * 8 + (x - 1)) ~= 0
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board:board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "NORMAL 0:10"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local temp = string.upper(value)
		interface.levelnum = 0
		if     ((string.match(temp,"NORMAL%s+%d:[0-5]%d")) or (string.match(temp,"NORMAL%s+TIME%s+%d:[0-5]%d"))) then
			interface.levelnum = 1
		elseif ((string.match(temp,"TURN%s+%d%d%s+IN%s+%d:[0-5]%d")) or (string.match(temp,"TOUR%s+%d%d%s+IN%s+%d:[0-5]%d"))) then
			interface.levelnum = 2
		elseif (string.match(temp,"BLITZ%s+%d:[0-5]%d%s+%d:[0-5]%d")) then
			interface.levelnum = 3
		elseif ((string.match(temp,"RECHENTIEFE%s+%d%d?")) or (string.match(temp,"PLY[%-%s]DEPTH%s+%d%d?"))) then
			if (string.match(temp," %d%d") == nil) then
				local s = string.find(temp," %d")
				value = value:sub(1,s) .. "0" .. value:sub(s+1,s+1)
			end
			interface.levelnum = 4
		elseif ((string.match(temp,"MATT%s+IN%s+[1-8]")) or (string.match(temp,"MATE%s+IN%s+[1-8]"))) then
			interface.levelnum = 5
		elseif ((string.match(temp,"ELO[%-%s]TURNIER%s+%d%d%d%d")) or (string.match(temp,"ELO[%-%s]TOUR%s+%d%d%d%d"))) then
			interface.levelnum = 6
		elseif ((string.match(temp,"ELO[%-%s]AKTIV%s+%d%d%d%d")) or (string.match(temp,"ELO[%-%s]ACTIVE%s+%d%d%d%d"))) then
			interface.levelnum = 7
		elseif ((string.match(temp,"ANALYSE")) or (string.match(temp,"INFINITE")) or (string.match(temp,"UNBEGRENZT")) or (string.match(temp,"UNENDLICH"))) then
			interface.levelnum = 8
		end
		if (interface.levelnum ~= 0) then
			interface.level = value
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	-- HD44780 Display Data RAM
	local ddram = emu.item(machine.devices[':display:hd44780'].items['0/m_ddram']):read_block(0x00, 0x80)

	if     (ddram:sub(65,81):find('\x04') or ddram:sub(65,81):find('\x0c')) then return 'q'
	elseif (ddram:sub(65,81):find('\x03') or ddram:sub(65,81):find('\x0b')) then return 'r'
	elseif (ddram:sub(65,81):find('\x02') or ddram:sub(65,81):find('\x0a')) then return 'b'
	elseif (ddram:sub(65,81):find('\x01') or ddram:sub(65,81):find('\x09')) then return 'n'
	end

	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board:board", x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then send_input(":KEY", 0x10, 1)
	elseif (piece == "r") then send_input(":KEY", 0x08, 1)
	elseif (piece == "b") then send_input(":KEY", 0x02, 1)
	elseif (piece == "n") then send_input(":KEY", 0x04, 1)
	end
end

return interface
