#include-once
;Common_Funcs.au3

Func LogEvent($pType, $pMsg)
	Local $lType[4] = [ "M", "W", "E", "D" ]
	If $pType < 0 Or $pType > 3 Then Return 0
	If $pType = 3 AND IsDeclared("Debug") = 0 Then Return
	Local $lFo = FileOpen(@ScriptDir & "\Logs\mmBOT.log", 1)
	if @error Then Return -1
	FileWriteLine($lFo, "[" & _Now () & "][" & $lType[$pType] & "]-> " & $pMsg)
	FileClose($lFo)
	Return 1
EndFunc

Func SendKey($pKey, $sType="PRESS", $sRaw=0)
	If $sRaw = 0 Then
		Local $lKey = Eval("k" & $pKey)
		If @error Then
			LogEvent(1, "Key '" * $pKey & " is an invalid key name.")
			Return 0
		EndIf
		Local $lRawKey = $iKey[$lKey]
	Else
		$lRawKey = $pKey
	EndIf
	If $sType = "PRESS" Then
	Switch StringUpper($lRawKey)
		Case "SHIFT"
			$lRawKey = "{LSHIFT"
		Case "ALT"
			$lRawKey = "{ALT"
		Case "CTRL"
			$lRawKey = "{LCTRL"
		Case "WIN"
			$lRawKey = "{LWIN"
		Case Else
			$lRawKey = "{" & $lRawKey
	EndSwitch
	EndIf
	Switch StringUpper($sType)
		Case "PRESS";Press up and down
			$lRawKey &= "}"
		Case "DOWN"
		Switch StringUpper($lRawKey)
			Case "SHIFT"
				$lRawKey = "{SHIFTDOWN}"
			Case "ALT"
				$lRawKey = "{ALTDOWN}"
			Case "CTRL"
				$lRawKey = "{CTRLDOWN}"
			Case "WIN"
				$lRawKey = "{LWINDOWN}"
			Case Else
				$lRawKey = "{" & $lRawKey & " DOWN}"
		EndSwitch
		Case "UP"
		Switch StringUpper($lRawKey)
			Case "SHIFT"
				$lRawKey = "{SHIFTUP}"
			Case "ALT"
				$lRawKey = "{ALTUP}"
			Case "CTRL"
				$lRawKey = "{CTRLUP}"
			Case "WIN"
				$lRawKey = "{LWINUP}"
			Case Else
				$lRawKey = "{" & $lRawKey & " UP}"
		EndSwitch
EndSwitch
	Send($lRawKey)
	Sleep(Random(500, 1000))
	Return 1
EndFunc

Func SlowClick($Side, $X, $Y)
	Sleep(Random(50, 100))
	MouseMove($X, $Y, 10)
	Sleep(Random(50, 100))
	MouseClick($Side, $X, $Y, 1, 10)
	Sleep(Random(50, 100))
EndFunc

Func FastClick($Side, $X, $Y)
	Sleep(Random(20, 50))
	MouseMove($X, $Y, 1)
	Sleep(Random(20, 50))
	MouseClick($Side, $X, $Y, 1, 2)
EndFunc

Func MoveMouse ()
	MouseMove(800, 0,1)
	Sleep(Random(50, 100))
	MouseMove(800, 0,1)
	Sleep(Random(50, 100))
EndFunc

Func TeleCheck($sTimeout, $sDelay)
	Local $sTime = TimerInit ()
	Do
	Sleep(100)
	Local $sPix[2][6]
	For $i = 1 To 5 Step 1
		$sPix[0][$i] = PixelGetColor(($i * 50), ($i * 50))
	Next
	For $i = 1 To 5 Step 1
		$sPix[1][$i] = PixelGetColor(($i * 50), 300-($i * 50))
	Next
	Sleep($sDelay)
	Local $sPixx[2][6]
	For $i = 1 To 5 Step 1
		$sPixx[0][$i] = PixelGetColor(($i * 50), ($i * 50))
	Next
	For $i = 1 To 5 Step 1
		$sPixx[1][$i] = PixelGetColor(($i * 50), 300-($i * 50))
	Next
	Local $sCor = 0
	For $x = 0 To 1 Step 1
		For $b = 1 To 5 Step 1
			If $sPix[$x][$b] = $sPixx[$x][$b] Then $sCor += 1
		Next
	Next
	If $sCor > 7 Then Return
	Until TimerDiff($sTime) > $sTimeout
EndFunc

Func Check($Screen)
Local $sEv = Eval("c" & $Screen)
If IsArray($sEv) = 0 Then
	LogEvent(1, $Screen & " does not exist.")
	Return -1
EndIf
Local $sPix = PixelChecksum($sEv[0], $sEv[1], $sEv[2], $sEv[3], 2)
If $sPix = $sEv[4] Then Return 1
Return 0
EndFunc