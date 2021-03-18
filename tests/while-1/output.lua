function func_1(...)
::label_1::
local_var_1 = 100
local_cmp_result = input_var_0 >= local_var_1
if local_cmp_result then goto label_8 end -- 1
-- loop start
local_var_1 = UNKNOWN_NUMBER --[[ inspect the lua file for this value ]] * input_var_0
local_var_0 = local_var_1 + 1
if local_cmp_result then goto label_1 end -- 1
::label_8::
return
end

function func_12(...)
local TODO_GLOBAL_0 = function() end -- new function, value unknown
test = TODO_GLOBAL_0
local_var_1 = 1
test(local_var_1)
local_var_1 = 2
test(local_var_1)
return
end

