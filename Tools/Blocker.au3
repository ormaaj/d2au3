ClipPut("")
Opt("MouseCoordMode", 2)
Opt("PixelCoordMode", 2)
Opt("WinTitleMatchMode", 4)
Opt("GUIOnEventMode", 1) 
Opt("TrayIconDebug", 1)

Global $sLeft = 0, $sRight = 800, $sTop = 0, $sBottom = 600
WinActivate("ClassName=Diablo II")
WinMove("ClassName=Diablo II", '', 0, 0)
Global $Letter = 0
Global $Let[4] = [ "W", "T", "BW", "BT" ]
Global $CoordMaker[1][7]

HotKeySet("{NUMPADDIV}", "GenerateCoords")
HotKeySet("{NUMPADADD}", "AddCoords")
HotKeySet("{NUMPAD7}", "SetTopLeft")
HotKeySet("{NUMPAD3}", "SetBottomRight")
HotKeySet("{NUMPAD5}", "ChangeLetter")

While 1
	Sleep(50)
	BlockWalk($sLeft, $sTop, $sRight, $sBottom, 0, 0)
WEnd
	
Func BlockWalk($xLeft, $xTop, $xRight, $xBottom, $xRelX, $xRelY, $xColor=1637376)
	Local $sPixel = PixelSearch($xLeft, $xTop, $xRight, $xBottom, $xColor, 2, 10)
	If @error Then
		ToolTip("Block unavailble",0,0)
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
	$sPixel[0] = Number($sRight - 18)
	$sPixel[1] = Number($sBottom - 34)
	$sPos = MouseGetPos()
	ToolTip("RelX: " & $sPos[0] - $sPixel[0] & "RelY: " & $sPos[1] - $sPixel[1],0,0) 
	Local $sRet[2] = [ $sPos[0] - $sPixel[0], $sPos[1] - $sPixel[1] ]
	Return $sRet
EndFunc

Func SetTopLeft()
	Local $sJ = MouseGetPos ()
	$sTop = $sJ[1] 
	$sLeft = $sJ[0]
	ToolTip("Set Top-Left Coords",0,0)
	Sleep(500)
EndFunc

Func ChangeLetter ()
	$Letter += 1
	If $Letter > 3 Then $Letter = 0
	ToolTip("Set to " & $Let[$Letter], 0, 0)
	Sleep(500)
EndFunc

Func SetBottomRight ()
	Local $sJ = MouseGetPos ()
	$sBottom = $sJ[1]
	$sRight = $sJ[0]
	ToolTip("Set Bottom-Right Coords",0,0)
	Sleep(500)
EndFunc

Func AddCoords ()
	If StringLeft($Let[$Letter], 1) <> "B" Then
	Local $sLawl = BlockWalk($sLeft, $sTop, $sRight, $sBottom, 0, 0)
	EndIf
	$sPos = MouseGetPos()
	Local $sU = UBound($CoordMaker) + 1
	ReDim $CoordMaker[$sU][7]
	$CoordMaker[0][0] += 1
	$CoordMaker[$sU - 1][0] = $Let[$Letter]
	$CoordMaker[$sU - 1][1] = $sLeft
	$CoordMaker[$sU - 1][2] = $sTop
	$CoordMaker[$sU - 1][3] = $sRight
	$CoordMaker[$sU - 1][4] = $sBottom
	If StringLeft($Let[$Letter], 1) <> "B" Then
		$CoordMaker[$sU - 1][5] = $sLawl[0]
		$CoordMaker[$sU - 1][6] = $sLawl[1]
	Else
		$CoordMaker[$sU - 1][5] = $sPos[0]
		$CoordMaker[$sU - 1][6] = $sPos[1]
	EndIf
	MouseClick("left", $sPos[0], $sPos[1])
	ToolTip("Currently " & $CoordMaker[0][0] & " steps.")
	Sleep(500)
EndFunc

Func GenerateCoords ()
	Local $sStr = "Global $p[" & $CoordMaker[0][0] + 1 & "][7] = [ _" & @CRLF & "[ " & $CoordMaker[0][0] & ', 0, "", "" ], _' & @CRLF
	For $i = 1 To $CoordMaker[0][0] Step 1
		If StringLeft($CoordMaker[$i][0], 1) <> "B" Then
			$sStr &= '[ "' & $CoordMaker[$i][0] & '", ' & $CoordMaker[$i][1] & ", " & $CoordMaker[$i][2] & ", " & $CoordMaker[$i][3] & ", " & $CoordMaker[$i][4] & _
			", " & $CoordMaker[$i][5] & ", " & $CoordMaker[$i][6] & " ], _" & @CRLF
		Else
			$sStr &= '[ "' & $CoordMaker[$i][0] & '", ' & $CoordMaker[$i][5] & ", " & $CoordMaker[$i][6] & "], _" & @CRLF
		EndIf
	Next
	ClipPut(StringTrimRight($sStr, 5) & "]")
	$CoordMaker = 0
	Global $CoordMaker[1][7]
	ToolTip("Added Path Array to clipboard, clearing.", 0, 0)
	Sleep(500)
EndFunc