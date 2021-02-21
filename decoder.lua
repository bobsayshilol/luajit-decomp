

local Disassembler = {}
Disassembler.__index = Disassembler


function Disassembler:new(fileOut)
	local o = {}
	o.fileOut = fileOut
	o.lineNo = 0
	o.logIndent = 0
	o.verbose = false
	o.functions = {}
	o.currentFunction = nil
	o.registers = nil
	setmetatable(o, self)
	return o
end


function Disassembler:HandleMaths(op, args, reg)
	assert(#args == 3)
	local o = args[1]
	local a = args[2]
	local b = args[3]

	-- Grab the type
	local strOp
	if op:sub(1, 3) == "ADD" then
		strOp = " + "
	elseif op:sub(1, 3) == "SUB" then
		strOp = " - "
	elseif op:sub(1, 3) == "MUL" then
		strOp = " * "
	elseif op:sub(1, 3) == "DIV" then
		strOp = " / "
	elseif op:sub(1, 3) == "MOD" then
		strOp = " % "
	else
		self:Log("Unknown operation: " .. op)
		return
	end

	-- Use raw numbers if required
	local pick = function(v, t)
		if t == 'V' then
			return assert(reg[v])
		elseif t == 'N' then
			return "TODO_NUMBER"
		else
			self:Log("Unknown operation: " .. op)
			return "INVALID"
		end
	end
	a = pick(a, op:sub(4, 4))
	b = pick(b, op:sub(5, 5))

	reg[o] = "local_var_" .. o
	self:Write(reg[o] .. " = " .. a .. strOp .. b)
end


function Disassembler:HandleIf(op, args, reg, func)
	assert(#args >= 1)
	local a = assert(reg[args[1]])

	-- Build the condition
	local condition
	if op:sub(3) == "T" then
		assert(#args == 1)
		condition = a
	elseif op:sub(3) == "F" then
		assert(#args == 1)
		condition = "not " .. a

	else
		-- Determine the type of operation
		local strOp
		if op:sub(3) == "GE" then
			strOp = " >= "
		elseif op:sub(3) == "GT" then
			strOp = " > "
		elseif op:sub(3) == "LE" then
			strOp = " <= "
		elseif op:sub(3) == "LT" then
			strOp = " < "
		elseif op:sub(3, 4) == "NE" then
			strOp = " ~= "
		elseif op:sub(3, 4) == "EQ" then
			strOp = " == "
		else
			self:Log("Unknown operation: " .. op)
			return
		end

		-- Handle the 2nd arg
		assert(#args == 2)
		local b = args[2]
		if op:sub(3, 3) == "G" or op:sub(3, 3) == "L" then
			b = assert(reg[b])
		elseif op:sub(5) == "N" then
			b = "TODO_NUMBER"
		elseif op:sub(5) == "P" then
			local prims = { "nil", "false", "true" }
			assert(b >= 0)
			assert(b < 3)
			b = prims[b + 1]
		elseif op:sub(5) == "S" then
			b = '"' .. assert(func.globals[b]) .. '"'
		elseif op:sub(5) == "V" then
			b = assert(reg[b])
		else
			self:Log("Unknown operation: " .. op)
			return
		end

		condition = a .. strOp .. b
	end

	self:Write("local_cmp_result = " .. condition)
end


function Disassembler:HandleOp(pc, op, args, comment, isJumpDest)
	-- Cache commonly accessed variables
	local reg = assert(self.registers)
	local func = assert(self.currentFunction)

	if isJumpDest then
		self:Write("::label_" .. pc .. "::")
	end

	if op == "GGET" then
		assert(#args == 2)
		local o = args[1]
		local v = assert(func.globals[args[2]])
		reg[o] = v

	elseif op == "GSET" then
		assert(#args == 2)
		local i = assert(reg[args[1]])
		local v = assert(func.globals[args[2]])
		self:Write(v .. " = " .. i)


	elseif op == "TGETS" then
		assert(#args == 3)
		local o = args[1]
		local v = assert(reg[args[2]])
		local m = assert(func.globals[args[3]])
		reg[o] = v .. "." .. m

	elseif op == "TSETS" then
		assert(#args == 3)
		local i = assert(reg[args[1]])
		local v = assert(reg[args[2]])
		local m = assert(func.globals[args[3]])
		self:Write(v .. "." .. m .. " = " .. i)


	elseif op == "UGET" then
		assert(#args == 2)
		local o = args[1]
		local u = args[2]
		reg[o] = "TODO_UGET_" .. u

	elseif op == "USETV" then
		assert(#args == 2)
		local i = args[1]
		local v = assert(reg[args[2]])
		reg[i] = "TODO_UGET_" .. i
		self:Write(reg[i] .. " = " .. v)


	elseif op == "CALL" then
		assert(#args == 3)

		local start = args[1]
		local outputs = args[2]
		local inputs = args[3]

		-- Build up the function call: {"a", "b", "c"} -> a(b, c)
		local name = assert(reg[start])
		local params = "(" .. table.concat(reg, ", ", start + 1, start + inputs - 1) .. ")"

		-- And the return values too
		assert(outputs >= 1)
		local outs = ""
		if outputs > 1 then
			-- Similar to the inputs, they're assigned back to start + i for each handled return value
			for output = 2, outputs do
				local r = start + output - 2
				reg[r] = "local_var_" .. r
				outs = outs .. reg[r] .. ", "
			end
			-- Trim the last comma
			outs = outs:sub(1, -3) .. " = "
		end

		self:Write(outs .. name .. params)

	elseif op == "UCLO" then
		assert(#args == 2)
		assert(args[1] == 0)

	elseif op == "RET0" then
		assert(#args == 2)
		assert(args[1] == 0)
		assert(args[2] == 1)
		self:Write("return")

	elseif op == "RET1" then
		assert(#args == 2)
		local o = assert(reg[args[1]])
		assert(args[2] == 2)
		self:Write("return " .. o)


	elseif op == "FNEW" then
		assert(#args == 2)
		local o = args[1]
		local f = assert(func.globals[args[2]])
		reg[o] = f
		self:Write("local " .. f .. " = function() end -- new function, value unknown")

	elseif op == "TNEW" then
		assert(#args == 2)
		assert(args[2] == 0)
		local o = args[1]
		reg[o] = "local_var_" .. o
		self:Write(reg[o] .. " = {}")

	elseif op == "KPRI" then
		assert(#args == 2)
		local prims = { "nil", "false", "true" }
		local o = args[1]
		local t = args[2]
		assert(t >= 0)
		assert(t < 3)
		reg[o] = "local_var_" .. o
		self:Write(reg[o] .. " = " .. prims[t + 1])

	elseif op == "KSHORT" then
		assert(#args == 2)
		local o = args[1]
		local i = args[2]
		reg[o] = "local_var_" .. o
		self:Write(reg[o] .. " = " .. i)

	elseif op == "KSTR" then
		assert(#args == 2)
		local o = args[1]
		local s = assert(func.globals[args[2]])
		reg[o] = "local_var_" .. o
		self:Write(reg[o] .. " = \"" .. s .. "\"")


	elseif op == "MOV" then
		assert(#args == 2)
		local o = args[1]
		local i = assert(reg[args[2]])
		reg[o] = "local_var_" .. o
		self:Write(reg[o] .. " = " .. i)

	elseif op == "NOT" then
		assert(#args == 2)
		local o = args[1]
		local i = assert(reg[args[2]])
		reg[o] = "local_var_" .. o
		self:Write(reg[o] .. " = not " .. i)

	elseif
		op == "ADDVV" or op == "ADDVN" or op == "ADDNV" or
		op == "SUBVV" or op == "SUBVN" or op == "SUBNV" or
		op == "MULVV" or op == "MULVN" or op == "MULNV" or
		op == "DIVVV" or op == "DIVVN" or op == "DIVNV" or
		op == "MODVV" or op == "MODVN" or op == "MODNV" then
		self:HandleMaths(op, args, reg)

	elseif op == "POW" then
		assert(#args == 3)
		local o = args[1]
		local a = assert(reg[args[2]])
		local b = assert(reg[args[3]])
		reg[o] = "local_var_" .. o
		self:Write(reg[o] .. " = " .. a .. " ^ " .. b)


	elseif op == "JMP" then
		assert(#args == 2)
		local i = args[1]
		local dest = args[2]
		self:Write("if local_cmp_result then goto label_" .. dest .. " end -- " .. i)

	elseif op:sub(1, 2) == "IS" then
		self:HandleIf(op, args, reg, func)

	elseif op == "LOOP" then
		assert(#args == 2)
		assert(args[1] == 1)
		self:Write("-- loop start")


	elseif op == "CAT" then
		assert(#args == 3)
		local o = args[1]
		local first = args[2]
		local last = args[3]
		-- TODO: what if reg[o] is used in the concat?
		reg[o] = "local_var_" .. o
		self:Write(reg[o] .. " = " .. table.concat(reg, " .. ", first, last))


	else
		self:Log("Unhandled operation: " .. op)
		self:Write("-- Unhandled: " .. op)

	end
end


function Disassembler:HandleInstruction(line)
	-- We expect to be inside a function if there's an instruction
	assert(self.currentFunction ~= nil)

	-- Split the line into parts we can use
	line = line:gsub(" +", " ") -- Remove whitespace

	-- Strip off any comments, but keep them around since they can hold useful info
	local comment = nil
	local semicolon = line:find(";")
	if semicolon then
		comment = line:sub(semicolon + 2)
		line = line:sub(1, semicolon - 1)
		self:Info("comment: " .. comment)
	end

	-- For now only handle instructions
	local pc = line:sub(1, 4)
	if pc == "KGC " then
		-- TODO: proper parsing
		local b,e = assert(line:find("%d+"))
		local idx = tonumber(line:sub(b, e))
		line = line:sub(e + 2)
		if line:sub(1, 1) == '"' then
			line = line:sub(2, -2)
		else
			line = "TODO_GLOBAL_" .. idx
		end
		self.currentFunction.globals[idx] = line
		self:Info("New global (" .. idx .. "): " .. line)
		return

	elseif pc:find("%d%d%d%d") then
		pc = tonumber(pc)
		line = line:sub(6)

	else
		self:Log("Unknown instruction format: " .. line)
		return

	end

	-- Check for any jump info
	local isJumpDest = line:sub(1, 3) == "=> "
	line = line:gsub("=> ", "") -- This also removes it from the jumps

	-- Pull out the operation
	local opIdx = assert(line:find(" "))
	local op = line:sub(1, opIdx - 1)
	line = line:sub(opIdx + 1)
	self:Info("op: " .. op)

	-- The args should be all that's left
	args = {}
	for arg in line:gmatch("%w+") do
		table.insert(args, tonumber(arg))
		self:Info("arg: " .. arg)
	end

	-- Dispatch this operation
	self:IncreaseIndent()
	self:HandleOp(pc, op, args, comment, isJumpDest)
	self:DecreaseIndent()
end


function Disassembler:HandleFunctionBegin(line)
	assert(self.currentFunction == nil)

	-- Create the new function
	local func = {}
	func.name = "func_" .. self.lineNo
	func.globals = {}
	self:Log("New function: " .. func.name)

	self.functions[func.name] = func
	self.currentFunction = func

	-- Setup fresh registers
	self.registers = {}
	for r = 0,100 do
		-- TODO: nil -> input_var_N at point of use
		self.registers[r] = "input_var_" .. r
	end

	-- Start the function
	self:Write("function " .. func.name .. "(...)")
end


function Disassembler:HandleFunctionEnd(line)
	-- This is the end of a function, so we should have been working on one
	assert(self.currentFunction ~= nil)
	self.currentFunction = nil
	self.registers = nil

	-- End the function
	self:Write("end\n")
end


function Disassembler:HandleLine(line)
	self:Info("Line: " .. line)
	self:IncreaseIndent()

	-- Determine the type of info on this line
	if line == "" then
		self:HandleFunctionEnd(line)
	elseif line:sub(1, 14) == "-- BYTECODE --" then
		self:HandleFunctionBegin(line)
	else
		self:HandleInstruction(line)
	end

	-- RAII would be nice here, if Lua supported it
	self:DecreaseIndent()
end


function Disassembler:Read(fileIn)
	-- Read line by line until there's nothing left
	while true do
		local line = fileIn:read("*line")
		if line == nil then break end

		-- There's another line to parse
		self.lineNo = self.lineNo + 1
		self:HandleLine(line)
	end
end


function Disassembler:Log(msg)
	local indent = "\t"
	indent = indent:rep(self.logIndent)
	print("#" .. self.lineNo .. ": " .. indent .. msg)
end


function Disassembler:Info(msg)
	if self.verbose then
		self:Log(msg)
	end
end


function Disassembler:IncreaseIndent()
	self.logIndent = self.logIndent + 1
end


function Disassembler:DecreaseIndent()
	self.logIndent = self.logIndent - 1
end


function Disassembler:Write(line)
	self.fileOut:write(line .. "\n")
end


function Disassemble(input, output)
	-- TODO: this would be better, but I can't see how to get the name to pass to luajit
	--local temp = assert(io.tmpfile())
	local temp = os.tmpname()

	-- Convert the input to a temporary file
	-- TODO: no string concatenation
	os.execute("luajit -blg " .. input .. " " .. temp)

	-- Open the files we'll be using
	local fileIn = assert(io.open(temp, "r"))
	local fileOut = assert(io.open(output, "w"))

	-- Run the disassembler
	local disassembler = Disassembler:new(fileOut)
	disassembler:Read(fileIn)
end


-- Parse args
-- TODO: better here
local input, output
if #arg ~= 2 then
	print("Usage:\n\t" .. arg[0] .. " <input> <output>")
	return
else
	input = arg[1]
	output = arg[2]
end

-- Testing code
-- TODO: add to arg parsing
-- [[
os.execute("luajit -b " .. input .. " input.luac")
os.execute("luajit -blg input.luac input.txt")
input = "input.luac"
--]]

-- Go go go
Disassemble(input, output)
