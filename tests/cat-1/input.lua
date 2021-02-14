function test(a, b, c)
	return a .. b .. c
end

function test2(b, c)
	return "a" .. b .. c
end

function test3(a, c)
	return a .. "b" .. c
end

function test4(a, b)
	return a .. b .. "c"
end

test()
test2()
test3()
test4()
