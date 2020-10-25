interface = {}

interface.opt_clear_announcements = true
interface.level = "a1"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = interface.level:sub(2, 2)
	send_input(":IN.0", 0x10, 1)  -- LEVEL
	emu.wait(0.5)
	sb_press_square(":board", 1, x, y)
	emu.wait(0.5)
	send_input(":IN.0", 0x01, 1) -- CLEAR
end

function interface.setup_machine()
	sb_reset_board(":board")
	emu.wait(1.0)
	send_input(":IN.0", 0x20, 1) -- OPTION
	emu.wait(1.0)
	sb_press_square(":board", 1, 2, 1) -- b1
	emu.wait(1.0)
	send_input(":IN.0", 0x01, 0.5) -- CLEAR
	emu.wait(1.0)

	interface.cur_level = "a1"
	interface.setlevel()
end

function interface.start_play(init)
	send_input(":IN.0", 0x02, 1) -- MOVE
end

function interface.clear_announcements()
	if (machine:outputs():get_value("9.1") ~= 0) then
		send_input(":IN.0", 0x01, 0.5) -- CLEAR
	end
end

function interface.is_selected(x, y)
	if (interface.opt_clear_announcements and x == 1 and y == 1) then
		interface.clear_announcements()
	end

	return (machine:outputs():get_indexed_value("0.", (y - 1)) ~= 0) and (machine:outputs():get_indexed_value("1.", (x - 1)) ~= 0)
end

function interface.select_piece(x, y, event)
	if (event == "get_castling") then
		emu.wait(1)
	end
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a1"}, { "check", "Clear announcements", "1"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		interface.level = value
		interface.setlevel()
	end
	if (name == "clear announcements") then
		interface.opt_clear_announcements = tonumber(value) == 1
	end
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":board", x, y, piece)
	emu.wait(1.0)
	if     (piece == "q") then	send_input(":IN.0", 0x20, 1)
	elseif (piece == "r") then	send_input(":IN.0", 0x10, 1)
	elseif (piece == "b") then	send_input(":IN.0", 0x8,  1)
	elseif (piece == "n") then	send_input(":IN.0", 0x4,  1)
	end
end

return interface
