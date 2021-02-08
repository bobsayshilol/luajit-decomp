function sink(...) end

function create()
	local counter = 0
	local generator = function()
		counter = counter + 1
		return counter
	end
	return generator
end

local gen = create()
sink(gen(), gen(), gen() + gen())
