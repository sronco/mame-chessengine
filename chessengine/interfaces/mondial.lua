-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = load_interface("mondial2")

function interface.start_play(init)
	send_input(":KEY.0", 0x01, 1) -- PLAY
end

return interface
