interface = load_interface("ssystem3")

local d0,d1,d2,d3 = 0

function getdigit(n)
	local map
	if     (n == 0) then map = {"1.2","1.1","3.0","3.2","3.3","1.3","1.4"}
	elseif (n == 1) then map = {"0.6","0.5","0.4","2.6","2.7","0.7","1.0"}
	elseif (n == 2) then map = {"0.0","4.4","2.3","2.4","2.5","0.1","0.2"}
	elseif (n == 3) then map = {"4.3","4.7","4.2","4.1","2.2","4.6","4.5"}
	end
	local dig = 0x00
	for i=1,7 do
		if (machine:outputs():get_value(map[i]) ~= 0) then
			dig = dig | (1 << (i-1))
		end
	end
	return dig
end

function interface.is_selected(x, y)
	if (machine:outputs():get_value("3.1") ~= 0) then -- COMPUTING?
		d0,d1,d2,d3 = 0
		return false
	end
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	if (x == 1 and y == 1) then
		d0 = getdigit(0)
		d1 = getdigit(1)
		d2 = getdigit(2)
		d3 = getdigit(3)
	end
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3)
end

return interface
