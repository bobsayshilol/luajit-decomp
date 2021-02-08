local counter1 = 0
local counter2 = 0

function inner()
	counter1 = counter1 + 1
	counter2 = counter2 * 2
end

function outer()
	inner()
	inner()
end

outer()
