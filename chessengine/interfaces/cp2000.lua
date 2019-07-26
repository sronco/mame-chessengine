-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

interface.turn = true
interface.last_get = nil
interface.level = 1
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	send_input(":IN.2", 0x08, 1) -- LEVEL
	if (interface.level <= 4)	then
		send_input(":IN." .. tostring(4-interface.level), 0x01, 1)
	else
		send_input(":IN." .. tostring(8-interface.level), 0x02, 1)
	end
	send_input(":IN.1", 0x04, 1) -- ENTER
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.turn = true
	interface.last_get = nil
	send_input(":IN.3", 0x08, 1) -- NEW GAME

	interface.cur_level = 1
	interface.setlevel()
end

function interface.start_play(init)
	interface.turn = false
	send_input(":IN.1", 0x04, 1) -- ENTER
end

function interface.stop_play()
end

function interface.is_selected_int(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0")
	local d1 = machine:outputs():get_value("digit1")
	local d2 = machine:outputs():get_value("digit2")
	local d3 = machine:outputs():get_value("digit3")
	if (d0 == 0 or d1 == 0) then
		return false
	end
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

function interface.is_selected(x, y)
	if (interface.is_selected_int(x, y)) then
		emu.wait(0.5)
		return interface.is_selected_int(x, y)
	end

	return false
end

function interface.select_piece(x, y, event)
	if (event == "get") then
		interface.last_get = {x=x, y=y}
	elseif (event == "put") then
		local move_type = get_move_type(interface.last_get.x, interface.last_get.y, x, y)

		sb_select_piece(":board", 1, interface.last_get.x, interface.last_get.y, "get")
		sb_select_piece(":board", 1, x, y, "put")

		-- special moves require extra steps
		if (move_type == "castling" and x == 7) then
			sb_select_piece(":board", 1, 8, y, "get")
			sb_select_piece(":board", 1, 6, y, "put")
		elseif (move_type == "castling" and x == 3) then
			sb_select_piece(":board", 1, 1, y, "get")
			sb_select_piece(":board", 1, 4, y, "put")
		elseif (move_type == "en_passant") then
			sb_remove_piece(":board", x, interface.last_get.y)
			sb_press_square(":board", 1, x, interface.last_get.y)
		elseif (move_type == "capture") then
			sb_press_square(":board", 1, x, y)
		end

		if (interface.turn) then
			send_input(":IN.1", 0x04, 1) -- ENTER
		end

		interface.last_get = nil
		interface.turn = not interface.turn
	end
end

function interface.get_options()
	return { { "spin", "Level", "1", "1", "8"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 1 or level > 8) then
			return
		end
		interface.level = level
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
