
function test(a)
	a.x = 1
	a.y = 2
	a.z = a.x + a.y
end

local a = {}
test(a)
