function func_1(...)
local_var_0 = a + UNKNOWN_NUMBER --[[ inspect the lua file for this value ]]
a = local_var_0
return
end

function func_8(...)
local_var_0 = 1
a = local_var_0
local TODO_GLOBAL_1 = function() end -- new function, value unknown
test = TODO_GLOBAL_1
test()
return
end

