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
	If @error Then
		MsgBox(1, "D2Au3 Error", "Failed to read pickit loading file.")
		LogEvent(2, "The pickit loading file does not exist.")
		Exit
	EndIf
	_CleanWS($sPickitList);Clean up whitespaces
	For $m = 1 To $sPickitList[0] Step 1;Start the loop of all the ALL pickit files
		If StringLeft($sPickitList[$m], 1) = ";" Then ContinueLoop;Check for commented files
		_FileReadToArray(@ScriptDir & "\Config\Pickit\" & $sPickitList[$m], $xPickitRead);Read in first pickit file
		If @error Then ContinueLoop
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

;--------------------------------------------------------
;Func FocusBox ($pX, $pY, $pColor)
;$pX - X point of general area of the big box
;$py - Y point of general area of the big box
;$pColor - Color of the big box
;On Success
;	Array with the right bottom corner of the box (The exact level for the little dots), and color that you gave in the first place
;On Fail
;	Returns 0
;Remarks:
;	This will take a spot that you find (Somewhere in the big boxes next to item names)
;	and checks to see if it is a big box, if it is then returns the coords for reading and color.
;--------------------------------------------------------
Func FocusBox ($pX, $pY, $pColor)
	Local $lSearch, $lBaseY
		Local $lRight = $pX
		;Keeps going right until you hit the end of the big box
		Do
			$lRight += 1
		Until PixelGetColor($lRight, $pY) <> $pColor
		Local $lLeft = $pX
		;Keep going until you hit the left side of the big box
		Do
			$lLeft -= 1
		Until PixelGetColor($lLeft, $pY) <> $pColor
		If $lRight - $lLeft < 45 Then Return 0 ;Check to see if we are looking at a big box
		Local $lBottom = $pY + 2
		;Find bottom of big box (End result is the Y value where the little dots are)
		Do
			$lBottom += 1
		Until PixelGetColor($pX, $lBottom) <> $pColor
		$lBottom -= 2
		Local $sRet[4] = [ $lRight, $lBottom, $pColor ];Creates array to return
		Return $sRet
EndFunc

;--------------------------------------------------------
;Func Pickit($pAct, $pScan = 3)
;$pAct - Act you are currently in (So you can use proper colors)
;$pScan - Amount of times to check for items (3 is good)
;Returns number of items picked up
;--------------------------------------------------------
Func Pickit($pScan = 3)
	Local $pAct = GetAct ()
	SendKey("ShowItems", "Down")
	Local $xPick, $yPick, $sPix, $c, $sFocus, $cColors = -1, $sScan, $sLog, $sItem = 0;Local Variables
	For $sScan = 0 TO $pScan Step 1; Amount of scans
		For $yPick = 0 To 600 Step 11; The Y Axis (Up to down)
			For $xPick = 0 To 800 Step 49; The X Axis (Left to Right)
				$sCol = _FindColor($pAct, PixelGetColor($xPick, $yPick));Checks to see if we hit a "Quality" color.
				If $sCol = -1 Then ContinueLoop;try again if we failed
				$sFocus = FocusBox($xPick, $yPick, $cItemColors[$pAct][$sCol]);Check to see if it is a real box
				If $sFocus <> 0 Then 
					$sItem = ReadLine($sFocus[0], $sFocus[1], $sFocus[2]);Read Item name
					If StringLen($sItem) < 2 Then ContinueLoop; Insure we didn't find something it thinks is a box, but really is something stupid
					If CheckItem(StringLower($sItem), $sCol) = 1 Then ;Checks item to pickit
						SlowClick("left", $sFocus[0] - 15, $sFocus[1] - 5);Does a nice slow click to grab it
						MoveMouse(); Moves mouse to insure no interference with hunt
						$sItem += 1;Increases picked items
					EndIf
				EndIf
			Next
		Next
	Next
	SendKey("ShowItems", "Up")
	Return $sItem
EndFunc
	
		