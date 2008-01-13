Opt("PixelCoordMode", 2)
Opt("MouseCoordMode", 2)
Opt("WinTitleMatchMode", 4)
#include <File.au3>
#include <Array.au3>
WinActivate("ClassName=Diablo II")
; "Name", Inv X, Inv Y, BaseX, BaseY, SquareX, SquareY
Global $cInvSize[4][7] = [ _
[ "Inv", 3, 9, 418, 316, 29, 29 ], _
[ "NPC", 9, 9, 95, 124, 29, 29 ], _
[ "Stash", 7, 5, 153, 143, 29, 29 ], _
[ "Belt", 3, 3, 422, 467, 31, 32 ]]

Global $sOpen[5] = [ 383, 559, 413, 589, 3815421329 ]
Global $sColors[2] = [ 16526336, 2384088 ]
Global $CharMode = "Single"
;Heal Pot, Mana Pot, Small Juv, Big Juv, Chicken

Global $cPotDelay = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "PotDrinkDelay", 5000)
Global $cJuvDelay = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "JuvDrinkDelay", 1500)

Global $cRow[4]
For $i = 0 To 3 Step 1
	$cRow[$i] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "DrinkKey" & ($i + 1), ($i + 1))
Next

;--==[Mana Percent's]==--
Global $cMHP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "ManaHealPercent", 70);Use Mana Potion percent
Global $cMJP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "ManaJuvPercent", 50);Use Small Juv Potion percent
Global $cMFJP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "ManaFullJuvPercent", 2);Use Big Juv Potion percent
Global $cMCP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "ManaChickenPercent", -1);Use Mana Chicken percent

;--==[Life Percent's]==--
Global $cLHP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "LifeHealPercent", 70);Use Life Potion percent
Global $cLJP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "LifeJuvPercent", 50);Use Small Juv Potion percent
Global $cLFJP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "LifeFullJuvPercent", 35);Use Big Juv Potion percent
Global $cLCP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "LifeChickenPercent", 20);Use Life Chicken percent

;--==[Merc Percent's]==--
Global $cEHP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "MercHealPercent", 40);Use Heal Potion on merc
Global $cEJP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "MercJuvPercent", 30);Use Heal Potion on merc
Global $cEFJP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "MercFullJuvPercent", 20);Use Full Juv Potion on merc
Global $cECP = IniRead(@ScriptDir & "\Config\D2Au3.ini", "oog", "MercChickenPercent", 10);Merc chicken percent
Global Const Enum $vName, $vLeft, $vTop, $vRight, $vBottom, $vColor, $vHeal, $vSmallJuv, $vFullJuv, $vChicken, $vCur, $vDrinkTimer
;Name, Left, Top, Right, Bottom, Color, HealPot, SmallJuv, FullJuv, Chicken, Current, DrinkTimer
;Merc we go by the pixel after (So Instead of searching for 3 colors, we go for 1)
Global $sStats[3][12] = [ _
["Life", 0, 509, 0, 587, 16526336, $cLHP, $cLJP, $cLFJP, $cLCP, 0, 0], _
["Mana", 799, 509, 799, 587, 2384088, $cMHP, $cMJP, $cMFJP, $cMCP, 0, 0], _
["Merc", 15, 18, 60, 18, 0, $cEHP, $cEJP, $cEFJP, $cECP, 0, 0]]

;~ Global $cChecksum[4] = [ 1008075717, 990512065, 1025639297, 1045562405 ]
Global $cChecksum[4] = [ 1511654973, 1321600493, 1646659825, 1072039085 ]
Global $sCurrent[3]
If PixelChecksum($sOpen[0], $sOpen[1], $sOpen[2], $sOpen[3], 2) <> $sOpen[4] Then
	MouseMove(399, 573, 4)
	Sleep(150)
	MouseClick("left", 399, 573, 1, 4)
	Sleep(150)
EndIf
If IsMenuOpen () = 0 Then
	LogEvent(1, "Unable to open menu.")
	Exit
EndIf

While 1
	Sleep(10)
	GetStat("Life")
	GetStat("Mana")
	GetStat("Merc")
	ToolTip("Life: " & $sStats[0][10] & @CRLF & "Mana: " & $sStats[1][10] & @CRLF & "Merc: " & $sStats[2][10], 0, 0)
WEnd


Func GetStat ($Stat)
	Local $Merc = 0
	If IsMenuOpen () = 0 Then Return
	Global $i
	For $i = 0 To 2 Step 1
		If $sStats[$i][0] = $Stat Then
			ExitLoop
		EndIf
	Next
	Local $sPix = PixelSearch($sStats[$i][1], $sStats[$i][2], $sStats[$i][3], $sStats[$i][4], $sStats[$i][5], 0, 1)
	If @error Then
		If $i = 2 Then;We are not able to anything because mercs dead/full life
			If PixelGetColor($sStats[$i][3]-2, $sStats[$i][2]) = 33792 Then;Mercs Full Health
				$sStats[$i][10] = 100
			Else
				$sStats[$i][10] = -1
			EndIf
			Return $sStats[$i][10]
		EndIf
		Return
	EndIf
	If $i = 2 Then
		$sStats[$i][10] = Round(100 * (($sPix[0] - $sStats[$i][1]) / ($sStats[$i][3] - $sStats[$i][1])))
	Else
		$sStats[$i][10] = Round(100 * (($sStats[$i][4] - $sStats[$i][2]) - ($sPix[1] - $sStats[$i][2])) / ($sStats[$i][4] - $sStats[$i][2]))
	EndIf
	If $i = 2 Then $Merc = 1
	Select
		Case $sStats[$i][10] <= $sStats[$i][$vChicken]
				If $Merc = 1 And $sStats[$i][10] = 0 Then Return
				If ExitGame () = 1 Then
					LogEvent(0, "Chickened from game. " & $Stat & " - " & $sStats[$i][10] & "%")
				EndIf
			Case $sStats[$i][10] <= $sStats[$i][$vFullJuv]
				LogEvent(0, "Attempting to drink a full juv. " & $Stat & " - " & $sStats[$i][10] & "%")
				If TimerDiff($sStats[$i][$vDrinkTimer]) > $cJuvDelay Then 
					If Drink($i, "FullJuv", $Merc) = 1 Then
						LogEvent(0, "Drank a full juv. " & $Stat & " - " & $sStats[$i][10] & "%")
					EndIf
					$sStats[$i][$vDrinkTimer] = TimerInit ()
				EndIf	
			Case $sStats[$i][10] <= $sStats[$i][$vSmallJuv];Small Juv
				LogEvent(0, "Attempting to drink a small juv. " & $Stat & " - " & $sStats[$i][10] & "%")
				If TimerDiff($sStats[$i][$vDrinkTimer]) > $cJuvDelay Then 
					If Drink($i, "SmallJuv", $Merc) = 1 Then
						LogEvent(0, "Drank a small juv. " & $Stat & " - " & $sStats[$i][10] & "%")
					EndIf
					$sStats[$i][$vDrinkTimer] = TimerInit ()
				EndIf
		Case $sStats[$i][10] <= $sStats[$i][$vHeal];Heal Potion
			If TimerDiff($sStats[$i][$vDrinkTimer]) > $cPotDelay Then 
				If Drink($i, "Heal", $Merc) = 1 Then
					LogEvent(0, "Drank a life/mana pot. " & $Stat & " - " & $sStats[$i][10] & "%")
				EndIf
				$sStats[$i][$vDrinkTimer] = TimerInit ()
			EndIf
	EndSelect
	Return $sStats[$i][10]
EndFunc

Func LogEvent($d, $j)
	Local $sg[4] = [ "M", "W", "E", "D" ]
	_FileWriteLog(@ScriptDir & "/Logs/Life-Check.txt", "[" & $sg[$d] & "] = " & $j)
EndFunc

Func IsMenuOpen()
	Switch $CharMode
		Case "Battle"
			If PixelGetColor(325, 559) <> 5274764 Then
				If PixelGetColor(462, 559) <> 8429760 Then
					Return 0
				EndIf
			EndIf
			Return 1
		Case "Single"
			If PixelGetColor(331, 538) <> 11312228 Then
				If PixelGetColor(470, 537) <> 9732196 Then
					Return 0
				EndIf
			EndIf
			Return 1
	EndSwitch
EndFunc   ;==>IsMenuOpen

Func Drink($i, $Type, $Merc=0)
	If $Type = "Heal" AND $i = 0 Then $Type = "Life"
	If $Type = "Heal" AND $i = 1 Then $Type = "Mana"
	If $Merc = 1 And $sStats[$i][10] = -1 Then Return;Merc is already dead.
	Local $sPos = FindPotion($Type, 1)
	If @error Then
		If $Type = "Life" or $Type = "Mana" Then
			Return 0
		ElseIf $Type = "SmallJuv" Then
			LogEvent(2, "Out of " & $Type & " potions, will use big juv!.")
			Drink($i, "FullJuv", $Merc)
		Else
			LogEvent(1, "Out of " & $Type & " potions, will chicken!")
			ExitGame ()
		EndIf
		Return 0
	EndIf
	If $Merc = 1 Then Send("{SHIFTDOWN}")
	Send($cRow[$sPos[0]])
	If $Merc = 1 Then Send("{SHIFTUP}")
	Return 1
EndFunc

Func FindPotion($sPot, $sFront=0)
	If $sFront = 1 Then $sFront = 3
	Local $cSize = 3, $cChk
	Switch $sPot
		Case "Life"
			$cChk = $cChecksum[0]
		Case "Mana"
			$cChk = $cChecksum[1]
		Case "SmallJuv"
			$cChk = $cChecksum[2]
		Case "FullJuv"
			$cChk = $cChecksum[3]
	EndSwitch
	For $sY = $sFront To 3 Step 1
		For $sZ = 0 To 3 Step 1
		Local $sB = PixelChecksum( _
			$cInvSize[$cSize][3] + ($sZ * $cInvSize[$cSize][5]) + 12, _
			$cInvSize[$cSize][4] + ($sY * $cInvSize[$cSize][6]) + 12, _
			$cInvSize[$cSize][3] + ($sZ * $cInvSize[$cSize][5]) + 17, _
			$cInvSize[$cSize][4] + ($sY * $cInvSize[$cSize][6]) + 17, 2);Checksum a 1x1 spot
			If $sB = $cChk Then
				Local $sRet[2] = [ $sZ, $sY ]
				Return $sRet
			EndIf
		Next
	Next
	Return SetError(1, 1, 0)
EndFunc

Func ExitGame ()
	Send("{ESC}")
EndFunc
