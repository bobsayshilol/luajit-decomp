#include <Array.au3>
#include <Math.au3>

RunWait("luajit -blg test.lua test.asm")
Sleep(0.5)

Dim $in = FileOpen("test.asm")
Dim $out = FileOpen("out.lua",2)

;~ Dim $randomOutNo = 0
;~ Dim $randomStringNo = 0
;~ Dim $randomNoNo = 0
;~ Dim $randomPrimitiveNo = 0
Dim $randomFunctionNo = 0
Dim $unknownNo = 0
;~ Dim $randomTableNo = 0

Dim $filo[100]
Dim $jmps[1]
Dim $loops[1]
Dim $fNo = -1

Dim $line = ""
While true
	$line = FileReadLine($in)
	If @error then ExitLoop
	handleLine($line)
WEnd

FileClose($out)
FileClose($in)

$out = FileOpen("out.lua")

Dim $faa[1]
Dim $tmpArray[1]
$fNo = 0
While true
	$line = FileReadLine($out)
	If @error then ExitLoop
	if StringLeft($line,4) = "-- B" Then
		$fNo = $fNo + 1
		_ArrayAdd($faa,$tmpArray)
	EndIf
	_ArrayAdd($faa[$fNo],$line)
	;MsgBox(0,$fNo,$line)
WEnd

FileClose($out)

fixup()

$out = FileOpen("out2.lua",2)
for $func in $faa
	for $line in $func
		FileWriteLine($out,$line)
	Next
	FileWriteLine($out,"")
Next
FileClose($out)

;~ for $func in $faa
;~ 	_ArrayDisplay($func)
;~ Next


Func handleLine($l)
	dim $header = StringLeft($l,4)
	if $header = "" Then						;check for end of functions
		FileWriteLine($out,"end")
		FileWriteLine($out,"")
	ElseIf $header = "-- B" Then				;check for new function start
		FileWriteLine($out,$l)
		FileWriteLine($out,"function someFunc" & $fNo+1 & "()")
		Dim $fi2[100]
		$fi2[0] = "INPUT_VAR_0_"
		$fi2[1] = "INPUT_VAR_1_"
		$fi2[2] = "INPUT_VAR_2_"
		$fi2[3] = "INPUT_VAR_3_"
		$fi2[4] = "INPUT_VAR_4_"
		$fi2[5] = "INPUT_VAR_5_"
		$fi2[6] = "INPUT_VAR_6_"
		$fi2[7] = "INPUT_VAR_7_"
		$fi2[8] = "INPUT_VAR_8_"
		$fi2[9] = "INPUT_VAR_9_"
		$fi2[10] = "INPUT_VAR_10_"
		$filo = $fi2
		Dim $jmps2[1]
		$jmps = $jmps2
		$fNo = $fNo + 1
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
		
	ElseIf $f = "TGETB" Then
		If $c = "" Then
			$filo[$p1] = $filo[$p2] & ".unknownB" & $unknownNo
			$unknownNo = $unknownNo + 1
		Else
			$tmp = StringSplit($c,"""")
			$filo[$p1] = $filo[$p2] & "." & $tmp[2]
		EndIf
		
	ElseIf $f = "UGET" Then
		$tmp = StringReplace($c," ","")
		If $tmp = "" Then
			$filo[$p1] = "uget_" & $fNo & "_" & $p2
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
			$tmp = "var_" & $fNo & "_" & $p1
			$filo[$p1] = "var_" & $fNo & "_" & $p1
			For $i = 2 To $p2-1
				$tmp = $tmp &  ", var_" & $fNo & "_" & $p1+$i-1
				$filo[$p1+$i-1] = "var_" & $fNo & "_" & $p1+$i-1
			Next
			$tmp = $tmp & " = "
		EndIf
		If $p2 = 0 Then
			$tmp = "var_" & $fNo & "_" & $p1
			$filo[$p1] = "var_" & $fNo & "_" & $p1
			$tmp = $tmp & " = "
			;$args = $args & " -- replace the next occurrence of var_" & $fNo & "_" & $p1 & " with this function and remove this line --var_" & $fNo & "_" & $p1 & " REPLACE-REPLACE"
			$args = $args & " --var_" & $fNo & "_" & $p1 & " REPLACE-REPLACE"
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
			$tmp = "var_" & $fNo & "_" & $p1
			$filo[$p1] = "var_" & $fNo & "_" & $p1
			For $i = 2 To $p2-1
				$tmp = $tmp &  ", var_" & $fNo & "_" & $p1
				$filo[$p1+$i-1] = "var_" & $fNo & "_" & $p1
			Next
			$tmp = $tmp & " = "
		EndIf
		If $p2 = 0 Then
			$tmp = "var_" & $fNo & "_" & $p1
			$filo[$p1] = "var_" & $fNo & "_" & $p1
			$tmp = $tmp & " = "
			;$args = $args & " -- replace the next occurrence of var_" & $fNo & "_" & $p1 & " with this function and remove this line"
			$args = $args & " --var_" & $fNo & "_" & $p1 & " REPLACE-REPLACE"
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
				$filo[$p2] = "var_" & $fNo & "_" & $p2
			EndIf
			$tmp = $filo[$p2]
		EndIf
		FileWriteLine($out,$tmp & " = " & $c2)
		
	ElseIf $f = "USETN" Then
		$tmp = StringReplace($c," ","")
		If $tmp="" Then
			If $filo[$p2] = "" Then
				$filo[$p2] = "var_" & $fNo & "_" & $p2
			EndIf
			$tmp = $filo[$p2]
		EndIf
		FileWriteLine($out,$tmp & " = " & $c2)
		
	ElseIf $f = "USETV" Then
		$tmp = StringReplace($c," ","")
		If $tmp="" Then
			If $filo[$p2] = "" Then
				$filo[$p2] = "var_" & $fNo & "_" & $p2
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
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " + " & $filo[$p3] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "ADDVN" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " + " & $c & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "ADDNV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $c & " + " & $filo[$p2] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "SUBVV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " - " & $filo[$p3] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "SUBVN" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " - " & $c & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "SUBNV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $c & " - " & $filo[$p2] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "MULVV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " * " & $filo[$p3] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "MULVN" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " * " & $c & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "MULNV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $c & " * " & $filo[$p2] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "DIVVV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " / " & $filo[$p3] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "DIVVN" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " / " & $c & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "DIVNV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $c & " / " & $filo[$p2] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "POW" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " ^ " & $filo[$p3] & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "MODVV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " % " & $filo[$p3])
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "MODVN" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2] & " % " & $c)
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "MODNV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $c & " % " & $filo[$p2])
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
	ElseIf $f = "KSTR" Then
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		If $c = "" Then
			FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = """" --some random string I couldn't find")
		Else
			$tmp = StringSplit($c,"""")
			If StringLen($tmp[2]) = 40 Then
				FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = """ & $tmp[2] & """ --strings longer than 40 characters get cut off, so check to see if there's more!")
			Else
				FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = """ & $tmp[2] & """ --var_" & $fNo & "_" & $p1 & " STRING-STRING")
			EndIf
		EndIf
;~ 	ElseIf $f = "KSTR" Then
;~ 		If $c = "" Then
;~ 			$filo[$p1] = "--some random string you will have to look up"
;~ 		Else
;~ 			$tmp = StringSplit($c,"""")
;~ 			If StringLen($tmp[2]) = 40 Then
;~ 				$filo[$p1] = """" & $tmp[2] & """ --strings longer than 40 characters get cut off, so check to see if there's more!"
;~ 			Else
;~ 				$filo[$p1] = """" & $tmp[2] & """ --STRING-STRING"
;~ 			EndIf
;~ 		EndIf
		
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
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $p2 & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		
	ElseIf $f = "KNUM" Then
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		If $c = "" Then
			FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = 0 -- COULDN'T FIND OUT THE VALUE!")
		Else
			$tmp = StringReplace($c," ","")
			FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $tmp & " --var_" & $fNo & "_" & $p1 & " NUMBER-NUMBER")
		EndIf
		
	ElseIf $f = "MOV" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $filo[$p2])
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
		
	ElseIf $f = "NOT" Then
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = not " & $filo[$p2])
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		
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
			FileWriteLine($out,"for var_" & $fNo & "_" & $p1 & ", var_" & $fNo & "_" & $p1+1 & " in (" & $filo[$p1-3] & " calling function) do --" & $filo[$p1-3] & " FORTEST-FORTEST")
		EndIf
		;FileWriteLine($out,"--it could be an else of an elseif")
		FileWriteLine($out,"--jump to " & $p2 & " (if previous if statement is false)")
		_ArrayAdd($jmps,$p2)
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		$filo[$p1+1] = "var_" & $fNo & "_" & $p1+1
		
	ElseIf $f = "LOOP" Then
		FileWriteLine($out,"repeat")
		_ArrayAdd($loops,$p2)
		
	ElseIf $f = "CAT" Then
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		$tmp = $filo[$p2]
		for $i = $p2+1 to $p3
			$tmp = $tmp & " .. " & $filo[$i]
		Next
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $tmp)
		
	ElseIf $f = "KPRI" Then
		Dim $prims[3] = ["nil","false","true"]
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = " & $prims[$p2] & " --var_" & $fNo & "_" & $p1 & " PRIMITIVE-PRIMITIVE")
		
	ElseIf $f = "FNEW" Then
		$filo[$p1] = "randomFunction" & $randomFunctionNo
		If $c = "" Then
			FileWriteLine($out,"local randomFunction" & $randomFunctionNo & " = function() end -- unknown location")
		Else
			FileWriteLine($out,"local randomFunction" & $randomFunctionNo & " = function() end -- starts at " & $c)
		EndIf
		$randomFunctionNo = $randomFunctionNo + 1
		
	ElseIf $f = "FORI" Then
		FileWriteLine($out,"for var_" & $fNo & "_" & $p1+3 & " = " & $filo[$p1] & "," & $filo[$p1+1] & "," & $filo[$p1+2] & " do --location " & $h & ", loop ends at " & $p2 & "-1")
		$filo[$p1+3] = "var_" & $fNo & "_" & $p1+3
		
	ElseIf $f = "FORL" Then
		FileWriteLine($out,"end --location " & $h & ", loops back to " & $p2 & "-1")
		
	ElseIf $f = "KNIL" Then
		For $i = $p1 to $p2
			$filo[$i] = "var_" & $fNo & "_" & $i
			FileWriteLine($out,"var_" & $fNo & "_" & $i & " = nil")
		Next
		
	ElseIf $f = "ITERN" Then
	ElseIf $f = "ISNEXT" Then
		If $p1>=3 Then
			FileWriteLine($out,"for var_" & $fNo & "_" & $p1 & ", var_" & $fNo & "_" & $p1+1 & " in (" & $filo[$p1-3] & "s calling function) do --" & $filo[$p1-3] & " FORTEST-FORTEST")
		EndIf
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		$filo[$p1+1] = "var_" & $fNo & "_" & $p1+1
		
	ElseIf $f = "ITERC" Then
	ElseIf $f = "ITERL" Then
		FileWriteLine($out,"end --end of a for loop")
		
	ElseIf $f = "UCLO" Then
		
	ElseIf $f = "TNEW" Then
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = {}")
		
	ElseIf $f = "TDUP" Then
		$filo[$p1] = "var_" & $fNo & "_" & $p1
		FileWriteLine($out,"var_" & $fNo & "_" & $p1 & " = {} --to find out the contents of this table look inside the lua file")
		
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

Func fixup()
	_ArrayDelete($faa,0)
	for $fi = 0 to UBound($faa)-1
		_ArrayDelete($faa[$fi],0)
		_ArrayDelete($faa[$fi],0)
		$li = 0
		While $li < UBound($faa[$fi])-1
			;MsgBox(0,"",$li)
			$func = $faa[$fi]
			$line = $func[$li]
			
			
			If StringRight($line,15) = "FORTEST-FORTEST" Then
				$tmp = StringSplit($line,"--",1)
				$tmp = StringSplit($tmp[2]," ")
				If Not StringInStr($func[$li-1],$tmp[1]) Then
					_ArrayDelete($faa[$fi],$li)
					ContinueLoop
				EndIf
				
			ElseIf StringRight($line,13) = "STRING-STRING" Then
				$tmp = StringSplit($line,"--",1)
				$tmp = StringSplit($tmp[2]," ")
				For $li2 = $li+1 To UBound($func)-1
					If StringInStr($func[$li2],$tmp[1] & " =") Then
						Dim $tmp2 = StringSplit($func[$li2],"=")
						If not StringInStr($tmp2[2],$tmp[1]) Then ExitLoop
						
						$line = StringSplit($line,"""")
						$tmp2[2] = StringReplace($tmp2[2],$tmp[1],"""" & $line[2] & """")
						$func[$li2] = $tmp[1] & " = " & $tmp2[2]
						;MsgBox(0,"",$func[$li2])
						$faa[$fi] = $func
						_ArrayDelete($faa[$fi],$li)
						ContinueLoop 2
						;ExitLoop
					ElseIf StringInStr($func[$li2],$tmp[1]) Then
						$line = StringSplit($line,"""")
						$func[$li2] = StringReplace($func[$li2],$tmp[1],"""" & $line[2] & """")
						$faa[$fi] = $func
						_ArrayDelete($faa[$fi],$li)
						ContinueLoop 2
						;ExitLoop
					EndIf
				Next
				;_ArrayDelete($faa[$fi],$li)
				;ContinueLoop
				
			ElseIf StringRight($line,13) = "NUMBER-NUMBER" Then
				$tmp = StringSplit($line,"--",1)
				$tmp = StringSplit($tmp[2]," ")
				For $li2 = $li+1 To UBound($func)-1
					If StringInStr($func[$li2],$tmp[1] & " =") Then
						Dim $tmp2 = StringSplit($func[$li2],"=")
						$tmp2 = StringSplit($tmp2[2],"--",1)
						If not StringInStr($tmp2[1],$tmp[1]) Then ExitLoop
						
						$line = StringSplit($line,"=")
						$line = StringSplit($line[2],"--",1)
						$tmp2[1] = StringReplace($tmp2[1],$tmp[1],$line[1])
						$func[$li2] = $tmp[1] & " = (" & $tmp2[1] & ")--" & $tmp2[2]
						$faa[$fi] = $func
						_ArrayDelete($faa[$fi],$li)
						ContinueLoop 2
						;ExitLoop
					ElseIf StringInStr($func[$li2],$tmp[1]) Then
						$line = StringSplit($line,"=")
						$line = StringSplit($line[2],"--",1)
						$func[$li2] = StringReplace($func[$li2],$tmp[1],$line[1])
						$faa[$fi] = $func
						_ArrayDelete($faa[$fi],$li)
						ContinueLoop 2
						;ExitLoop
					EndIf
				Next
				;_ArrayDelete($faa[$fi],$li)
				;ContinueLoop
				
			ElseIf StringRight($line,15) = "REPLACE-REPLACE" Then
				$tmp = StringSplit($line,"--",1)
				$tmp = StringSplit($tmp[2]," ")
				For $li2 = $li+1 To UBound($func)-1
					If StringInStr($func[$li2],$tmp[1] & " =") Then
						Dim $tmp2 = StringSplit($func[$li2],"=")
						$tmp2 = StringSplit($tmp2[2],"--",1)
						If not StringInStr($tmp2[1],$tmp[1]) Then ExitLoop
						
						$line = StringSplit($line,"=")
						$line = StringSplit($line[2],"--",1)
						$tmp2[1] = StringReplace($tmp2[1],$tmp[1],$line[1])
						$func[$li2] = $tmp[1] & " = " & $tmp2[1] & "--" & $tmp2[2]
						$faa[$fi] = $func
						_ArrayDelete($faa[$fi],$li)
						ContinueLoop 2
						;ExitLoop
					ElseIf StringInStr($func[$li2],$tmp[1]) Then
						$line = StringSplit($line,"=")
						$line = StringSplit($line[2],"--",1)
						$func[$li2] = StringReplace($func[$li2],$tmp[1],$line[1])
						$faa[$fi] = $func
						_ArrayDelete($faa[$fi],$li)
						ContinueLoop 2
						;ExitLoop
					EndIf
				Next
				;_ArrayDelete($faa[$fi],$li)
				;ContinueLoop
				
			ElseIf StringRight($line,19) = "PRIMITIVE-PRIMITIVE" Then
				$tmp = StringSplit($line,"--",1)
				$tmp = StringSplit($tmp[2]," ")
				For $li2 = $li+1 To UBound($func)-1
					If StringInStr($func[$li2],$tmp[1] & " =") Then
						Dim $tmp2 = StringSplit($func[$li2],"=")
						$tmp2 = StringSplit($tmp2[2],"--",1)
						If not StringInStr($tmp2[1],$tmp[1]) Then ExitLoop
						
						$line = StringSplit($line,"=")
						$line = StringSplit($line[2],"--",1)
						$tmp2[1] = StringReplace($tmp2[1],$tmp[1],$line[1])
						$func[$li2] = $tmp[1] & " = " & $tmp2[1] & "--" & $tmp2[2]
						$faa[$fi] = $func
						_ArrayDelete($faa[$fi],$li)
						ContinueLoop 2
						;ExitLoop
					ElseIf StringInStr($func[$li2],$tmp[1]) Then
						$line = StringSplit($line,"=")
						$line = StringSplit($line[2],"--",1)
						$func[$li2] = StringReplace($func[$li2],$tmp[1],$line[1])
						$faa[$fi] = $func
						_ArrayDelete($faa[$fi],$li)
						ContinueLoop 2
						;ExitLoop
					EndIf
				Next
				;_ArrayDelete($faa[$fi],$li)
				;ContinueLoop
				
			EndIf
			$li = $li + 1
		WEnd
		
		Dim $maxInVar = -1
		$func = $faa[$fi]
		for $li = 0 to UBound($faa[$fi])-1
			If StringInStr($func[$li],"INPUT_VAR_") Then
				$tmp = StringSplit($func[$li],"INPUT_VAR_",1)
				$tmp = StringSplit($tmp[2],"_")
				$maxInVar = _Max(Number($tmp[1]),$maxInVar)
			EndIf
		Next
		For $i = 0 to $maxInVar
			$func[0] = StringLeft($func[0],StringLen($func[0])-1) & "INPUT_VAR_" & $i & "_,)"
		Next
		If StringRight($func[0],2) = ",)" Then $func[0] = StringLeft($func[0],StringLen($func[0])-2) & ")"
		$faa[$fi] = $func
		
		Dim $varList[1]
		for $li = 0 to UBound($faa[$fi])-1
			If StringLeft($func[$li],4) = "var_" Then
				$tmp = StringSplit($func[$li]," ")
				$tmp = StringSplit($tmp[1],".")
				If _ArraySearch($varList,$tmp[1]) = -1 Then
					_ArrayAdd($varList,$tmp[1])
					$func[$li] = "local " & $func[$li]
				EndIf
			EndIf
		Next
		$faa[$fi] = $func
	Next
EndFunc

