Opt("PixelCoordMode", 2)
Opt("MouseCoordMode", 2)
WinActivate("Diablo II")
Sleep(100)
Local $sI = ItemClick("Stash", 1, 0, "left")
#include <Array.au3>
#include <Date.au3>
;~ _ArrayDisplay($sI)

Func ItemClick($sArea, $sX, $sY, $sSide, $sDown=0)
	Local $sPos = MouseInv($sArea, $sX, $sY)
	If $sDown <> 0 Then SendKey($sDown, "DOWN", 1)
;~ 	MouseClick($sSide, $sPos[0], $sPos[1])
	If $sDown <> 0 Then SendKey($sDown, "UP", 1)
	Return 1
EndFunc

Func MouseInv($Area, $X, $Y)
	Switch $Area
		Case "Inv"
			$z_s = 3
			$i_s = 9
			$bx = 418
			$by = 316
		Case "NPC"
			$z_s = 9
			$i_s = 9
			$bx = 95
			$by = 124
		Case "Stash"
			$z_s = 7
			$i_s = 5
			$bx = 153
			$by = 143
		Case "Belt"
			$z_s = 3
			$i_s = 3
			$bx = 422
			$by = 467
			$xid = 31
			$yid = 32
	EndSwitch	
	Sleep(Random(100, 200))
	LogEvent(2, $X & " " & $Y & " " & ($bx + ($X * 29) + 15) & " " & ($by + ($Y * 29) + 15))
	MouseMove($bx + ($X * 29) + 15, $by + ($Y * 29) + 15, 5)
	Sleep(Random(100, 200))
	Local $sRet[2] = [ $bx + ($X * 29) + 15, $by + ($Y * 29) + 15 ]
	Return $sRet
EndFunc

Func LogEvent($pType, $pMsg)
	Local $lType[4] = [ "M", "W", "E", "D" ]
	If $pType < 0 Or $pType > 3 Then Return 0
	If $pType = 3 AND IsDeclared("Debug") = 0 Then Return
	Local $lFo = FileOpen(@ScriptDir & "\..\..\Logs\mmBOT.log", 1)
	if @error Then Return -1
	FileWriteLine($lFo, "[" & _Now () & "][" & $lType[$pType] & "]-> " & $pMsg)
	FileClose($lFo)
	Return 1
EndFunc