-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	sb_reset_board(":smartboard:board")
	emu.wait(3)
end

function interface.start_play(init)
	send_input(":IN.0", 0x20, 0.5)	-- PLAY
end

function interface.is_selected(x, y)
	local led0 = machine:outputs():get_value("led_" .. tostring(8 - y) .. tostring(8 - x)) == 1
	local led1 = machine:outputs():get_value("led_" .. tostring(8 - y) .. tostring(9 - x)) == 1
	local led2 = machine:outputs():get_value("led_" .. tostring(9 - y) .. tostring(8 - x)) == 1
	local led3 = machine:outputs():get_value("led_" .. tostring(9 - y) .. tostring(9 - x)) == 1
	return led0 and led1 and led2 and led3
end

function interface.select_piece(x, y, event)
	sb_select_piece(":smartboard:board", 1, x, y, event)
end

function interface.get_promotion(x, y)
	return 'q'	-- TODO
end

function interface.promote(x, y, piece)
	sb_promote(":smartboard:board", x, y, piece)
	local right = -1
	if     (piece == "q") then	right = 0
	elseif (piece == "r") then	right = 1
	elseif (piece == "b") then	right = 2
	elseif (piece == "n") then	right = 3
	end

	if (right ~= -1) then
		for i=1,right do
			send_input(":IN.1", 0x40, 0.5)	-- RIGHT
		end

		send_input(":IN.3", 0x20, 0.5)	-- ENTER
	end
end

return interface
