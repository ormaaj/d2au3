#include-once

Func Stash ($sData)
	If Check("Stash") = 0 Then 
		LogEvent(1, "We are not in stash and stashing function was called, cancel.")
		Return 0;Not in stash then we can't do shit.
	EndIf
	LogEvent(0, "Starting stashing sequence.")
	Local $sStash = Database("Stash")
	Local $sStashCounter = 0
	Local $sMove = DatabaseCompare("Inv", $sData)
	For $x = 0 To 3 Step 1
		For $y = 0 To 9 Step 1
			If $sMove[$x][$y] = "0" Then ContinueLoop
			$tItem = ReadItem($y, $x)
			If $tItem[0][0] = '' Then ContinueLoop
			LogEvent(3, "Found item '" & $tItem[0][0] & "' in inventory, looking for stash spot.")
			For $sStashX = 0 To 7 Step 1
				For $sStashY = 0 To 5 Step 1
					If $sStash[$sStashX][$sStashY] = "1" Then ContinueLoop
					For $xSt = $sStashX To $sStashX + $tItem[0][6] - 1 Step 1
						If $xsT > 7 Then ContinueLoop 2
						For $ySt = $sStashY To $sStashY + $tItem[0][5] - 1 Step 1
							If $ysT > 5 Then ContinueLoop 3
							If $sStash[$xSt][$ySt] = "1" Then ContinueLoop 3
						Next
					Next
					LogEvent(3, "Found stash spot, moving item to spot.")
					ItemClick("Inv", $y, $x, "left")
					Sleep(250)
					Local $sClickX = $sStashX, $sClickY = $sStashY
					If $tItem[0][5] > 1 Then $sClickY += Number($tItem[0][5] / 2) - 0.6
					If $tItem[0][6] > 1 Then $sClickX += Number($tItem[0][6] / 2) - 0.6
					ItemClick("Stash", $sClickY, $sClickX, "left")
					$sStashCounter += 1
					MoveMouse ()
					For $mX = $x To $x + $tItem[0][6] - 1 Step 1
						For $mY = $y To $y + $tItem[0][5] - 1 Step 1
							$sMove[$mX][$mY] = "0"
						Next
					Next	
					For $mX = $sStashX To $sStashX + $tItem[0][6] - 1 Step 1
						For $mY = $sStashY To $sStashY + $tItem[0][5] - 1 Step 1
							$sStash[$mX][$mY] = "1"
						Next
					Next
					ContinueLoop 3
				Next
			Next
			For $mX = $x To $x + $tItem[0][6] - 1 Step 1
				For $mY = $y To $y + $tItem[0][5] - 1 Step 1
					$sMove[$mX][$mY] = "0"
				Next
			Next	
			LogEvent(1, "Unable to stash " & $tItem[0][0] & " due to insuffient space in stash.")		
			$sStashCounter -= 1
		Next
	Next
	Local $sGold = GetInvGold ()
	If $sGold >= $iStashGoldAm Then
		SlowClick("left", 496, 461)
		SendKey("ENTER", "PRESS", 1)
		LogEvent(0, "Moved " & $sGold & " gold into stash.")
	EndIf
	LogEvent(0, "Stash sequence done, stashed " & $sStashCounter & " items.")
EndFunc

Func NeedToStash ($Data, $sClearScreen=0)
	Local $sInfo = DatabaseCompare("Inv", $Data, 0)
	Local $sGold = GetInvGold ()
	If $sClearScreen = 1 Then SendKey("ClearScreen")
	For $c = 0 To UBound($sInfo) - 1 Step 1
		For $x = 0 To UBound($sInfo, 2) - 1 Step 1
			If $sInfo[$c][$x] = "1" Then Return 1
		Next
	Next
	If $sGold >= $iStashGoldAm Then Return 1
	Return 0
EndFunc