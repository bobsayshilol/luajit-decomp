function func_1(...)
local_var_2 = #input_var_0
local_cmp_result = local_var_2 ~= TODO_NUMBER
if local_cmp_result then goto label_13 end -- 2
local_cmp_result = input_var_0[1] == TODO_NUMBER
if local_cmp_result then goto label_10 end -- 3
local_var_3 = false
if local_cmp_result then goto label_11 end -- 4
::label_10::
local_var_3 = true
::label_11::
assert(local_var_3)
if local_cmp_result then goto label_26 end -- 2
::label_13::
local_var_2 = #input_var_1
local_cmp_result = local_var_2 ~= TODO_NUMBER
if local_cmp_result then goto label_22 end -- 2
local_var_2 = f(input_var_1[1], input_var_1[2])
input_var_1[3] = local_var_2
if local_cmp_result then goto label_26 end -- 2
::label_22::
local_all_outputs = f()
assert(local_all_outputs)
::label_26::
return
end

function func_33(...)
local TODO_GLOBAL_0 = function() end -- new function, value unknown
test = TODO_GLOBAL_0
return
end

