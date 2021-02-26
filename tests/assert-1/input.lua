
function test(a, b)
	if #a == 1 then
		assert(a[1] == -1)
	elseif #b == 2 then
		b[3] = f(b[1], b[2])
	else
		return assert(f())
	end
end
