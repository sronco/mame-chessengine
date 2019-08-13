-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.turn = true
interface.color = "B"
interface.level = "00"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":IN.3", 0x04, 0.5) -- SET
	emu.wait(0.5)
	send_input(":IN.3", 0x08, 0.5) -- CE
	emu.wait(0.5)
	for i=1,interface.level:len() do
		local n = tonumber(interface.level:sub(i,i))
		if (n==0) then
			send_input(":IN.0", 0x01, 0.5)
		elseif (n<=3) then
			send_input(":IN.1", 0x01 << (n-1), 0.5)
		elseif (n<=6) then
			send_input(":IN.2", 0x01 << (n-4), 0.5)
		elseif (n<=9) then
			send_input(":IN.3", 0x01 << (n-7), 0.5)
		end
	end
	send_input(":IN.0", 0x08, 0.5) -- ENTER
	emu.wait(0.5)
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.turn = true
	interface.color = "B"
	send_input(":RESET", 0x01, 0.5) -- RESET
	emu.wait(1.0)

	interface.cur_level = "00"
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		send_input(":IN.0", 0x04, 0.5) -- B/W
	end
	if (interface.color == "W") then
		interface.color = "B"
	else
		interface.color = "W"
	end
	interface.turn = false
	send_input(":IN.0", 0x08, 0.5) -- ENTER
	emu.wait(0.25)
end

function interface.stop_play()
end

function interface.is_selected_int(x, y)
        if (emu.item(machine.devices[':maincpu']:owner().items['0/m_ram_address']):read()~=0x0f) then
              emu.wait(0.5)
              if (emu.item(machine.devices[':maincpu']:owner().items['0/m_ram_address']):read()~=0x0f) then
                      return false
              end
        end
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	local d4 = machine:outputs():get_value("digit4")
	return (d2 == 0x01 or interface.color == "W") and (d2 == 0x08 or interface.color == "B") and ((xval[x] == d0 and yval[y] == d1) or (xval[x] == d3 and yval[y] == d4))
end

function interface.is_selected(x, y)
	if (interface.is_selected_int(x, y)) then
		emu.wait(0.3)
		return interface.is_selected_int(x, y)
	end

	return false
end

function interface.send_pos(p)
	if     (p == 1)	then	send_input(":IN.1", 0x01, 0.5)
	elseif (p == 2)	then	send_input(":IN.1", 0x02, 0.5)
	elseif (p == 3)	then	send_input(":IN.1", 0x04, 0.5)
	elseif (p == 4)	then	send_input(":IN.2", 0x01, 0.5)
	elseif (p == 5)	then	send_input(":IN.2", 0x02, 0.5)
	elseif (p == 6)	then	send_input(":IN.2", 0x04, 0.5)
	elseif (p == 7)	then	send_input(":IN.3", 0x01, 0.5)
	elseif (p == 8)	then	send_input(":IN.3", 0x02, 0.5)
	end
end

function interface.select_piece(x, y, event)
	sb_select_piece(":board", 0.3, x, y, event)
	if (event ~= "capture" and event ~= "get_castling" and event ~= "put_castling" and event ~= "en_passant") then
		if (interface.turn) then
			interface.send_pos(x)
			interface.send_pos(y)
		end

		if (event == "put") then
			if (interface.turn) then
				send_input(":IN.0", 0x08, 0.5) -- ENTER
				emu.wait(0.25)
			end
			interface.turn = not interface.turn
		end
	end
end

function interface.get_options()
	return { { "string", "Level", "00"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
		interface.setlevel()
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	-- TODO
end

return interface
