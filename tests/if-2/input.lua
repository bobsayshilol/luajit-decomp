
function test(x, y)
	if x then f() end
	if not x then f() end

	if x == nil then f() end
	if x ~= nil then f() end
	if not (x == nil) then f() end
	if not (x ~= nil) then f() end

	if x == true then f() end
	if x ~= true then f() end
	if not (x == true) then f() end
	if not (x ~= true) then f() end

	if x == false then f() end
	if x ~= false then f() end
	if not (x == false) then f() end
	if not (x ~= false) then f() end

	if x > y  then f() end
	if x >= y then f() end
	if x < y  then f() end
	if x <= y then f() end
	if x == y then f() end
	if x ~= y then f() end

	if not (x > y)  then f() end
	if not (x >= y) then f() end
	if not (x < y)  then f() end
	if not (x <= y) then f() end
	if not (x == y) then f() end
	if not (x ~= y) then f() end

	if x == 1 then f() end
	if x ~= 2 then f() end
	if x == "a" then f() end
	if x ~= "b" then f() end

	if not (x == 1) then f() end
	if not (x ~= 2) then f() end
	if not (x == "a") then f() end
	if not (x ~= "b") then f() end

	if 1 == x then f() end
	if 2 ~= x then f() end
	if "a" == x then f() end
	if "b" ~= x then f() end

	if not (1 == x) then f() end
	if not (2 ~= x) then f() end
	if not ("a" == x) then f() end
	if not ("b" ~= x) then f() end
end

test()
