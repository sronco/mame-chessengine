-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

local exports = {}
exports.name = "chessengine"
exports.version = "0.0.1"
exports.description = "Chess UCI/XBoard Interface plugin"
exports.license = "The BSD 3-Clause License"
exports.author = { name = "Sandro Ronco" }


local plugin_path = ""
local protocol = ""
local co = nil
local conth = nil
local interface = nil
local board = nil
local game_started = false
local sel_started = false
local piece_get = false
local my_color = "B"
local ply = "W"
local piece_from = nil
local piece_to = nil
local scr = [[
	while true do
		_G.status = io.stdin:read("*line")
		yield()
	end
]]

local function describe_system()
	return manager:machine():system().description .. " (" .. emu.app_name() .. " " .. emu.app_version() .. ")"
end

local function board_reset()
	game_started = false
	piece_get = false
	sel_started = false
	ply = "W"
	piece_from = nil
	piece_to = nil

	board = {{ 3, 5, 4, 2, 1, 4, 5, 3 },
		{  6, 6, 6, 6, 6, 6, 6, 6 },
		{  0, 0, 0, 0, 0, 0, 0, 0 },
		{  0, 0, 0, 0, 0, 0, 0, 0 },
		{  0, 0, 0, 0, 0, 0, 0, 0 },
		{  0, 0, 0, 0, 0, 0, 0, 0 },
		{ -6,-6,-6,-6,-6,-6,-6,-6 },
		{ -3,-5,-4,-2,-1,-4,-5,-3 }}

	if interface.setup_machine then
		interface.setup_machine()
	end
end

local function move_to_pos(move)
	local rows_idx = { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8 }
	local x = rows_idx[move:sub(1, 1)]
	local y = tonumber(move:sub(2, 2))
	return {x = x, y = y}
end

local function promote_pawn(pos, piece)
	local sign = 1
	if board[pos.y][pos.x] < 0 then
		sign = -1
	end

	if     (piece == "q") then	board[pos.y][pos.x] = board[pos.y][pos.x] - (4 * sign)
	elseif (piece == "r") then	board[pos.y][pos.x] = board[pos.y][pos.x] - (3 * sign)
	elseif (piece == "b") then	board[pos.y][pos.x] = board[pos.y][pos.x] - (2 * sign)
	elseif (piece == "n") then	board[pos.y][pos.x] = board[pos.y][pos.x] - (1 * sign)
	end

	if interface.promote then
		emu.wait(0.5)
		interface.promote(piece.x, piece.y, piece)
	end
end

local function send_input(tag, mask, seconds)
	manager:machine():ioport().ports[tag]:field(mask):set_value(1)
	emu.wait(seconds * 2 / 3)
	manager:machine():ioport().ports[tag]:field(mask):set_value(0)
	emu.wait(seconds * 1 / 3)
end

local function recv_cmd()
	if conth.yield then
		local result = conth.result
		conth:continue("")
		return result
	end
	return nil
end

local function send_cmd(cmd)
	io.stdout:write(cmd .. "\n")
	io.stdout:flush()
end

local function make_move(move, reason)
	local from = move_to_pos(move:sub(1, 2))
	local to = move_to_pos(move:sub(3, 4))

	if interface.select_piece then
		if not piece_get then
			interface.select_piece(from.x, from.y, "get" .. reason)
			emu.wait(0.5)
		end
		if board[to.y][to.x] ~= 0 then
			interface.select_piece(to.x, to.y, "capture")
			emu.wait(0.5)
		end

		interface.select_piece(to.x, to.y, "put" .. reason)
		emu.wait(0.5)
	end

	piece_get = false
	sel_started = false

	-- castling
	if     (board[from.y][from.x] ==  1 and move == "e1g1") then make_move("h1f1", "_castling")
	elseif (board[from.y][from.x] ==  1 and move == "e1c1") then make_move("a1d1", "_castling")
	elseif (board[from.y][from.x] == -1 and move == "e8g8") then make_move("h8f8", "_castling")
	elseif (board[from.y][from.x] == -1 and move == "e8c8") then make_move("a8d8", "_castling")
	else
		-- next ply
		if (ply == "W") then
			ply = "B"
		else
			ply = "W"
		end
	end

	-- en passant
	if board[to.y][to.x] == 0 and board[from.y][from.x] == -6 and from.y == 4 and to.y == 3 and from.x ~= to.x and board[to.y + 1][to.x] == 6 then
		if interface.select_piece  then
			interface.select_piece(to.x, to.y + 1, "en_passant")
			emu.wait(0.5)
		end
		board[to.y + 1][to.x] = 0
	elseif board[to.y][to.x] == 0 and board[from.y][from.x] == 6  and from.y == 5 and to.y == 6 and from.x ~= to.x and board[to.y - 1][to.x] == -6 then
		if interface.select_piece then
			interface.select_piece(to.x, to.y - 1, "en_passant")
			emu.wait(0.5)
		end
		board[to.y - 1][to.x] = 0
	end

	board[to.y][to.x] = board[from.y][from.x]
	board[from.y][from.x] = 0

	-- promotion
	if (move:len() >= 5) then
		promote_pawn(to, move:sub(move:len()))
	end
end

local function search_selected_piece()
	local active_fpos = 0
	local active_tpos = 0
	for y=1,8 do
		for x=1,8 do
			if interface.is_selected and interface.is_selected(x, y) then
				if piece_from ~= nil and (board[y][x] == 0 or (board[y][x] < 0 and ply == "W") or (board[y][x] > 0 and ply == "B")) then
					piece_to = {x = x, y = y}
					active_tpos = active_tpos + 1
				elseif (board[y][x] < 0 and ply == "B") or (board[y][x] > 0 and ply == "W") then
					piece_from = {x = x, y = y}
					active_fpos = active_fpos + 1
				end
			end
		end
	end

	-- If there are more than 2 selections, something is wrong
	if active_tpos > 1 or active_fpos > 1 or (piece_from ~= nil and piece_to ~= nil and piece_from.x == piece_to.x and piece_from.y == piece_to.y) then
		piece_from = nil
		piece_to = nil
	end

	-- in some systems LEDs flash for a bit after the search is completed, wait for 1 second should allow thing to stabilize
	if (not sel_started and (piece_from or piece_to)) then
		sel_started = true
		emu.wait(1)
		piece_from = nil
		piece_to = nil
	end

	if not piece_get and piece_from ~= nil then
		piece_get = true
		if interface.select_piece then
			interface.select_piece(piece_from.x, piece_from.y, "get")
			emu.wait(0.5)
		end
	end

	if piece_to ~= nil and piece_from ~= nil then
		local rows = { "a", "b", "c", "d", "e", "f", "g", "h" }
		local move = rows[piece_from.x] .. tostring(piece_from.y)
		move = move .. rows[piece_to.x] .. tostring(piece_to.y)

		-- promotion
		if (piece_to.y == 8 and board[piece_from.y][piece_from.x] == 6) or (piece_to.y == 1 and board[piece_from.y][piece_from.x] == -6) then
			local new_type = "q"	-- default to Queen
			if interface.get_promotion then
				new_type = interface.get_promotion()
			end

			move = move .. new_type
		end

		if (protocol == "xboard") then
			send_cmd("move " .. move)
		elseif (protocol == "uci") then
			send_cmd("bestmove " .. move)
		end

		make_move(move, "")
	end
end

local function execute_uci_command(cmd)
	if cmd == "uci" then
		protocol = cmd
		send_cmd("uciok")
	elseif cmd == "isready" then
		send_cmd("id name " .. describe_system())
		board_reset()
		send_cmd("readyok")
	elseif cmd == "ucinewgame" then
		if game_started == true then
			manager:machine():soft_reset()
			board_reset()
		end
	elseif cmd == "quit" then
		manager:machine():exit()
	elseif cmd:match("^go") ~= nil then
		if game_started == false then
			game_started = true
			sel_started = false
			my_color = "W"
			if interface.start_play then
				interface.start_play()
			end
		end
	elseif cmd:match("^position startpos moves") ~= nil then
		game_started = true
		local last_move = ""
		for i in string.gmatch(cmd, "%S+") do
			last_move = i
		end
		make_move(last_move, "")
		piece_from = nil
		piece_to = nil
	else
		manager:machine():logerror("Unhandled UCI command '" .. cmd .. "'")
	end
end

local function execute_xboard_command(cmd)
	if cmd == "xboard" then
		protocol = cmd
	elseif cmd:match("^protover") then
		send_cmd("feature done=0")
		send_cmd("feature myname=\"" .. describe_system() .. "\"")
		send_cmd("feature done=1")
		board_reset()
	elseif cmd == "new" then
		if game_started == true then
			manager:machine():soft_reset()
		end
		board_reset()
	elseif cmd == "white" then
		my_color = "W"
		if game_started == false and ply == my_color then
			sel_started = false
			if interface.start_play then
				interface.start_play()
			end
		end
	elseif cmd == "black" then
		my_color = "B"
		if game_started == false and ply == my_color then
			sel_started = false
			if interface.start_play then
				interface.start_play()
			end
		end
	elseif cmd == "quit" then
		manager:machine():exit()
	elseif cmd:match("^[abcdefgh][12345678][abcdefgh][12345678]") ~= nil then
		game_started = true
		make_move(cmd, "")
		piece_from = nil
		piece_to = nil
		sel_started = false
	else
		manager:machine():logerror("Unhandled xboard command '" .. cmd .. "'")
	end
end

local function update()
	repeat
		local command = recv_cmd()
		if (command ~= nil) then
			if (command == "uci" or command == "xboard") then
				protocol = command
			end

			if protocol == "uci" then
				execute_uci_command(command)
			elseif protocol == "xboard" then
				execute_xboard_command(command)
			end
		end
	until command == nil

	-- search for a new move
	if ply == my_color then
		search_selected_piece()
	end
end

local function load_interface(name)
	local env = { machine = manager:machine(), send_input = send_input, load_interface = load_interface, emu = emu,
			pairs = pairs, ipairs = ipairs, tostring = tostring, tonumber = tonumber, print = emu.print_debug }

	local func = loadfile(plugin_path .. "/interfaces/" .. name .. ".lua", "t", env)
	if func then
		return func()
	end
	return nil
end

function exports.set_folder(path)
	plugin_path = path
end

function exports.startplugin()
	conth = emu.thread()
	conth:start(scr)

	emu.register_periodic(
	function()
		if ((co == nil or coroutine.status(co) == "dead") and not manager:machine().paused) then
			co = coroutine.create(update)
			coroutine.resume(co)
		end
	end)

	emu.register_start(
	function()
		local system = manager:machine():system().name
		interface = load_interface(system)

		if interface == nil and manager:machine():system().parent ~= nil then
			interface = load_interface(manager:machine():system().parent)
		end

		if interface == nil then
			interface = {}
			emu.print_error("Error: missing interface for " .. system)
		end
	end)

	emu.register_stop(
	function()

	end)
end

return exports
