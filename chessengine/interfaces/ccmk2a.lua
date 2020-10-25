interface = load_interface("ccmk2")

function interface.send_pos2(p)  -- "1" to "8" keys
	if     (p == 1)	then	send_input(":IN.0", 0x20, 0.5)
	elseif (p == 2)	then	send_input(":IN.0", 0x10, 0.5)
	elseif (p == 3)	then	send_input(":IN.0", 0x08, 0.5)
	elseif (p == 4)	then	send_input(":IN.0", 0x04, 0.5)
	elseif (p == 5)	then	send_input(":IN.0", 0x02, 0.5)
	elseif (p == 6)	then	send_input(":IN.0", 0x01, 0.5)
	elseif (p == 7)	then	send_input(":IN.1", 0x40, 0.5)
	elseif (p == 8)	then	send_input(":IN.1", 0x20, 0.5)
	end
end

return interface
