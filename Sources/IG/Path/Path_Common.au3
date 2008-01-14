;======------------=========
;------Path_Common.au3------
;======------------=========

Func DetectAct ()
	Send($Key_ClearScreen)
	Send($Key_Quest)
		
	If PixelChecksum($Act1[1], $Act1[2], $Act1[3], $Act1[4], $Act1[5]) Then			; Check Pixel Checksum for Act 1
		LogEvent(0, "Act 1 Detected")
		Send($Key_ClearScreen)
		Return 1
	ElseIf PixelChecksum($Act2[1], $Act2[2], $Act2[3], $Act2[4], $Act2[5]) Then		; Check Pixel Checksum for Act 2
		LogEvent(0, "Act 2 Detected")
		Send($Key_ClearScreen)
		Return 2
	ElseIf PixelChecksum($Act3[1], $Act3[2], $Act3[3], $Act3[4], $Act3[5]) Then		; Check Pixel Checksum for Act 3
		LogEvent(0, "Act 3 Detected")
		Send($Key_ClearScreen)
		Return 3
	ElseIf PixelChecksum($Act4[1], $Act4[2], $Act4[3], $Act4[4], $Act4[5]) Then		; Check Pixel Checksum for Act 4
		LogEvent(0, "Act 4 Detected")
		Send($Key_ClearScreen)
		Return 4
	ElseIf PixelChecksum($Act5[1], $Act5[2], $Act5[3], $Act5[4], $Act5[5]) Then		; Check Pixel Checksum for Act 5
		LogEvent(0, "Act 5 Detected")
		Send($Key_ClearScreen)
		Return 5
	Else
		LogEvent(1, "Could not detect Act")
		Send($Key_ClearScreen)
		Return 0
	EndIf
EndFunc

Func FromMapBlockClick($RelativeX, $RelativeY, $Act)
	Local $Prec = 5
	Local $xColor = PixelSearch(1, 1, 800, 485, $cPath[$Act], 0, 1)
	If Not @error Then
		$MouseCoordX = 400 + (($xColor[0] - $RelativeX) * 10)
		$MouseCoordY = 285 + (($xColor[1] - $RelativeY) * 10)
		If ($MouseCoordX < 0) Or ($MouseCoordX > 800) Or ($MouseCoordY < 0) Or ($MouseCoordY > 550) Then
            LogEvent(2, "Pathing error: Act " & $Act & " RelX " & $RelativeX & " RelY " & $RelativeY &  " out of bounds.")
			Return 0
        EndIf
		MouseMove($MouseCoordX, $MouseCoordY,0)
		Sleep(50)
		MouseDown("left")
		Do ;This is the move time calculator , moves will be verry clean and quick
			$Col = PixelSearch(1,1,800,485,$cPath[$Act],0,1)
			If @Error Then
				ExitLoop
			EndIf
			Sleep(500)
		Until (($Col[0] > ($RelativeX - $Prec)) And ($Col[0] < ($RelativeX + $Prec))) And (($Col[1] > ($RelativeY - $Prec)) And ($Col[1] < ($RelativeY + $Prec)))
        MouseUp("Left")
		Return 1
	EndIf
	LogEvent(2, "Unable to find pathing block.")
	Return 0
EndFunc
	
Func Pather($Act, $Start, $End)
	Local $sPath = Eval("pA" & $Act & $Start & "To" & $End)
	If @error OR UBound($sPath, 2) <> 2 Then
		LogEvent(2, "Pathing error: Path 'A" & $Act & $Start & "To" & $End & "' doesn't exist.")
		Return 0
	EndIf
	For $b = 0 To UBound($sPath) -1 Step 1
		If FromMapBlockClick($sPath[$b][0], $sPath[$b][1], $Act) = 0 Then
			LogEvent(2, "Path 'A" & $Act & $Start & "To" & $End & "' failed at point " & $b)
			Return 0
		EndIf
	Next
	Return 1
EndFunc

;======------------=========
;------Path_Common.au3------
;======------------=========

Func BlockWalk($xLeft, $xTop, $xRight, $xBottom, $xRelX, $xRelY, $xColor=1637376)
	Local $sPixel = PixelSearch($xLeft, $xTop, $xRight, $xBottom, $xColor, 2, 10)
	If @error Then
		Return SetError(1, 1, 0)
	EndIf
	Local $sRight = $sPixel[0]
	Do
		$sRight += 1
	Until PixelGetColor($sRight, $sPixel[1]) <> $xColor
	Local $sBottom = $sPixel[1]
	Do
		$sBottom += 1
	Until PixelGetColor($sPixel[0], $sBottom) <> $xColor
	$sPixel[0] = Number($sRight - 18) + $xRelX
	$sPixel[1] = Number($sBottom - 34) + $xRelY
	Sleep(Random(50, 100))
	MouseMove($sPixel[0], $sPixel[1], 2)
	Sleep(Random(100, 200))
	MouseClick("left", $sPixel[0], $sPixel[1], 1, 3)
	MoveEnd ()
	Return 1
EndFunc

Func Path($Act, $sFrom, $sTo)
	Local $sPathInfo = Eval("pA" & $Act & $sFrom & "To" & $sTo)
	If @error Then
		LogEvent(1, "Pathing array for act " & $Act & " From " & $sFrom & " to " & $sTo & " doesn't exist.")
		Return -1
	EndIf
	For $i = 1 To UBound($sPathInfo) - 1 Step 1
		Sleep(Random(500, 1000))
		Switch $sPathInfo[$i][0]
			Case "W";Walk
				BlockWalk($sPathInfo[$i][1], $sPathInfo[$i][2], $sPathInfo[$i][3], $sPathInfo[$i][4], $sPathInfo[$i][5], $sPathInfo[$i][6])
				If @error Then
					LogEvent(1, "Pathing error: act " & $Act & " From " & $sFrom & " to " & $sTo & " Step: " & $i & "/" & $sPathInfo[0][0] & " Type: Walk")
					ExitLoop
				EndIf
			Case "T";Teleport
				TeleBlock($sPathInfo[$i][1], $sPathInfo[$i][2], $sPathInfo[$i][3], $sPathInfo[$i][4], $sPathInfo[$i][5], $sPathInfo[$i][6])
				If @error Then
					LogEvent(1, "Pathing error: act " & $Act & " From " & $sFrom & " to " & $sTo & " Step: " & $i & "/" & $sPathInfo[0][0] & " Type: Tele")
					ExitLoop
				EndIf
			Case "BT";Blind Teleport
				Teleport($sPathInfo[$i][1], $sPathInfo[$i][2])
				If @error Then
					LogEvent(1, "Pathing error: act " & $Act & " From " & $sFrom & " to " & $sTo & " Step: " & $i & "/" & $sPathInfo[0][0] & " Type: Blind Teleport")
					ExitLoop
				EndIf
			Case "BW";Blind Walk
				BlindWalk($sPathInfo[$i][1], $sPathInfo[$i][2])
				If @error Then
					LogEvent(1, "Pathing error: act " & $Act & " From " & $sFrom & " to " & $sTo & " Step: " & $i & "/" & $sPathInfo[0][0] & " Type: Blind Walk")
					ExitLoop
				EndIf
		EndSwitch
	Next
	Return 1
EndFunc

Func MoveEnd($sDelay=500, $sTimeOut=2500)
	Sleep($sDelay)
	Local $sBase[4], $sDiff[4]
	While TimerDiff($sTime) < $sTimeOut
		$sBase[0] = PixelGetColor(219, 175)
		$sBase[1] = PixelGetColor(585, 175)
		$sBase[2] = PixelGetColor(585, 384)
		$sBase[3] = PixelGetColor(219, 384)
		Sleep($sDelay)
		$sDiff[0] = PixelGetColor(219, 175)
		$sDiff[1] = PixelGetColor(585, 175)
		$sDiff[2] = PixelGetColor(585, 384)
		$sDiff[3] = PixelGetColor(219, 384)
		For $sPixCompare = 0 To 3 Step 1
			If $sBase[$sPixCompare] <> $sDiff[$sPixCompare] Then ContinueLoop 2
		Next
		Return 1
	WEnd
	Return 0
EndFunc

Func Teleport($sX, $sY, $sDelay=200, $sTimeOut=2000)
	Local $sBase[4], $sDiff[4]
	SendKey("Teleport")
	$sBase[0] = PixelGetColor(219, 175)
	$sBase[1] = PixelGetColor(585, 175)
	$sBase[2] = PixelGetColor(585, 384)
	$sBase[3] = PixelGetColor(219, 384)	
	FastClick("Right", $sX, $sY)
	Sleep($sDelay)
	Local $sTime = TimerInit ()
	While TimerDiff($sTime) < $sTimeOut
		$sDiff[0] = PixelGetColor(219, 175)
		$sDiff[1] = PixelGetColor(585, 175)
		$sDiff[2] = PixelGetColor(585, 384)
		$sDiff[3] = PixelGetColor(219, 384)
		For $sPixCompare = 0 To 3 Step 1
			If $sBase[$sPixCompare] <> $sDiff[$sPixCompare] Then ContinueLoop 2
		Next
		Return 1
	WEnd
	Return 0
EndFunc

Func BlindWalk ($sX, $sY)
	Sleep(Random(50, 100))
	MouseMove($sX, $sY, 2)
	Sleep(Random(100, 200))
	MouseClick("left", $sX, $sY, 1, 3)
	MoveEnd ()
	Return 1	
EndFunc

Func NPCForJob($Type, $Act="")
	If $Act = "" Then $Act = GetAct ()
	Switch $Type
		Case "Heal"
			Return $NPCJobs[$Act][2]
		Case "Merc"
			Return $NPCJobs[$Act][7]
		Case "Repair"
			Return $NPCJobs[$Act][4]
		Case "Gamble"
			Return $NPCJobs[$Act][3]
		Case "Aarows"
			Return $NPCJobs[$Act][6]
		Case "Pots"
			Return $NPCJobs[$Act][5]
		Case "ID/TP"
			Return $NPCJobs[$Act][8]
		Case Else
			Return -2
	EndSwitch
EndFunc

Func Interact ($NPC, $Mode)
	Local $sInfo = -1, $sSpot
	For $l = 0 To 16 Step 1
		If $NPCs[$l][0] = $NPC Then
			$sInfo = $l
			ExitLoop
		EndIf
	Next
	If $sInfo = -1 Then
		LogEvent(1, "NPC given for Interact () does not exist " & $NPC)
	EndIf
	Switch $Mode
		Case "Trade"
			If $NPCs[$sInfo][5] = -1 Then
				LogEvent(1, "NPC '" & $NPC & "' does not have Trade support!")
				Return 0
			EndIf
			$sSpot = $NPCs[$sInfo][5]
		Case "Gamble"
			If $NPCs[$sInfo][4] = -1 Then
				LogEvent(1, "NPC '" & $NPC & "' does not have Gamble support!")
				Return 0
			EndIf		
			$sSpot = $NPCs[$sInfo][4]			
		Case "Revive"
			If $NPCs[$sInfo][6] = -1 Then
				LogEvent(1, "NPC '" & $NPC & "' does not have Merc support!")
				Return 0
			EndIf				
			$sSpot = $NPCs[$sInfo][6]
	EndSwitch
	For $h = 1 To 3 Step 1
		If $h <> 1 Then
			LogEvent(0, "Total interact attempt #" & $h)
		EndIf
		For $n = 1 To 3 Step 1
			SendKey("ClearScreen")
			Local $sPix = PixelSearch(0, 0, 800, 600, $NPCs[$sInfo][7], 2, 5)
			If @error Then
				If $n = 3 Then
					LogEvent(2, "Unable to interact with " & $NPC & ", retrying whole interact.")
					ContinueLoop 2
				EndIf
				LogEvent(1, "Trying to interact with " & $NPC & " Retrying Attempt #" & $n & "/3")
				Sleep(750)
				ContinueLoop
			EndIf
			ExitLoop
		Next
		Local $xTemp = $sPix[0]
		Do
			$xTemp += 1
		Until PixelGetColor($xTemp, $sPix[1]) <> $NPCs[$sInfo][7];Right
		Local $yTemp = $sPix[1]
		Do
			$yTemp += 1
		Until PixelGetColor($sPix[0], $yTemp) <> $NPCs[$sInfo][7];bottom
		$xTemp -= $NPCs[$sInfo][2] / 2
		$yTemp -= $NPCs[$sInfo][3] / 2
		SlowClick("left", $xTemp, $yTemp)
		For $b = 1 To 5 Step 1
			Sleep(1000)
			Local $vPix = PixelSearch(0, 0, 800, 600, $NPCs[$sInfo][8], 1, 2)
			If @error Then
				If $b >= 3 Then
					If $b = 5 Then
						LogEvent(1, "Unable to find Malah's screen, reattempting whole interact.")
						ContinueLoop 2
					EndIf
					LogEvent(1, "Trying to find Interact screen Attempt #" & $b - 2 & "/3")
				EndIf
				ContinueLoop
			EndIf
			ExitLoop
		Next
		If $Mode = "Heal" Then
			SendKey("ClearScreen")
			Return 1
		EndIf
		Local $xInt = $vPix[0]
		Do
			$xInt += 1
		Until PixelGetColor($XInt, $vPix[1]) <> $NPCs[$sInfo][8]
		Local $yInt = $vPix[1]
		Do
			$yInt += 1
		Until PixelGetColor($vPix[1], $yInt) <> $NPCs[$sInfo][8]
		Sleep(Random(500, 1000))
		SlowClick("Left", $xInt, $yInt + ($sSpot * 15) + 10)
		Sleep(Random(500, 1000))
		If $Mode = "Revive" Then
			SendKey("ClearScreen")
			Return 1
		EndIf		
		For $c = 1 To 3 Step 1
			Sleep(500)
			If Check("NPCScreen") = 1 Then ExitLoop
			If $c = 3 Then
				LogEvent(1, "Failed to see NPC Trade Window, retrying.")
			EndIf
		Next
		Return 1
	Next
	Return 0
EndFunc

Func TeleBlock($xLeft, $xTop, $xRight, $xBottom, $sX, $sY, $xColor=1637376)
	Local $sPixel = PixelSearch($xLeft, $xTop, $xRight, $xBottom, $xColor, 2, 10)
	If @error Then
;~ 		LogEvent(1, "Failed to find the block.")
;~ 		TPToTown()
		Return SetError(1, 1, 0)
	EndIf
	Local $sRight = $sPixel[0]
	Do
		$sRight += 1
	Until PixelGetColor($sRight, $sPixel[1]) <> $xColor
	Local $sBottom = $sPixel[1]
	Do
		$sBottom += 1
	Until PixelGetColor($sPixel[0], $sBottom) <> $xColor
	$sPixel[0] = Number($sRight - 18) + $sX
	$sPixel[1] = Number($sBottom - 34) + $sY
	Teleport($sPixel[0], $sPixel[1], 200, 2000)
	Return $sPixel
EndFunc