;----------------------------------------------------------------------
;Func ReadPickit ()
;Reads in all the pickit files into a 4 dimesion'd array
;$xPick[x][x][x][x]
	;'[1] = Item
	;[50] = Stats (40% ED) or (7+ TO Amazon Skills)
	;[3] = Sub Stat (40% ED) or (7) and (Amazon)
	;[2] = [0] = Comparison operator (=, >=, <) ; [1] = Stat
;----------------------------------------------------------------------	
Func ReadPickit ()
	Global $xPick[1][1][4][2];Declare Global Pickit Aray
	Local $cIt = 0, $cStat = 0, $cSubStat = 1, $sPickitList, $xPickitRead;Local variables
	Local $tOpt[6] = [ "!=", ">=", "<=", "=", "<", ">" ] ; Every possible Operator
	_FileReadToArray(@ScriptDir & "\Config\Au3.Pickit.ini", $sPickitList);Read in the pickit chooser(Which pickit files to load)
	_CleanWS($sPickitList);Clean up whitespaces
	For $m = 1 To $sPickitList[0] Step 1;Start the loop of all the ALL pickit files
		If StringLeft($sPickitList[$m], 1) = ";" Then ContinueLoop;Check for commented files
		_FileReadToArray(@ScriptDir & "\Config\Pickit\" & $sPickitList[$m], $xPickitRead);Read in first pickit file
		_CleanWS($xPickitRead);Clean up whitespaces in pickit file
		For $x = 1 To $xPickitRead[0] Step 1;Start loop of pickit
			If StringLeft($xPickitRead[$x], 1) = ";" Then ContinueLoop;Check for comment
			If StringLen(StringStripWS($xPickitRead[$x],8)) = 0 Then ContinueLoop;Checks for a blank line
			If StringLeft($xPickitRead[$x], 1) = "[" Then;Checks for a new item
				$sItem = StringRegExp($xPickitRead[$x], "\[(.+?)\]", 3);Reads in name (Using RegExp)
				$cIt += 1;Increase amount of items we have in our pickit array
				$cStat = 0;Reset stat counter
				ReDim $xPick[$cIt + 1][50][3][2];Redim array so we can put new item in
				$xPick[$cIt][0][0][0] = $sItem[0];Put item name in as base
			EndIf
			Local $sItemStat = StringSplit($xPickitRead[$x], ":");Splits the stat by the delim (:)
			If @error Then ContinueLoop;Continues file if bad line (Missing delims)
			If $sItemStat[1] = "Quality" Then;Check to see if the stat is a special stat(Quality)
				$xPick[$cIt][0][0][1] = _ConvertQuality(StringTrimLeft($sItemStat[2], 1));Convert quality name to an number and store in array
				ContinueLoop;Continue with next stat
			EndIf
			$cStat += 1;Increases stat counter
			$xPick[$cIt][$cStat][0][0] = $sItemStat[1];Adds base stat name(Like Life) to array
			For $u = 2 To $sItemStat[0] Step 1;Loops all the values for the stat (Put incase we have 2 or more values like Adds [x]-[x] cold damage)
				For $v = 0 To 5 Step 1;Loop all the operators
					If StringInStr($sItemStat[$u], $tOpt[$v]) = 0 Then ContinueLoop;Compare to find operator
					$xPick[$cIt][$cStat][$cSubStat][0] = $tOpt[$v];Store Operator
					$xPick[$cIt][$cStat][$cSubStat][1] = StringTrimLeft($sItemStat[$u], StringLen($tOpt[$v]));Store Value
					$cSubStat += 1;Increase substat counter
					ExitLoop;Leave operator loop(To do next substat)
				Next
			Next
			$cSubStat = 1;Reset substat counter
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
;Func _ConvertQuality($sQual)
;$sQual - Name of quality
;Return		-1 - Bad quality name enter
;Return		0-6 - Quality number
;----------------------------------------------------------------------
Func _ConvertQuality($sQual)
Local Const Enum $gWhite, $gGrey, $gMagic, $gRare, $gSet, $gUnique, $gCrafted
Local $sE = Eval("g" & $sQual)
If @error Then Return -1
Return $sE
EndFunc

		