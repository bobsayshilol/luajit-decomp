function tester(...)
end

function test(i)
	tester(i)
	tester(i + i)
	tester(i, i, i)
end

test(1)
