interface = load_interface("berl32t8p")

interface.level = "TURN 01"
interface.cur_level = nil

function interface.get_options()
	return { { "string", "Level", "TURN 01"}, }
end

return interface
