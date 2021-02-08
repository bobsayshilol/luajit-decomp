
function test(a)
	b0 = a.x + a.y
	c0 = a.x - a.y
	d0 = a.x * a.y
	e0 = a.x / a.y
	f0 = a.x ^ a.y
	g0 = a.x % a.y

	b1 = a.x + 3
	c1 = a.x - 3
	d1 = a.x * 3
	e1 = a.x / 3
	f1 = a.x ^ 3
	g1 = a.x % 3

	b2 = 3 + a.y
	c2 = 3 - a.y
	d2 = 3 * a.y
	e2 = 3 / a.y
	f2 = 3 ^ a.y
	g2 = 3 % a.y

	a.z = not a.z
end

local a = {}
a.x = 1
a.y = 2
a.z = false
test(a)
