local counter = 0

function inner()
	counter = counter + 1
	counter = counter * 2
end

function outer()
	inner()
	inner()
end

outer()
