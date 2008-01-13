;======------------=========
;------Path_Common.au3------
;======------------=========

Func DetectAct ()
	SendKey("ClearScreen")
	SendKey("Quest")
	Switch PixelChecksum($cAct[0][0], $cAct[0][1], $cAct[0][2], $cAct[0][3], 2)
		Case $cAct[1][0];Act1
			LogEvent(0, "The bot is currently in " & $cAct[1][1])
			SendKey("ClearScreen")
			Return 1
		Case $cAct[2][0];Act2
			LogEvent(0, "The bot is currently in " & $cAct[2][1])
			SendKey("ClearScreen")
			Return 2
		Case $cAct[3][0];Act3
			LogEvent(0, "The bot is currently in " & $cAct[3][1])
			SendKey("ClearScreen")
			Return 3
		Case $cAct[4][0];Act4
			LogEvent(0, "The bot is currently in " & $cAct[4][1])
			SendKey("ClearScreen")
			Return 4
		Case $cAct[5][0];Act5
			LogEvent(0, "The bot is currently in " & $cAct[5][1])
			SendKey("ClearScreen")
			Return 5		
		Case Else
			LogEvent(0, "The bot could not properly detect the current act.")
			SendKey("ClearScreen")
			Return 0
	EndSwitch
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
