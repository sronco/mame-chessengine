-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}
interface.invert = false
interface.level = "a1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = tostring(tonumber(interface.level:sub(2, 2)))
	send_input(":IN.0", 0x02, 1)  -- Level
	emu.wait(0.5)

	local invert = interface.invert
	interface.invert = false
	local clevx = -1
	local clevy = -1
	for cy=1,8 do
		for cx=1,8 do
			if (interface.is_selected(cx, cy)) then
				clevx = cx
				clevy = cy
				break
			end
		end
	end
	if (clevx < 0 or clevy < 0) or (clevx == x and clevy == y) then
		return
	end

	repeat
		if not interface.is_selected(x, y) then
			if (clevx * 8 + clevy < x * 8 + y) then
				send_input(":IN.5", 0x01, 1) -- +
			else
				send_input(":IN.4", 0x04, 1) -- -
			end
		end
	until interface.is_selected(x, y)

	interface.invert = invert
	emu.wait(0.5)
	send_input(":IN.7", 0x04, 1) -- Normal
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
	emu.wait(15)
	send_input(":IN.1", 0x04, 1)	-- New Game
	emu.wait(1)

	interface.cur_level = ""
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		sb_rotate_board(":board")
		interface.invert = true
	end
	send_input(":IN.4", 0x01, 1)	-- Play
end

function interface.is_selected(x, y)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	local xval0 = machine:outputs():get_indexed_value("4.", x - 1) ~= 0
	local xval1 = machine:outputs():get_indexed_value("5.", x - 1) ~= 0
	local yval0 = machine:outputs():get_indexed_value("2.", y - 1) ~= 0
	local yval1 = machine:outputs():get_indexed_value("3.", y - 1) ~= 0
	return (xval0 or xval1) and (yval0 or yval1)
end

function interface.select_piece(x, y, event)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	sb_select_piece(":board", 1, x, y, event)
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
	if     (machine:outputs():get_value("0.6") ~= 0 or machine:outputs():get_value("1.6") ~= 0) then	return 'q'
	elseif (machine:outputs():get_value("0.5") ~= 0 or machine:outputs():get_value("1.5") ~= 0) then	return 'r'
	elseif (machine:outputs():get_value("0.4") ~= 0 or machine:outputs():get_value("1.4") ~= 0) then	return 'b'
	elseif (machine:outputs():get_value("0.3") ~= 0 or machine:outputs():get_value("1.3") ~= 0) then	return 'n'
	end
	return nil
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	-- TODO
end

return interface
