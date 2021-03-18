function func_1(...)
local_var_1 = input_var_0.x + input_var_0.y
b0 = local_var_1
local_var_1 = input_var_0.x - input_var_0.y
c0 = local_var_1
local_var_1 = input_var_0.x * input_var_0.y
d0 = local_var_1
local_var_1 = input_var_0.x / input_var_0.y
e0 = local_var_1
local_var_1 = input_var_0.x ^ input_var_0.y
f0 = local_var_1
local_var_1 = input_var_0.x % input_var_0.y
g0 = local_var_1
local_var_1 = input_var_0.x + UNKNOWN_NUMBER --[[ inspect the lua file for this value ]]
b1 = local_var_1
local_var_1 = input_var_0.x - 3
c1 = local_var_1
local_var_1 = input_var_0.x * 5
d1 = local_var_1
local_var_1 = input_var_0.x / 7
e1 = local_var_1
local_var_2 = 9
local_var_1 = input_var_0.x ^ local_var_2
f1 = local_var_1
local_var_1 = input_var_0.x % 11
g1 = local_var_1
local_var_1 = 13 + input_var_5
b2 = local_var_1
local_var_1 = 15 - input_var_6
c2 = local_var_1
local_var_1 = 17 * input_var_7
d2 = local_var_1
local_var_1 = 19 / input_var_8
e2 = local_var_1
local_var_2 = 21
local_var_1 = local_var_2 ^ input_var_0.y
f2 = local_var_1
local_var_1 = 23 % input_var_9
g2 = local_var_1
local_var_1 = not input_var_0.z
input_var_0.z = local_var_1
return
end

function func_99(...)
local TODO_GLOBAL_0 = function() end -- new function, value unknown
test = TODO_GLOBAL_0
local_var_0 = {}
local_var_1 = 1
local_var_0.x = local_var_1
local_var_1 = 2
local_var_0.y = local_var_1
local_var_1 = false
local_var_0.z = local_var_1
local_var_2 = local_var_0
test(local_var_2)
return
end

