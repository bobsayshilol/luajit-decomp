
function test(a)
	b0 = a.x + a.y
	c0 = a.x - a.y
	d0 = a.x * a.y
	e0 = a.x / a.y
	f0 = a.x ^ a.y
	g0 = a.x % a.y

	b1 = a.x + 1
	c1 = a.x - 3
	d1 = a.x * 5
	e1 = a.x / 7
	f1 = a.x ^ 9
	g1 = a.x % 11

	b2 = 13 + a.y
	c2 = 15 - a.y
	d2 = 17 * a.y
	e2 = 19 / a.y
	f2 = 21 ^ a.y
	g2 = 23 % a.y

	a.z = not a.z
end

local a = {}
a.x = 1
a.y = 2
a.z = false
test(a)
