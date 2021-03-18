function sink(...) end
function sink2(...) end

function create()
	local counter = 0
	local generator = function()
		counter = counter + 1
		return counter
	end
	return generator
end

local gen = create()
sink(gen())
sink(gen(), gen(), gen() + gen())
sink(sink(gen()))
sink(sink(gen()), gen())
sink(sink(), sink2())
