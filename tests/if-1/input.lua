
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

	if f() then
		c = 1
	elseif g() then
		c = 2
	elseif (h() and i()) or j() then
		c = 3
	elseif h() and (i() or j()) then
		c = 3
	end
end

test(100)
