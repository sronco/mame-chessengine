-- license:BSD-3-Clause

interface = {}

interface.invert = false
interface.level = "a3"
interface.cur_level = nil

function interface.setlevel()
	if (interface.cur_level == nil or interface.cur_level == interface.level) then
		return
	end
	interface.cur_level = interface.level
	local cols_idx = { a=1, b=2, c=3, d=4 }
	local x = cols_idx[interface.level:sub(1, 1)]
	local y = tonumber(interface.level:sub(2, 2))

	send_input(":IN.5", 0x04, 1)  -- Level
	emu.wait(0.5)

	local clevx = 0
	local clevy = 0
	for cx=1,4 do
		for cy=1,8 do
			local led0 = output:get_value(tostring(cx-1) .. "." .. tostring(cy-1)) ~= 0
			local led3 = output:get_value(tostring(cx) .. "." .. tostring(cy)) ~= 0
			if (led0 and led3) then
				clevx = cx
				clevy = cy
				cx = 4
				cy = 8
			end
		end
	end
	if (clevx > 0 and clevy > 0) and (clevx ~= x or clevy ~= y) then
		local dlev = (x * 8 + y) - (clevx * 8 + clevy)
		local dx = (x - clevx + 4) % 4
		local dy = y - clevy
		if (dlev >= -5 and  dlev <= 4) then
			dx = 0
			dy = dlev
		end
		for i=1,dx do
			send_input(":IN.2", 0x02, 1) -- Tab
		end
		for i=1,math.abs(dy) do
			if (dy > 0) then
				send_input(":IN.2", 0x04, 1) -- +
			else
				send_input(":IN.6", 0x01, 1) -- -
			end
		end
	end

	emu.wait(0.5)
	send_input(":IN.6", 0x02, 1) -- Normal
end

function interface.setup_machine()
	sb_reset_board(":board")
	interface.invert = false
	emu.wait(7)
	send_input(":IN.7", 0x02, 1)	-- New Game
	emu.wait(1)

	interface.cur_level = "a3"
	interface.setlevel()
end

function interface.start_play(init)
	if (init) then
		sb_rotate_board(":board")
		interface.invert = true
	end
	send_input(":IN.5", 0x02, 1)	-- Play
end

function interface.stop_play()
	send_input(":IN.5", 0x02, 1)	-- Play
end

function interface.is_selected(x, y)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	local led0 = output:get_value(tostring(x-1) .. "." .. tostring(y-1)) ~= 0
	local led1 = output:get_value(tostring(x)   .. "." .. tostring(y-1)) ~= 0
	local led2 = output:get_value(tostring(x-1) .. "." .. tostring(y)) ~= 0
	local led3 = output:get_value(tostring(x)   .. "." .. tostring(y)) ~= 0
	return led0 and led1 and led2 and led3
end

function interface.select_piece(x, y, event)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	sb_select_piece(":board", 1, x, y, event)
end

function interface.get_options()
	return { { "string", "Level", "a3"}, }
end

function interface.set_option(name, value)
	if (name == "level" and value ~= "") then
		local level = value:match("^%s*(.-)%s*$"):gsub("%s%s+"," "):lower() -- trim
		if (level:match("[a-d][1-8]")) then
			interface.level = level
			interface.setlevel()
		end
	end
end

local function getpiece()
	local piece = 0x00
	for i=1,7 do
		if (output:get_value("s" .. (i+8) .. ".12") ~= 0) then
			piece = piece | (1 << (i-1))
		end
	end
	return piece
end

function interface.get_promotion(x, y)
	local piece = getpiece()
	if     (piece == 0x3e) then return 'q'
	elseif (piece == 0x3f) then return 'r'
	elseif (piece == 0x36) then return 'b'
	elseif (piece == 0x7c) then return 'n'
	end
	return nil
end

function interface.promote_special(piece)
	if     (piece == "q") then send_input(":IN.1", 0x01, 1)
	elseif (piece == "r") then send_input(":IN.0", 0x02, 1)
	elseif (piece == "b") then send_input(":IN.1", 0x02, 1)
	elseif (piece == "n") then send_input(":IN.0", 0x04, 1)
	end
end

function interface.promote(x, y, piece)
	if interface.invert then
		x = 9 - x
		y = 9 - y
	end
	sb_promote(":board", x, y, piece)
end

return interface
