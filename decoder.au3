#include <Array.au3>

RunWait("luajit -blg test.lua test.asm")
Sleep(0.5)

Dim $in = FileOpen("test.asm")
Dim $out = FileOpen("out.lua",2)

Dim $randomOutNo = 0
Dim $randomStringNo = 0
Dim $randomNoNo = 0
Dim $randomPrimitiveNo = 0
Dim $randomFunctionNo = 0
Dim $unknownNo = 0
Dim $randomTableNo = 0


Dim $filo[100]
Dim $uv[100]
Dim $jmps[1]
Dim $loops[1]
Dim $endifm = "end"

Dim $line = ""
While true
	$line = FileReadLine($in)
	If @error then ExitLoop
	handleLine($line)
WEnd

FileClose($out)
FileClose($in)



Func handleLine($l)
	dim $header = StringLeft($l,4)
	if $header = "" Then						;check for end of functions
		FileWriteLine($out,"end")
		FileWriteLine($out,"")
	ElseIf $header = "-- B" Then				;check for new function start
		FileWriteLine($out,$l)
		FileWriteLine($out,"function someFunction()")
		Dim $fi2[100]
		$fi2[0] = "var0"
		$fi2[1] = "var1"
		$fi2[2] = "var2"
		$fi2[3] = "var3"
		$fi2[4] = "var4"
		$fi2[5] = "var5"
		$fi2[6] = "var6"
		$fi2[7] = "var7"
		$fi2[8] = "var8"
		$filo = $fi2
	Else
		Dim $comment = StringSplit($l,";")		;split for comment
		Dim $c = ""
		Dim $c2 = ""
		Dim $com = False
		$l = $comment[1]
		if $comment[0] = 2 Then					;if comment exists
			$c = $comment[2]					;set comment
			$com = true
		EndIf
		if $comment[0] = 3 Then					;if comment exists
			$c = $comment[2]					;set comment
			$com = true
			$c2 = $comment[3]					;set comment2
		EndIf
		$l = StringReplace($l,"=>","")			;remove "=>"'s
		While StringInStr($l,"  ")				;remove whitespaces
			$l = StringReplace($l,"  "," ")
		WEnd
		Dim $sec = StringSplit($l," ")			;split into sections
		Dim $func = $sec[2]						;operator
		Dim $p1 = 0								;arguements
		Dim $p2 = 0
		Dim $p3 = 0
		If $sec[0]>=3 Then $p1 = $sec[3]
		If $sec[0]>=4 Then $p2 = $sec[4]
		If $sec[0]>=5 Then $p3 = $sec[5]
		;_ArrayDisplay($filo)
		If _ArraySearch($jmps,$header)<>-1 Then
			FileWriteLine($out,"--location " & $header)
			_ArrayDelete($jmps,_ArraySearch($jmps,$header))
		EndIf
		If _ArraySearch($loops,$header)<>-1 Then
			FileWriteLine($out,"until false or (previous if statement is true) --location " & $header)
			_ArrayDelete($jmps,_ArraySearch($jmps,$header))
		EndIf
		;_ArrayDisplay($endifs)
		handleOp($func,$p1,$p2,$p3,$c,$header,$c2)			;handle the operation
		;FileWriteLine($out,$func)
	EndIf
	;MsgBox(0,"",$l)
EndFunc


Func handleOp($f,$p1,$p2,$p3,$c,$h,$c2)
	Dim $tmp
	If $f = "GGET" Then
		If $c = "" Then
			$filo[$p1] = "unknown" & $unknownNo
			$unknownNo = $unknownNo + 1
		Else
			$tmp = StringSplit($c,"""")
			$filo[$p1] = $tmp[2]
		EndIf
		
	ElseIf $f = "TGETS" Then
		If $c = "" Then
			$filo[$p1] = $filo[$p2] & ".unknown" & $unknownNo
			$unknownNo = $unknownNo + 1
		Else
			$tmp = StringSplit($c,"""")
			$filo[$p1] = $filo[$p2] & "." & $tmp[2]
		EndIf
		
	ElseIf $f = "TGETV" Then
		If $c = "" Then
			$filo[$p1] = "unknown" & $unknownNo
			$unknownNo = $unknownNo + 1
		Else
			$tmp = StringSplit($c,"""")
			$filo[$p1] = $tmp[2]
		EndIf
		
	ElseIf $f = "UGET" Then
		$tmp = StringReplace($c," ","")
		If $tmp = "" Then
			$filo[$p1] = "uget_" & $p2
		Else
			$filo[$p1] = $tmp
		EndIf
		
	ElseIf $f = "CALL" Then
		$tmp = ""
		dim $args = ""
		If $p3 > 1 Then
			$args = $filo[$p1+1]
			For $i = 2 To $p3-1
				$args = $args & ", " & $filo[$p1+$i]
			Next
		EndIf
		$args = $filo[$p1] & "(" & $args & ")"
		If $p2 > 1 Then
			$tmp = "local randomOut" & $randomOutNo
			$filo[$p1] = "randomOut" & $randomOutNo
			$randomOutNo = $randomOutNo + 1
			For $i = 2 To $p2-1
				$tmp = $tmp &  ", randomOut" & $randomOutNo
				$filo[$p1+$i-1] = "randomOut" & $randomOutNo
				$randomOutNo = $randomOutNo + 1
			Next
			$tmp = $tmp & " = "
		EndIf
		If $p2 = 0 Then
			$tmp = "local randomOut" & $randomOutNo
			$filo[$p1] = "randomOut" & $randomOutNo
			$tmp = $tmp & " = "
			$args = $args & " -- replace all occurrences of randomOut" & $randomOutNo & " with this function and remove this line"
			$randomOutNo = $randomOutNo + 1
		EndIf
		FileWriteLine($out,$tmp & $args)
		
	ElseIf $f = "CALLM" Then
		$tmp = ""
		dim $args = ""
		;If $p3 >= 0 Then
			$args = $filo[$p1+1]
			For $i = 1 To $p3
				$args = $args & ", " & $filo[$p1+$i+1]
			Next
		;EndIf
		$args = $filo[$p1] & "(" & $args & ")"
		If $p2 > 1 Then
			$tmp = "local randomOut" & $randomOutNo
			$filo[$p1] = "randomOut" & $randomOutNo
			$randomOutNo = $randomOutNo + 1
			For $i = 2 To $p2-1
				$tmp = $tmp &  ", randomOut" & $randomOutNo
				$filo[$p1+$i-1] = "randomOut" & $randomOutNo
				$randomOutNo = $randomOutNo + 1
			Next
			$tmp = $tmp & " = "
		EndIf
		If $p2 = 0 Then
			$tmp = "local randomOut" & $randomOutNo
			$filo[$p1] = "randomOut" & $randomOutNo
			$tmp = $tmp & " = "
			$args = $args & " -- replace all occurrences of randomOut" & $randomOutNo & " with this function and remove this line"
			$randomOutNo = $randomOutNo + 1
		EndIf
		FileWriteLine($out,$tmp & $args)
		
	ElseIf $f = "GSET" Then
		If $c<>"" Then
			$tmp = StringSplit($c,"""")
			$tmp = $tmp[2]
		Else
			$tmp = $filo[$p2]
		EndIf
		FileWriteLine($out,$tmp & " = " & $filo[$p1])
		
	ElseIf $f = "TSETS" Then
		If $c<>"" Then
			$tmp = StringSplit($c,"""")
			$tmp = $filo[$p2] & "." & $tmp[2]
		Else
			$tmp = $filo[$p2] & "." & $filo[$p3]
		EndIf
		FileWriteLine($out,$tmp & " = " & $filo[$p1])
		
	ElseIf $f = "USETS" Then
		$tmp = StringReplace($c," ","")
		If $tmp="" Then
			If $filo[$p2] = "" Then
				$filo[$p2] = "unknown" & $unknownNo
				$unknownNo = $unknownNo + 1
			EndIf
			$tmp = $filo[$p2]
		EndIf
		FileWriteLine($out,$tmp & " = " & $c2)
		
	ElseIf $f = "USETN" Then
		$tmp = StringReplace($c," ","")
		If $tmp="" Then
			If $filo[$p2] = "" Then
				$filo[$p2] = "unknown" & $unknownNo
				$unknownNo = $unknownNo + 1
			EndIf
			$tmp = $filo[$p2]
		EndIf
		FileWriteLine($out,$tmp & " = " & $c2)
		
	ElseIf $f = "USETV" Then
		$tmp = StringReplace($c," ","")
		If $tmp="" Then
			If $filo[$p2] = "" Then
				$filo[$p2] = "unknown" & $unknownNo
				$unknownNo = $unknownNo + 1
			EndIf
			$tmp = $filo[$p2]
		EndIf
		FileWriteLine($out,$tmp & " = " & $filo[$p1])
		
;~ 	ElseIf $f = "ADDVV" Then
;~ 		$filo[$p1] = $filo[$p2] & " + " & $filo[$p3]
;~ 		
;~ 	ElseIf $f = "ADDVN" Then
;~ 		$filo[$p1] = $filo[$p2] & " + " & $c
;~ 		
;~ 	ElseIf $f = "ADDNV" Then
;~ 		$filo[$p1] = $c & " + " & $filo[$p2]
;~ 		
;~ 	ElseIf $f = "SUBVV" Then
;~ 		$filo[$p1] = $filo[$p2] & " - " & $filo[$p3]
;~ 		
;~ 	ElseIf $f = "SUBVN" Then
;~ 		$filo[$p1] = $filo[$p2] & " - " & $c
;~ 		
;~ 	ElseIf $f = "SUBNV" Then
;~ 		$filo[$p1] = $c & " - " & $filo[$p2]
;~ 		
;~ 	ElseIf $f = "MULVV" Then
;~ 		$filo[$p1] = $filo[$p2] & " * " & $filo[$p3]
;~ 		
;~ 	ElseIf $f = "MULVN" Then
;~ 		$filo[$p1] = $filo[$p2] & " * " & $c
;~ 		
;~ 	ElseIf $f = "MULNV" Then
;~ 		$filo[$p1] = $c & " * " & $filo[$p2]
;~ 		
;~ 	ElseIf $f = "DIVVV" Then
;~ 		$filo[$p1] = $filo[$p2] & " / " & $filo[$p3]
;~ 		
;~ 	ElseIf $f = "DIVVN" Then
;~ 		$filo[$p1] = $filo[$p2] & " / " & $c
;~ 		
;~ 	ElseIf $f = "DIVNV" Then
;~ 		$filo[$p1] = $c & " / " & $filo[$p2]
;~ 		
;~ 	ElseIf $f = "MODVV" Then
;~ 		$filo[$p1] = $filo[$p2] & " % " & $filo[$p3]
;~ 		
;~ 	ElseIf $f = "MODVN" Then
;~ 		$filo[$p1] = $filo[$p2] & " % " & $c
;~ 		
;~ 	ElseIf $f = "MODNV" Then
;~ 		$filo[$p1] = $c & " % " & $filo[$p2]
;~ 		
;~ 	ElseIf $f = "POW" Then
;~ 		$filo[$p1] = $filo[$p2] & " ^ " & $filo[$p3]
		
	ElseIf $f = "ADDVV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " + " & $filo[$p3])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "ADDVN" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " + " & $c)
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "ADDNV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $c & " + " & $filo[$p2])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "SUBVV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " - " & $filo[$p3])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "SUBVN" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " + " & $c)
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "SUBNV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $c & " - " & $filo[$p2])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "MULVV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " * " & $filo[$p3])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "MULVN" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " * " & $c)
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "MULNV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $c & " * " & $filo[$p2])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "DIVVV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " / " & $filo[$p3])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "DIVVN" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " / " & $c)
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "DIVNV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $c & " / " & $filo[$p2])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "POW" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " ^ " & $filo[$p3])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "MODVV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " % " & $filo[$p3])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "MODVN" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $filo[$p2] & " % " & $c)
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "MODNV" Then
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $c & " % " & $filo[$p2])
		$filo[$p1] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "KSTR" Then
		$filo[$p1] = "randomString" & $randomStringNo
		If $c = "" Then
			FileWriteLine($out,"local randomString" & $randomStringNo & " = ""some random string""")
		Else
			$tmp = StringSplit($c,"""")
			FileWriteLine($out,"local randomString" & $randomStringNo & " = """ & $tmp[2] & """")
		EndIf
		$randomStringNo = $randomStringNo + 1
		
	ElseIf $f = "RET0" Then
		FileWriteLine($out,"return")
		
	ElseIf $f = "RET1" Then
		FileWriteLine($out,"return " & $filo[$p1])
		
	ElseIf $f = "RET" Then
		$tmp = ""
		If $p2 > 1 Then
			$tmp = " " & $filo[$p1]
		EndIf
		If $p2 > 2 Then
			For $i = 2 To $p2-1
				$tmp = $tmp & ", " & $filo[$p1+$i-1]
			Next
		EndIf
		FileWriteLine($out,"return" & $tmp)
		
	ElseIf $f = "CALLT" Then
		$tmp = ""
		dim $args = ""
		If $p2 > 1 Then
			$args = $filo[$p1+1]
			For $i = 2 To $p2-1
				$args = $args & ", " & $filo[$p1+$i]
			Next
		EndIf
		$args = $filo[$p1] & "(" & $args & ")"
		FileWriteLine($out,"return " & $args)
		
	ElseIf $f = "CALLMT" Then
		$tmp = ""
		dim $args = ""
		;If $p3 >= 0 Then
			$args = $filo[$p1+1]
			For $i = 1 To $p2
				$args = $args & ", " & $filo[$p1+$i+1]
			Next
		;EndIf
		$args = $filo[$p1] & "(" & $args & ")"
		FileWriteLine($out,$tmp & $args)
		
	ElseIf $f = "KSHORT" Then
		$filo[$p1] = "randomNo" & $randomNoNo
		FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $p2)
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "KNUM" Then
		$filo[$p1] = "randomNo" & $randomNoNo
		If $c = "" Then
			FileWriteLine($out,"local randomNo" & $randomNoNo & " = 0 -- COULDN'T FIND OUT THE VALUE!")
		Else
			$tmp = StringReplace($c," ","")
			FileWriteLine($out,"local randomNo" & $randomNoNo & " = " & $tmp)
		EndIf
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "MOV" Then
		$filo[$p1] = $filo[$p2]
		
	ElseIf $f = "NOT" Then
		$filo[$p1] = "not " & $filo[$p2]
		
	ElseIf $f = "ISF" Then
		FileWriteLine($out,"if " & $filo[$p1] & " then")
		
	ElseIf $f = "IST" Then
		FileWriteLine($out,"if not " & $filo[$p1] & " then")
		
	ElseIf $f = "ISNEV" Then
		FileWriteLine($out,"if " & $filo[$p1] & " == " & $filo[$p2] & " then")
		
	ElseIf $f = "ISEQV" Then
		FileWriteLine($out,"if " & $filo[$p1] & " ~= " & $filo[$p2] & " then")
		
	ElseIf $f = "ISGE" Then
		FileWriteLine($out,"if " & $filo[$p1] & " < " & $filo[$p2] & " then")
		
	ElseIf $f = "ISGT" Then
		FileWriteLine($out,"if " & $filo[$p1] & " <= " & $filo[$p2] & " then")
		
	ElseIf $f = "ISLT" Then
		FileWriteLine($out,"if not (" & $filo[$p1] & " < " & $filo[$p2] & ") then")
		
	ElseIf $f = "ISLE" Then
		FileWriteLine($out,"if not (" & $filo[$p1] & " <= " & $filo[$p2] & ") then")
		
	ElseIf $f = "ISNEN" Then
		FileWriteLine($out,"if " & $filo[$p1] & " == " & $p2 & " then")
		
	ElseIf $f = "ISEQN" Then
		FileWriteLine($out,"if " & $filo[$p1] & " ~= " & $p2 & " then")
		
	ElseIf $f = "ISNES" Then
		If $c = "" Then
			FileWriteLine($out,"if " & $filo[$p1] & " == ""some random string"" then")
		Else
			FileWriteLine($out,"if " & $filo[$p1] & " == " & $c & " then")
		EndIf
		
	ElseIf $f = "ISEQS" Then
		If $c = "" Then
			FileWriteLine($out,"if " & $filo[$p1] & " ~= ""some random string"" then")
		Else
			FileWriteLine($out,"if " & $filo[$p1] & " ~= " & $c & " then")
		EndIf
		
	ElseIf $f = "ISNEP" Then
		Dim $prims[3] = ["nil","false","true"]
		FileWriteLine($out,"if " & $filo[$p1] & " == " & $prims[$p2] & " then")
		
	ElseIf $f = "ISEQP" Then
		Dim $prims[3] = ["nil","false","true"]
		FileWriteLine($out,"if " & $filo[$p1] & " ~= " & $prims[$p2] & " then")
		
	ElseIf $f = "JMP" Then
		If $p1>=3 Then
			;FileWriteLine($out,"--if you see randomOut" & $randomOutNo & " or randomOut" & $randomOutNo+1 & " and there isn't an if directly above this then its:")
			FileWriteLine($out,"for randomOut" & $randomOutNo & ", randomOut" & $randomOutNo+1 & " in (" & $filo[$p1-3] & "s calling function) do --if (" & $filo[$p1-3] & "s calling function) isn't on the line before then remove this line")
		EndIf
		;FileWriteLine($out,"--it could be an else of an elseif")
		FileWriteLine($out,"--jump to " & $p2 & " (if previous if statement is false)")
		_ArrayAdd($jmps,$p2)
		$filo[$p1] = "randomOut" & $randomOutNo
		$filo[$p1+1] = "randomOut" & $randomOutNo+1
		$randomOutNo = $randomOutNo+2
		
	ElseIf $f = "LOOP" Then
		FileWriteLine($out,"repeat")
		_ArrayAdd($loops,$p2)
		
	ElseIf $f = "CAT" Then
		$filo[$p1] = $filo[$p2] & " .. " & $filo[$p3]
		
	ElseIf $f = "KPRI" Then
		Dim $prims[3] = ["nil","false","true"]
		$filo[$p1] = "randomPrimitive" & $randomPrimitiveNo
		FileWriteLine($out,"local randomPrimitive" & $randomPrimitiveNo & " = " & $prims[$p2])
		$randomPrimitiveNo = $randomPrimitiveNo + 1
		
	ElseIf $f = "FNEW" Then
		$filo[$p1] = "randomFunction" & $randomFunctionNo
		If $c = "" Then
			FileWriteLine($out,"local randomFunction" & $randomFunctionNo & " = function() end -- unknown location")
		Else
			FileWriteLine($out,"local randomFunction" & $randomFunctionNo & " = function() end -- starts at " & $c)
		EndIf
		$randomFunctionNo = $randomFunctionNo + 1
		
	ElseIf $f = "FORI" Then
		FileWriteLine($out,"for randomNo" & $randomNoNo & " = " & $filo[$p1] & "," & $filo[$p1+1] & "," & $filo[$p1+2] & " do --location " & $h & ", loop ends at " & $p2 & "-1")
		$filo[$p1+3] = "randomNo" & $randomNoNo
		$randomNoNo = $randomNoNo + 1
		
	ElseIf $f = "FORL" Then
		FileWriteLine($out,"end --location " & $h & ", loops back to " & $p2 & "-1")
		
	ElseIf $f = "KNIL" Then
		For $i = $p1 to $p2
			$filo[$i] = "randomPrimitive" & $randomPrimitiveNo
			FileWriteLine($out,"local randomPrimitive" & $randomPrimitiveNo & " = nil")
			$randomPrimitiveNo = $randomPrimitiveNo + 1
		Next
		
	ElseIf $f = "ITERN" Then
	ElseIf $f = "ISNEXT" Then
		If $p1>=3 Then
			FileWriteLine($out,"for randomOut" & $randomOutNo & ", randomOut" & $randomOutNo+1 & " in (" & $filo[$p1-3] & "s calling function) do --if (" & $filo[$p1-3] & "s calling function) isn't on the line before then remove this line")
		EndIf
		$filo[$p1] = "randomOut" & $randomOutNo
		$randomOutNo = $randomOutNo + 1
		$filo[$p1+1] = "randomOut" & $randomOutNo
		$randomOutNo = $randomOutNo + 1
		
	ElseIf $f = "ITERC" Then
	ElseIf $f = "ITERL" Then
		FileWriteLine($out,"end --end of a for loop")
		
	ElseIf $f = "UCLO" Then
		
	ElseIf $f = "TNEW" Then
		$filo[$p1] = "randomTable" & $randomTableNo
		FileWriteLine($out,"local randomTable" & $randomTableNo & " = {}")
		$randomTableNo = $randomTableNo + 1
		
	ElseIf $f = "TDUP" Then
		$filo[$p1] = "randomTable" & $randomTableNo
		FileWriteLine($out,"local randomTable" & $randomTableNo & " = {} --to find out the contents of this table look inside the lua file")
		$randomTableNo = $randomTableNo + 1
		
	ElseIf $f = "TSETB" Then
		FileWriteLine($out,$filo[$p2] & "[" & $p3 & "] = " & $filo[$p1])
		
	ElseIf $f = "TSETV" Then
		FileWriteLine($out,$filo[$p2] & "[" & $filo[$p3] & "] = " & $filo[$p1])
		
	ElseIf $f = "VARG" Then
		FileWriteLine($out,"--VARG appeared here - that usually means that the input for this function should be (...) and anywhere you see var0 or var1 or var2 ect. in this function should be replaced by (...)")
		
	Else						;catch any others
		FileWriteLine($out,$f & " unhandled at " & $h)
	EndIf
EndFunc

