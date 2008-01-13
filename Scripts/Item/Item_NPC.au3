;Item_NPC.au3
#include-once
;None of these are comments throughout the function cuz I'm mad lazy and it got mad boring.

;--------------------------------------------------------
;Func FindItem ($Area, $Item, $Ret=1)
;$Area - Type of area we are getting a reference for(Inv, Stash, NPC, Belt)
;$Item - Name of item to look for(Checksums are in Item_Checksums.au3)
;$Ret - If set to 1 will return first found item, else will return ALL of them found
;--------------------------------------------------------
Func FindItem ($Area, $Item, $Ret=1)
	Local $z_s, $i_s, $bx, $by, $z, $i, $sRet[1][2], $xid = 29, $yid = 31, $cAr = -1
	For $n = 0 To UBound($cInvSize) - 1 Step 1
		If $cInvSize[$n][0] = $Area Then
			$cAr = $n
			ExitLoop
		EndIf
	Next
	If $cAr = -1 Then
		LogEvent(2, "Area given for FindItem () was not valid.")
		Return SetError(2, 0, 0)
	EndIf
	$z_s = $cInvSize[$cAr][1]
	$i_s = $cInvSize[$cAr][2]
	$bx = $cInvSize[$cAr][3]
	$by = $cInvSize[$cAr][4]
	$xid = $cInvSize[$cAr][5]
	$yid = $cInvSize[$cAr][6]
	Local $Pix = Eval("I_" & $Item)
	For $z = 0 To $z_s Step 1;Top-Bottom
		For $i = 0 To $i_s Step 1;Left-Right
			If PixelChecksum($bx + ($i * $xid) + 12, $by + ($z * $yid) + 12, $bx + ($i * $xid) + 17, $by + ($z * $yid) + 17, 1) = $Pix Then
				If $Ret = 1 Then
					Local $sRett[2] = [ $i, $z ]
					Return $sRett
				ElseIf $Ret = 2 Then
					$s = UBound($sRet, 1)
					ReDim $sRet[$s+1][2]
					$sRet[$s][0] = $z
					$sRet[$s][1] = $i
					$sRet[0][0] = $s
				EndIf
			EndIf
		Next
	Next
	If $Ret = 2 Then Return $sRet
	Return SetError(1, 0, 0)
EndFunc

;--------------------------------------------------------
;Func MouseInv($Area, $X, $Y)
;$Area - Type of area we are getting a reference for(Inv, Stash, NPC, Belt)
;X - The X value of where it is in inventory (0-9 for inv etc...)
;Y - The Y value of where it is in invenotry (0-3 for inv etc...)
;--------------------------------------------------------
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
	MouseMove($bx + ($X * 29) + 14, $by + ($Y * 29) + 14, 5)
	Sleep(Random(100, 200))
	Local $sRet[2] = [ Int($bx + ($X * 29) + 15), Int($by + ($Y * 29) + 15) ]
	Return $sRet
EndFunc

;--------------------------------------------------------
;Func Identify ($base = $gInvChecksum)
;$base - Database to compare against
;Notes:
;Compares against a global reference if no database entered
;Needs to be in NPC window for it to work (Selling items, buying ID scrolls)
;--------------------------------------------------------
Func Identify ($base)
	LogEvent(0, "Starting identification at NPC.")
	Local $sDiff = DatabaseCompare("Inv", $base, 0, 0)
	Local $sNewRef = EmptyDatabase("Inv")
	For $sIDx = 0 To $cInvSize[0][2] Step 1;Left-Right 0-9
		For $sIDy = 0 TO $cInvSize[0][1] Step 1;Up-Down 0-3
			If $sDiff[$sIDy][$sIDx] = "0" Then ContinueLoop ;This is not a change area
			$tItem = ReadItem($sIDx, $sIDy);Check this new item
			$vStat = 1
			Local $vStats[1][5]
			For $i = 2 To UBound($tItem) - 1 Step 1
				For $v = 1 To UBound($iStats) - 1 Step 1
					Local $sgg = StringRegExp($tItem[$i][0], _RegFriendly($iStats[$v][1]),3)
					If @error Then ContinueLoop
					$vStat += 1
					ReDim $vStats[$vStat][5]
					$vStats[0][0] += 1
					$vStats[$vStat - 1][0] = $iStats[$v][3]
					For $m = 0 To UBound($sgg) - 1 Step 1
						$vStats[$vStat - 1][$m + 1] = $sgg[$m]
					Next
					ExitLoop
				Next
			Next
			For $h = 1 To UBound($xPick) - 1 Step 1;Starts a loop on pickit array
				If $xPick[$h][0][0][0] <> $tItem[0][0] Then ContinueLoop;Checks Item Name
				If $xPick[$h][0][0][1] <> $tItem[0][1] Then ContinueLoop;Checks Quality
				Local $mStat = 1;Starts xPick Stat counter
				Do
					For $d = 1 To UBound($vStats) - 1 Step 1;Loop real item stats
						If $xPick[$h][$mStat][0][0] = $vStats[$d][0] Then;Matching Stats
							For $b = 1 To UBound($xPick,3) - 1 Step 1
								If _Comparison($xPick[$h][$mStat][$b][0], $vStats[$d][$b], $xPick[$h][$mStat][$b][1]) = 0 Then 
									SendKey("CTRL", "DOWN", 1)
									Sleep(Random(50, 100))
									Local $sV = MouseInv("Inv", $sIDx, $sIDy)
									MouseClick("left", $sV[0], $sV[1], 1, 3)
									Sleep(Random(50, 100))
									SendKey("CTRL", "UP", 1)
									ContinueLoop 4
									For $mX = $sIDx To $sIDx + $tItem[0][5] - 1 Step 1
										For $mY = $sIDY To $sIDy + $tItem[0][6] - 1 Step 1
											$sDiff[$mY][$mX] = "0"
										Next
									Next	
								EndIf
							Next
						EndIf
					Next
					For $mX = $sIDx To $sIDx + $tItem[0][5] - 1 Step 1
						For $mY = $sIDY To $sIDy + $tItem[0][6] - 1 Step 1
							$sNewRef[$mY][$mX] = "1"
						Next
					Next		
					For $mX = $sIDx To $sIDx + $tItem[0][5] - 1 Step 1
						For $mY = $sIDY To $sIDy + $tItem[0][6] - 1 Step 1
							$sDiff[$mY][$mX] = "0"
						Next
					Next						
					ContinueLoop 3
				Until $xPick[$h][$mStat][0][0] = ""
			Next
			SendKey("CTRL", "DOWN", 1)
			Sleep(Random(50, 100))
			Local $sV = MouseInv("Inv", $sIDx, $sIDy)
			MouseClick("left", $sV[0], $sV[1], 1, 3)
			Sleep(Random(50, 100))
			SendKey("CTRL", "UP", 1)	
			For $mX = $sIDx To $sIDx + $tItem[0][5] - 1 Step 1
				For $mY = $sIDY To $sIDy + $tItem[0][6] - 1 Step 1
					$sDiff[$mY][$mX] = "0"
				Next
			Next			
		Next
	Next
	LogEvent(0, "Identification successful.")
EndFunc

;--------------------------------------------------------
;Func _RegFriendly($sStr)
;$sStr - String to convert to a RegExp friendly string
;Notes:
;Used on the item stats so characters like +, . , / don't mess up the RegExp
;--------------------------------------------------------
Func _RegFriendly($sStr)
	Local $sStart = 1
	If StringInStr($sStr, "Ethereal") <> 0 OR StringInStr($sStr, "Socket") <> 0 Then $sStart = 0
	Local $sClean = _ArrayCreate("/", "+", "(", ")", "[", "]", ".", "|", "*", "?", "{", "}")
	For $qq = 0 To UBound($sClean) - 1 Step 1
		$sStr = StringReplace($sStr, $sClean[$qq], "\" & $sClean[$qq])
	Next
	$sStr = StringReplace($sStr, "\[x\]", "(.+)")
	If $sStart = 1 Then 
		$sStr = "\A(?i)" & $sStr
	Else
		$sStr = "(?i)" & $sStr
	EndIf
	Return $sStr
EndFunc

;--------------------------------------------------------
;Func Tool($sTxt)
;$sTxt - Txt you want to display
;Notes:
;Used for debugging
;--------------------------------------------------------
Func Tool ($sTxt)
	ToolTip($sTxt, 0, 0)
	Sleep(4000)
	ToolTip("")
EndFunc

;--------------------------------------------------------
;Func ItemClick($sArea, $sX, $sY, $sSide, $sDown=0)
;$sArea - Type of area we are getting a reference for(Inv, Stash, NPC, Belt)
;$sX - The X value of where it is in inventory (0-9 for inv etc...)
;$sY - The Y value of where it is in invenotry (0-3 for inv etc...)
;$sSide - Mouse click left or right
;$sDown - Key to press down while clicking(CTRL would sell item, SHIFT would fill tomb/belt, etc....)
;--------------------------------------------------------
Func ItemClick($sArea, $sX, $sY, $sSide, $sDown=0)
	Local $sPos = MouseInv($sArea, $sX, $sY)
	If $sDown <> 0 Then SendKey($sDown, "DOWN", 1)
	MouseClick($sSide, $sPos[0], $sPos[1])
	If $sDown <> 0 Then SendKey($sDown, "UP", 1)
	Return 1
EndFunc
	