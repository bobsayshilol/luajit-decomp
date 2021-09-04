function func_1(...)
-- local_var_0 = {} -- ???
local_all_outputs = {...} -- 1
local_var_0 = local_all_outputs
local_var_1 = 1
-- local_var_2 = {} -- ???
local_all_outputs = {...} -- 3
local_var_2 = local_all_outputs
local_var_4 = local_var_0
local_var_5 = local_var_2
sink(local_var_4, local_var_5)
return
end

function func_16(...)
-- local_var_0 = {} -- ???
local_all_outputs = {...} -- 1
local_var_0 = local_all_outputs
local_var_2 = local_var_0
local_var_1, local_var_2, local_var_3 = ipairs(local_var_2)
if local_cmp_result then goto label_12 end -- 4
::label_8::
local_var_7 = input_var_4
local_var_8 = input_var_5
sink(local_var_7, local_var_8)
::label_12::
-- Unhandled: ITERC
-- Unhandled: ITERL
return
end

function func_34(...)
-- local_var_0 = {} -- ???
local_all_outputs = {...} -- 1
local_var_0 = local_all_outputs
local_var_2 = local_var_0
local_var_1, local_var_2, local_var_3 = pairs(local_var_2)
::label_8::
local_var_7 = input_var_4
local_var_8 = input_var_5
sink(local_var_7, local_var_8)
::label_12::
-- Unhandled: ITERN
-- Unhandled: ITERL
return
end

function func_52(...)
-- local_var_0 = {} -- ???
local_all_outputs = {...} -- 1
local_var_0 = local_all_outputs
local_var_3 = local_var_0
local_all_outputs = unpack(local_var_3)
sink(local_all_outputs)
return
end

function func_65(...)
local_var_2 = 1
local_all_outputs = {...} -- 3
local_var_1 = select(local_var_2, local_all_outputs)
local_var_3 = 2
local_all_outputs = {...} -- 4
local_var_2 = select(local_var_3, local_all_outputs)
local_var_4 = 3
local_all_outputs = {...} -- 5
local_all_outputs = select(local_var_4, local_all_outputs)
sink(local_var_1, local_var_2, local_all_outputs)
return
end

function func_84(...)
local TODO_GLOBAL_0 = function() end -- new function, value unknown
test1 = TODO_GLOBAL_0
local TODO_GLOBAL_2 = function() end -- new function, value unknown
test2 = TODO_GLOBAL_2
local TODO_GLOBAL_4 = function() end -- new function, value unknown
test3 = TODO_GLOBAL_4
local TODO_GLOBAL_6 = function() end -- new function, value unknown
test4 = TODO_GLOBAL_6
local TODO_GLOBAL_8 = function() end -- new function, value unknown
test5 = TODO_GLOBAL_8
return
end

