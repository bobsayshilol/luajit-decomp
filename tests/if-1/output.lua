function func_1(...)
local_var_1 = input_var_0 * TODO_NUMBER
local_cmp_result = input_var_0 >= local_var_1
if local_cmp_result then goto label_5 end -- 1
local_var_0 = 10
::label_5::
local_var_1 = local_var_0 * TODO_NUMBER
local_cmp_result = local_var_0 >= local_var_1
if local_cmp_result then goto label_9 end -- 1
local_var_0 = 10
::label_9::
local_var_1 = 100
local_cmp_result = local_var_1 < local_var_0
if local_cmp_result then goto label_15 end -- 1
local_var_1 = 0
local_cmp_result = local_var_0 >= local_var_1
if local_cmp_result then goto label_16 end -- 1
::label_15::
local_var_0 = 10
::label_16::
local_cmp_result = not b
if local_cmp_result then goto label_27 end -- 2
local_var_1 = 20
local_cmp_result = local_var_1 < local_var_0
if local_cmp_result then goto label_24 end -- 1
local_var_1 = false
if local_cmp_result then goto label_25 end -- 2
::label_24::
local_var_1 = true
::label_25::
b = local_var_1
if local_cmp_result then goto label_29 end -- 1
::label_27::
local_var_1 = nil
b = local_var_1
::label_29::
return
end

function func_33(...)
local TODO_GLOBAL_0 = function() end -- new function, value unknown
test = TODO_GLOBAL_0
local_var_1 = 100
test(local_var_1)
return
end

