
function test(a)
	if a * 20 > a then
		a = -10
	end

	if a * 20 > a then
		a = -10
	end

	if a > 100 or a < 0 then
		a = -10
	end

	if b then
		b = a > 20
	else
		b = nil
	end
end

test(100)
