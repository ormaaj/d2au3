;----------------------------------------------------------------------
;Func IniReadItem($sPickit)
;$sPickit - Name of pickit file
;Returns: 	1 - Success Read
;			0 - Bad File Name
;----------------------------------------------------------------------
Func IniReadItem($sPickit)
	Local $tOpt[6] = [ "!=", ">=", "<=", "=", "<", ">" ] ; Every possible Operator
	Local $tFile, $t = 0, $d = UBound($xPick), $iStat = 1, $i, $b ;Just local variables
	_FileReadToArray(@ScriptDir & "\Config\Pickit\" & $sPickit, $tFile); Read whole pickit file into an array
	If @error Then Return 0; Return if bad pickit file name.
	For $i = 1 To $tFile[0] Step 1; Start Loop of pickit
		If StringLeft($tFile[$i], 1) = ";" Then ContinueLoop;Checks for a comment
		If StringLen(StringStripWS($tFile[$i],8)) = 0 Then ContinueLoop;Checks for a blank line
		If StringLeft($tFile[$i], 1) = "[" Then;If New Item
			Local $tCol = StringTrimLeft(StringStripWS($tFile[$i], 3),1), $t;Get Name like [Amulet]
			$sItem = StringTrimLeft($tCol, 1);Trim left bracket
			$sItem = StringTrimRight($tCol, 1);Trim right bracket
			$d += 1; Increase ItemId
			ReDim $xPick[$d][50][3];Redim Global Pickit Array
			$iStat = 1;Reset Stat counter
			$xPick[$d - 1][0][0] = StringLower($sItem);Enter Item Name into array
			ContinueLoop
		EndIf
		For $b = 0 To 5 Step 1;A operator loop (Loops the 6 operators)
			If StringInStr($tFile[$i], $tOpt[$b])  = 0 Then ContinueLoop;Checks to see if operator is in line
			$tFile[$i] = StringReplace($tFile[$i], $tOpt[$b], chr(09));Replaces operator with a Split friendly character
			Local $sStr = StringSplit($tFile[$i], Chr(09));Split Item Stat
			_CleanWS($sStr);Clean Whitespaces (At beginning and end) in the array
			If $sStr[0] <> 2 Then ContinueLoop 2; Insures that we have a proper stat
			If $sStr[1] = "Quality" Then;Checks for a unique stat(Quality as it is a Actual Pickit stat(When you check Items(Yes I did a sub-sub comment))
				For $h = 0 To 6 Step 1; Starts quality loop check
					If $cColor[$h] = $sStr[2] Then;Compares colors
						$xPick[$d - 1][0][1] = $h;Puts color id into array (Easier then actual name)
						ContinueLoop 3;Start new line(As we fully parse this one)
					EndIf
				Next
			EndIf
			$xPick[$d - 1][0][2] = $iStat; Increases number of stats for this item
			$xPick[$d - 1][$iStat][0] = $sStr[1];Stat Name(In pickit form, like MaxDmg)
			$xPick[$d - 1][$iStat][1] = $tOpt[$b];Operator to use (To be used in _Comparison())
			$xPick[$d - 1][$iStat][2] = $sStr[2];Stat Value
			$iStat += 1;Increase stat number
		Next
	Next
EndFunc

;----------------------------------------------------------------------
;Func _Comparison ($sOpt, $sComp1, $sComp2)
;$sOpt - Operator to test
;$sComp1 - First value to compare
;$sComp2 - Second value to compare
;Returns: 	1 - True
;			0 - False
;----------------------------------------------------------------------
Func _Comparison ($sOpt, $sComp1, $sComp2)
	Switch $sOpt
		Case "="
			If $sComp1 <> $sComp2 Then Return 0
		Case ">"
			If $sComp1 <= $sComp2 Then Return 0
		Case "<"
			If $sComp1 >= $sComp2 Then Return 0
		Case "<="
			If $sComp1 > $sComp2 Then Return 0
		Case ">="
			If $sComp1 < $sComp2 Then Return 0
		Case "!="
			If $sComp1 = $sComp2 Then Return 0
		Case Else
			Return -1
	EndSwitch
	Return 1
EndFunc   ;==>_Comparison

;----------------------------------------------------------------------
;Func _CleanWS(ByRef $sStr)
;$sStr - The string or 1D Array you want to clean of front and back whitespace
;Returns:	1 - Cleaned
;----------------------------------------------------------------------
Func _CleanWS(ByRef $sStr)
	If IsArray($sStr) = 1 Then;Arr
		For $n = 0 To UBound($sStr) - 1 Step 1
			$sStr[$n] = StringStripWS($sStr[$n], 3)
		Next
		Return 1
	EndIf
	$sStr = StringStripWS($sStr, 3)
	Return 1
EndFunc

;----------------------------------------------------------------------
;Func ReadPickit ()
;Reads all wanted pickit files into array with all stats
;----------------------------------------------------------------------
Func ReadPickit ()
Global $xPick[1][50][3]
Local $sPick
_FileReadToArray(@ScriptDir & "\Config\Pickit.ini", $sPick)
If @error Then Return
For $m = 1 To $sPick[0] Step 1
	If StringLeft($sPick[$m], 1) = ";" Then ContinueLoop
	_CleanWS($sPick[$m])
	IniReadItem($sPick[$m])
Next
Return 1
EndFunc