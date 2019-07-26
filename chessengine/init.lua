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
local prev_move = nil
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
	my_color = "B"
	ply = "W"
	piece_from = nil
	piece_to = nil
	prev_move = nil

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

local function promote_pawn(pos, piece, promotion)
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
		if promotion then
			interface.promote(pos.x, pos.y, string.lower(piece))
		else
			interface.promote(pos.x, pos.y, string.upper(piece))
		end
	end
end

local function send_input(tag, mask, seconds)
	manager:machine():ioport().ports[tag]:field(mask):set_value(1)
	emu.wait(seconds * 2 / 3)
	manager:machine():ioport().ports[tag]:field(mask):set_value(0)
	emu.wait(seconds * 1 / 3)
end

local function sb_set_ui(tag, mask, state)
	local field = manager:machine():ioport().ports[tag .. ":UI"]:field(mask)
	if (field ~= nil) then
		field:set_value(state)
		emu.wait(0.5)
	end
end

local function sb_press_square(tag, seconds, x, y)
	sb_set_ui(tag, 0x0001, 1)
	send_input(tag .. ":RANK." .. tostring(y), 1 << (x - 1), seconds)
	sb_set_ui(tag, 0x0001, 0)
end

local function sb_promote(tag, x, y, piece)
	local mask = 0
	if     (string.lower(piece) == 'q') then	mask = 0x10
	elseif (string.lower(piece) == 'r') then	mask = 0x08
	elseif (string.lower(piece) == 'b') then	mask = 0x04
	elseif (string.lower(piece) == 'n') then	mask = 0x02
	end

	if board[y][x] < 0 or (board[y][x] == 0 and y == 8) then
		mask = mask << 6
	end

	send_input(tag .. ":SPAWN", mask, 0.09)
	if (manager:machine():outputs():get_value("piece_ui0") ~= 0) then
		sb_set_ui(tag, 0x0002, 1)
		send_input(tag .. ":RANK." .. tostring(y), 1 << (x - 1), 0.09)
		sb_set_ui(tag, 0x0002, 0)
	end
end

local function sb_remove_piece(tag, x, y)
	sb_set_ui(tag, 0x0002, 1)
	send_input(tag .. ":RANK." .. tostring(y), 1 << (x - 1), 0.09)
	sb_set_ui(tag, 0x0002, 0)
	send_input(tag .. ":UI", 0x0008, 0.09)	-- SensorBoard REMOVE
end

local function sb_select_piece(tag, seconds, x, y, event)
	if (event ~= "capture") then
		send_input(tag .. ":RANK." .. tostring(y), 1 << (x - 1), seconds)
	end
	if (event == "en_passant") then
		send_input(tag .. ":UI", 0x0008, seconds)	-- SensorBoard REMOVE
	end
end

local function sb_move_piece(tag, x, y)
	sb_set_ui(tag, 0x0002, 1)
	sb_select_piece(tag, 0.09, x, y, "")
	sb_set_ui(tag, 0x0002, 0)
end

local function sb_reset_board(tag)
	send_input(tag .. ":UI", 0x0200, 0.09)	-- SensorBoard RESET
end

local function sb_rotate_board(tag)
	sb_set_ui(tag, 0x0002, 1)
	send_input(tag .. ":UI", 0x0200, 0.09)	-- SensorBoard RESET
	sb_set_ui(tag, 0x0002, 0)
end

local function get_piece_id(x, y)
	if (board ~= nil) then
		return board[y][x]
	end
	return 0
end

local function get_move_type(fx, fy, tx, ty)
	if (fy == 1 and fx == 5 and ty == 1 and (tx == 3 or tx == 7) and get_piece_id(fx, fy) == 1) or
	   (fy == 8 and fx == 5 and ty == 8 and (tx == 3 or tx == 7) and get_piece_id(fx, fy) == -1) then
		return "castling"

	elseif (fx ~= tx and fy == 5 and ty == 6 and get_piece_id(fx, fy) == 6 and get_piece_id(tx, ty) == 0) or
	       (fx ~= tx and fy == 4 and ty == 3 and get_piece_id(fx, fy) == -6 and get_piece_id(tx, ty) == 0) then
		return "en_passant"

	elseif (get_piece_id(fx, fy) == 6 and ty == 8) or (get_piece_id(fx, fy) == -6 and ty == 1) then
		if (get_piece_id(tx, ty) ~= 0) then
			return "capture_promotion"
		else
			return "promotion"
		end

	elseif (get_piece_id(tx, ty) ~= 0) then
		return "capture"
	end

	return nil
end

local function recv_cmd()
	if conth.yield then
		return conth.result
	end
	return nil
end

local function send_cmd(cmd)
	io.stdout:write(cmd .. "\n")
	io.stdout:flush()
end

local function send_move(move)
	prev_move = move
	if (protocol == "xboard") then
		send_cmd("move " .. move)
	elseif (protocol == "uci") then
		send_cmd("bestmove " .. move)
	end
end

local function make_move(move, reason, promotion)
	local from = move_to_pos(move:sub(1, 2))
	local to = move_to_pos(move:sub(3, 4))

	if interface.select_piece then
		if not piece_get then
			interface.select_piece(from.x, from.y, "get" .. reason)
			emu.wait(0.5)
		end
		if board[to.y][to.x] ~= 0 then
			interface.select_piece(to.x, to.y, "capture")
		end

		interface.select_piece(to.x, to.y, "put" .. reason)
	end

	piece_get = false
	sel_started = false

	-- castling
	if     (board[from.y][from.x] ==  1 and move == "e1g1") then make_move("h1f1", "_castling", false)
	elseif (board[from.y][from.x] ==  1 and move == "e1c1") then make_move("a1d1", "_castling", false)
	elseif (board[from.y][from.x] == -1 and move == "e8g8") then make_move("h8f8", "_castling", false)
	elseif (board[from.y][from.x] == -1 and move == "e8c8") then make_move("a8d8", "_castling", false)
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
		promote_pawn(to, move:sub(move:len()), promotion)
	end
end

local function search_selected_piece()
	local active_fpos = 0
	local active_tpos = 0
	local board_sel = {}
	if (interface.is_selected) then
		for y=1,8 do
			for x=1,8 do
				board_sel[y*8 + x] = interface.is_selected(x, y)
				if board_sel[y*8 + x] and ((board[y][x] < 0 and ply == "B") or (board[y][x] > 0 and ply == "W")) then
					piece_from = {x = x, y = y}
					active_fpos = active_fpos + 1
				end
			end
		end
		if (piece_from ~= nil) then
			for y=1,8 do
				for x=1,8 do
					if board_sel[y*8 + x] and (board[y][x] == 0 or (board[y][x] < 0 and ply == "W") or (board[y][x] > 0 and ply == "B")) then
						piece_to = {x = x, y = y}
						active_tpos = active_tpos + 1
					end
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

	if not piece_get and piece_from ~= nil and piece_to == nil then
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
		local need_promotion = (piece_to.y == 8 and board[piece_from.y][piece_from.x] == 6) or (piece_to.y == 1 and board[piece_from.y][piece_from.x] == -6)

		-- promotion
		if (need_promotion) then
			local new_type = "q"	-- default to Queen
			if interface.get_promotion then
				new_type = interface.get_promotion(piece_to.x, piece_to.y)
			end

			if (new_type ~= nil) then
				move = move .. new_type
				need_promotion = false
				send_move(move)
			end
		else
			send_move(move)
		end

		make_move(move, "", false)

		-- some machines show the promotion only after the pawn has been moved
		if (need_promotion) then
			local new_type = nil
			if interface.get_promotion then
				new_type = interface.get_promotion(piece_to.x, piece_to.y)
			end

			if (new_type == nil) then
				manager:machine():logerror(manager:machine():system().name .. " Unable to determine the promotion")
				new_type = "q"	-- default to Queen
			end

			promote_pawn(piece_to, new_type, false)
			move = move .. new_type
			send_move(move)
		end
	end
end

local function send_options()
	local tag_default = ""
	local tag_min = " "
	local tag_max = " "

	if (protocol == "uci") then
		tag_default = "default "
		tag_min = " min "
		tag_max = " max "
	end

	for idx,opt in ipairs(interface.get_options()) do
		local opt_data = nil
		if     (#opt == 3 and opt[1] == "string") then    opt_data = tag_default .. tostring(opt[3])
		elseif (#opt == 2 and opt[1] == "button") then    opt_data = ''
		elseif (#opt == 5 and opt[1] == "spin")   then    opt_data = tag_default .. tostring(opt[3]) .. tag_min .. tostring(opt[4]) .. tag_max .. tostring(opt[5])
		elseif (#opt == 3 and opt[1] == "check")  then
			if protocol == "uci" then
				opt_data = tag_default .. tostring(opt[3]:gsub("1", "true"):gsub("0", "false"))
			elseif protocol == "xboard" then
				opt_data = tag_default .. tostring(opt[3])
			end
		elseif (#opt == 4 and opt[1] == "combo")  then
			if protocol == "uci" then
				opt_data = tag_default .. tostring(opt[3]) .. " var " .. tostring(opt[4]):gsub("\t", " var ")
			elseif protocol == "xboard" then
				opt_data = tostring(opt[4]):gsub("%f[%w_]" .. tostring(opt[3]) .. "%f[^%w_]", "*" .. tostring(opt[3])):gsub("\t", " /// ")
			end
		end
		if (opt_data ~= nil) then
			if protocol == "uci" then
				send_cmd('option name ' .. tostring(opt[2])  .. ' type ' .. tostring(opt[1]) .. ' ' .. opt_data)
			elseif protocol == "xboard" then
				send_cmd('feature option="' .. tostring(opt[2])  .. ' -' .. tostring(opt[1]) .. ' ' .. opt_data .. '"')
			end
		else
			manager:machine():logerror("Invalid interface options '" .. tostring(opt[1]) .. " " .. tostring(opt[2]) .. "'")
		end
	end
end

local function set_option(name, value)
	if (name == nil or value == nil) then
		return
	end

	if (string.lower(name) == "speed") then
		if (tonumber(value) == 0) then	-- 0 = unlimited
			manager:machine():video().throttled = false
		else
			manager:machine():video().throttled = true
			manager:machine():video().throttle_rate = tonumber(value) / 100.0
		end
	elseif (interface.set_option) then
		interface.set_option(string.lower(name), value)
	end
end

local function execute_uci_command(cmd)
	if cmd == "uci" then
		protocol = cmd
		send_cmd("id name " .. describe_system())
		send_cmd("option name Speed type spin default 100 min 0 max 10000")
		if interface.get_options then
			send_options()
		end
		send_cmd("uciok")
	elseif cmd == "isready" then
		send_cmd("readyok")
	elseif cmd == "ucinewgame" then
		if game_started == true then
			game_started = false
			manager:machine():soft_reset()
		end
		board_reset()
	elseif cmd == "quit" then
		manager:machine():exit()
	elseif cmd:match("^go") ~= nil then
		if board == nil then
			board_reset()
		end
		if game_started == false or my_color ~= ply then
			if interface.start_play then
				interface.start_play(not game_started)
			end
			my_color = ply
			game_started = true
			sel_started = false
		end
	elseif cmd:match("^setoption name ") ~= nil then
		local opt_name, opt_val = string.match(cmd:sub(16), '(.+) value (.+)')
		if     (string.lower(opt_val) == "true" ) then opt_val = "1"
		elseif (string.lower(opt_val) == "false") then opt_val = "0"
		end
		set_option(opt_name, opt_val)
	elseif cmd:match("^position startpos moves") ~= nil then
		if board == nil then
			board_reset()
		end
		game_started = true
		local last_move = ""
		for i in string.gmatch(cmd, "%S+") do
			last_move = i
		end
		if (last_move == prev_move) then
			my_color = ply
			sel_started = false
			if interface.start_play then
				interface.start_play(not game_started)
			end
		else
			make_move(last_move, "", true)
			piece_from = nil
			piece_to = nil
			sel_started = false
		end
	elseif cmd == "stop" then
		if game_started == true then
			if interface.stop_play then
				interface.stop_play()
			elseif interface.start_play then
				interface.start_play(not game_started)
			end
		end
	else
		manager:machine():logerror("Unhandled UCI command '" .. cmd .. "'")
	end
end

local function execute_xboard_command(cmd)
	if cmd == "xboard" then
		protocol = cmd
	elseif cmd:match("^protover") then
		send_cmd("feature done=0")
		send_cmd("feature myname=\"" .. describe_system() .. "\" colors=0 usermove=1 sigint=0 sigterm=0")
		send_cmd('feature option="Speed -spin 100 0 10000"')
		if interface.get_options then
			send_options()
		end
		send_cmd("feature done=1")
	elseif cmd == "new" then
		if game_started == true then
			game_started = false
			manager:machine():soft_reset()
		end
		board_reset()
	elseif cmd == "go" then
		if (board == nil) then
			board_reset()
		end
		sel_started = false
		if game_started == false or my_color ~= ply then
			if interface.start_play then
				interface.start_play(not game_started)
			end
			game_started = true
			my_color = ply
		end
	elseif (cmd == "?") then
		if interface.stop_play then
			interface.stop_play()
		elseif interface.start_play then
			interface.start_play(not game_started)
		end
	elseif cmd == "quit" then
		manager:machine():exit()
	elseif cmd:match("^option ") ~= nil then
		local opt_name, opt_val = string.match(cmd:sub(8), '([^=]+)=([^=]+)')
		set_option(opt_name, opt_val)
	elseif cmd:match("^usermove ") ~= nil then
		if board == nil then
			board_reset()
		end
		game_started = true
		make_move(cmd:sub(10), "", true)
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

			conth:continue(conth.result)
			emu.wait(0.1)
		end
	until command == nil

	-- search for a new move
	if ply == my_color then
		search_selected_piece()
	end
end

local function load_interface(name)
	local env = { machine = manager:machine(), send_input = send_input, get_piece_id = get_piece_id, get_move_type = get_move_type, load_interface = load_interface, emu = emu,
			sb_select_piece = sb_select_piece, sb_move_piece = sb_move_piece, sb_press_square = sb_press_square, sb_promote = sb_promote,
			sb_remove_piece = sb_remove_piece, sb_reset_board = sb_reset_board, sb_rotate_board = sb_rotate_board, sb_set_ui = sb_set_ui,
			pairs = pairs, ipairs = ipairs, tostring = tostring, tonumber = tonumber, string = string, math = math, print = _G.print }

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
		if interface == nil then
			interface = load_interface(system)
		end
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
