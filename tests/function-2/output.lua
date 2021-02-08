function func_1(...)
-- Unhandled: ADDVN
-- Unhandled: USETV
-- Unhandled: MULVN
-- Unhandled: USETV
return
end

function func_11(...)
inner()
inner()
return
end

function func_19(...)
local_var_0 = 0
local TODO_GLOBAL_0 = function() end -- new function, value assigned later
TODO_GLOBAL_0 = inner
local TODO_GLOBAL_2 = function() end -- new function, value assigned later
TODO_GLOBAL_2 = outer
outer()
-- Unhandled: UCLO
return
end

