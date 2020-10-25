interface = {}

interface.level = "010 sec/move"
interface.cur_level = nil
interface.levelnum = 1

function setdigits(n)
	local dram = emu.item(machine.devices[':ram'].items['0/m_pointer'])
	send_input(":P1", 0x80000000, 0.2) -- Enter
	for i=1,n do
		if (n == 7 and (i == 3 or i == 5)) then
			-- skip char
		else
			local k = tonumber(interface.level:sub(i,i)) - (dram:read(0xeb1+i)-0x30)
			if (n == 7 and i == 6) then
				if (k > 3) then
					k = k - 6
				elseif (k < -3) then
					k = k + 6
				end
			else
				if (k > 5) then
					k = k - 10
				elseif (k < -5) then
					k = k + 10
				end
			end
			for j=1,math.abs(k) do
				if (k > 0) then
					send_input(":P3", 0x80000000, 0.2) -- Up
				else
					send_input(":P2", 0x80000000, 0.2) -- Down
				end
			end
			if (i < n) then
				send_input(":P6", 0x40000000, 0.2) -- Right
			end
		end
	end
end

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level or interface.levelnum == 0) then
		return
	end
	send_input(":P4", 0x80000000, 0.2) -- Menu
	send_input(":P2", 0x80000000, 0.2) -- Down
	send_input(":P2", 0x80000000, 0.2) -- Down
	send_input(":P1", 0x80000000, 0.2) -- Enter
	send_input(":P1", 0x80000000, 0.2) -- Enter
	local dram = emu.item(machine.devices[':ram'].items['0/m_pointer'])
	local s = ""
	local b = 0
	local i = 1
	repeat
		b = dram:read(0xec1 + i)
		if (b ~= 0x00) then
			s = s .. string.char(b)
			i = i + 1
		end
	until (b == 0x00)
	local curnum = 0
	if     (string.match(s,"sec/move") or string.match(s,"Sek/Zug")) then curnum = 1
	elseif (string.match(s,"moves/hrs") or string.match(s,"Z.ge/Std")) then curnum = 2
	elseif (string.match(s,"min/game") or string.match(s,"Min/Partie")) then curnum = 3
	elseif (string.match(s,"ply") or string.match(s,"Halbzug")) then curnum = 4
	elseif (string.match(s,"mate") or string.match(s,"Matt")) then curnum = 5
	elseif (string.match(s,"analysis") or string.match(s,"Analyse")) then curnum = 6
	end
	if (curnum == 0) then
		send_input(":P4", 0x80000000, 0.2) -- Menu
		return
	end
	interface.cur_level = interface.level
	local k = interface.levelnum - curnum
	if (k > 3) then
		k = k - 6
	elseif (k < -3) then
		k = k + 6
	end
	for i=1,math.abs(k) do
		if (k > 0) then
			send_input(":P2", 0x80000000, 0.2) -- Down
		else
			send_input(":P3", 0x80000000, 0.2) -- Up
		end
	end
	if     (interface.levelnum == 1) then setdigits(3)
	elseif (interface.levelnum == 2) then setdigits(7)
	elseif (interface.levelnum == 3) then setdigits(2)
	elseif (interface.levelnum == 4) then setdigits(2)
	elseif (interface.levelnum == 5) then setdigits(2)
	elseif (interface.levelnum == 6) then -- nothing to do
	end
	send_input(":P1", 0x80000000, 0.2) -- Enter
	send_input(":P4", 0x80000000, 0.2) -- Menu
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(5) -- boot time

	interface.cur_level = ""
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":P5", 0x80000000, 1)
end

function interface.is_selected(x, y)
	local xval = machine:outputs():get_indexed_value("led", 8 + (x - 1)) == 0
	local yval = machine:outputs():get_indexed_value("led", (y - 1)) == 0
	return xval and yval
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "10 sec/move"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local temp = string.upper(value)
		interface.levelnum = 0
		if ((string.match(temp,"%d%d?%d?%s+SEC/MOVE")) or (string.match(temp,"%d%d?%d?%s+SE[KC]/ZUG"))) then
			if (temp:sub(3,3) == " ") then
				value = "0" .. value
			elseif (temp:sub(2,2) == " ") then
				value = "00" .. value
			end
			interface.levelnum = 1
		elseif ((string.match(temp,"%d%d/%d:[0-5]%d%s+MOVES/HRS")) or (string.match(temp,"%d%d/%d:[0-5]%d%s+Z[Üü]GE/STD"))) then
			interface.levelnum = 2
		elseif ((string.match(temp,"%d%d?%s+MIN/GAME")) or (string.match(temp,"%d%d?%s+MIN/PARTIE"))) then
			if (temp:sub(2,2) == " ") then
				value = "0" .. value
			end
			interface.levelnum = 3
		elseif ((string.match(temp,"%d%d?%s+PLY")) or (string.match(temp,"%d%d?%s+HALBZUG"))) then
			if (temp:sub(2,2) == " ") then
				value = "0" .. value
			end
			interface.levelnum = 4
		elseif ((string.match(temp,"%d%d?%s+MATE")) or (string.match(temp,"%d%d?%s+MATT"))) then
			if (temp:sub(2,2) == " ") then
				value = "0" .. value
			end
			interface.levelnum = 5
		elseif ((string.match(temp,"ANALYSIS")) or (string.match(temp,"ANALYSE"))) then
			interface.levelnum = 6
		end
		if (interface.levelnum ~= 0) then
			interface.level = value
			interface.setlevel()
		end
	end
end

function interface.get_promotion(x, y)
	local ddram = emu.item(machine.devices[':maincpu']:owner().items['0/m_vram']):read_block(0x00, 0x100)

	-- LCD symbols used to represent chess pieces
	if     (ddram:byte(5 + 1) == 0x4d and ddram:byte(5 + 2) == 0x63 and ddram:byte(5 + 3) == 0x7f and ddram:byte(5 + 4) == 0x63 and ddram:byte(5 + 5) == 0x4d) then	return 'q'
	elseif (ddram:byte(5 + 1) == 0x4c and ddram:byte(5 + 2) == 0x67 and ddram:byte(5 + 3) == 0x6f and ddram:byte(5 + 4) == 0x67 and ddram:byte(5 + 5) == 0x4c) then	return 'r'
	elseif (ddram:byte(5 + 1) == 0x40 and ddram:byte(5 + 2) == 0x47 and ddram:byte(5 + 3) == 0x2f and ddram:byte(5 + 4) == 0x47 and ddram:byte(5 + 5) == 0x40) then	return 'b'
	elseif (ddram:byte(5 + 1) == 0x46 and ddram:byte(5 + 2) == 0x6c and ddram:byte(5 + 3) == 0x7d and ddram:byte(5 + 4) == 0x6f and ddram:byte(5 + 5) == 0x47) then	return 'n'
	end

	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	if     (piece == "q") then	send_input(":P4", 0x40000000, 1)
	elseif (piece == "r") then	send_input(":P3", 0x40000000, 1)
	elseif (piece == "b") then	send_input(":P2", 0x40000000, 1)
	elseif (piece == "n") then	send_input(":P1", 0x40000000, 1)
	end
end

return interface
