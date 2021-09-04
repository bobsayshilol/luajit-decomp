
function test1(...)
	local arg = {...}
	local j = 1
	local arg2 = {...}
	sink(arg, arg2)
end

function test2(...)
	local arg = {...}
	for i, v in ipairs(arg) do
		sink(i, v)
	end
end

function test3(...)
	local arg = {...}
	for u, v in pairs(arg) do
		sink(u, v)
	end
end

function test4(...)
	local arg = {...}
	sink(unpack(arg))
end

function test5(...)
	sink(select(1, ...), select(2, ...), select(3, ...))
end
