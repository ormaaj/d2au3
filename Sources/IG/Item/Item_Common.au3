#include-once
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
	
;--------------------------------------------------------
;Func CheckItem($sItem, $sQual)
;$sItem - Name of base item (Like Amulet or Breast Plate)
;$sQual - Quality id ( 0 = White, 1 = Grey etc....)
;Returns	1 - Item is in Pickit
;			0 - Item isn't in pickit
;--------------------------------------------------------
Func CheckItem($sItem, $sQual)
	For $h = 1 To UBound($xPick) - 1 Step 1;Starts a loop on pickit array
		If $xPick[$h][0][0][0] <> $sItem Then ContinueLoop;Checks Item Name
		If $xPick[$h][0][0][1] <> $sQual Then ContinueLoop;Checks Quality
		Return 1;Returns a good item
	Next
	Return 0;Returns bad item
EndFunc

;--------------------------------------------------------
;Func _FindColor($pAct, $lPix)
;$pAct - Act you are currently in (So you can use proper colors)
;$lPix - Color to compare against
;Success:
;	Color is a "Quality" color
;	Returns quality id
;--------------------------------------------------------
Func _FindColor($pAct, $lPix)
	For $n = 0 To 6 Step 1;Loop Color id
		If $cItemColors[$pAct][$n] = $lPix Then Return $n;Compare and return
	Next
	Return -1;Returns that color is bad (-1 is used here because 0 is a quality id)
EndFunc

;--------------------------------------------------------
;Func ReadLine ($X, $Y, $Color)
;X - A close X value (Fine tune in beginning)
;Y - Exact Y value of dots (The thing we "Read")
;Color - Color of thoses dots (Associated with quality
;On Success:
;	Returns Read line
;Notes:
;The whole main and sub pixel thing is that there is usually like 6 or 7 0/1's (Always starts and ends with a 1)
;There wasn't enough pixel space so mm put Sub pixels
;So if you have like a 1011 and a sub pixel of 1 then your letter would be like b
;--------------------------------------------------------
Func ReadLine ($X, $Y, $Color)
	Local $xCodeA, $xCodeB, $sLetter, $xPix;Local Variables
	Do
		$X += 1
	Until PixelGetColor($X, $Y) <> $Color;Fine tune until we hit first little dot
	$X -= 1;Back up so we can start from non-dot
	While 1
		If StringRight($sLetter, 4) = "    " Then ExitLoop;End of line (A lazy way of doing it I know, but it works so W/e)
		$X += 1;Increase X pixel value
		$xPix = PixelGetColor($X, $Y);Grabs Main Pixel (One at the top)
		If $xPix = $Color Then;Checks to see if 1 or 0
			$xCodeA &= "1";Adds 1
		Else
			$xCodeA &= "0";Adds 0
		EndIf
		$xPix = PixelGetColor($X, $Y+1);Grabs Sub value (Might take a bit longer but FAR easier)
		If $xPix = $Color Then
			$xCodeB &= "1"
		Else
			$xCodeB &= "0"
		EndIf
		If StringRight($xCodeA, 2) = "00" Then;End of Letter (Usually 2 00's mean a new letter, some have 3 so BEWARE!)
			If $xCodeA = "00" Then ContinueLoop;If there is ONLY 2 00's then we found nothing lawl
			If PixelGetColor($X+1, $Y) <> $Color Then;Checks to see if next pixel to the right isnt a color
				If StringInStr($xCodeA, "1") = 0 Then;checks to see if there is even a single A
					While 1;Loops numbers 10101(Exp)
						For $m = $X To $X + 8 Step 1;Checks to see if we are on a space (Spaces are usually 8 pixels)
							If PixelGetColor($M, $Y) = $Color Then ExitLoop 2;Else its a letter
						Next
						$sLetter &= " ";Adds space
						$X += 8;Increases pixel count
						$xCodeA = "";Resets Code Letters
						$xCodeB = "";Resets Code B Letters
						ContinueLoop 2
					WEnd	
				EndIf
			EndIf
			$sLetter &= CodeToChar($xCodeA, $xCodeB);Converts your 101010 to B etc..
			$xCodeA = "";Resets Code Letters
			$xCodeB = "";Resets Code B Letters
		EndIf
	WEnd
	Return StringStripWS($sLetter, 7);Cleans the white spaces on the right and left and anything more then 2 spaces.
EndFunc

;****************************************
; Convert elementary code into character
;****************************************
Func CodeToChar($CodeA, $CodeB)
While StringRight($CodeA, 1) = "0"
	$CodeA = StringTrimRight($CodeA, 1)
WEnd
While StringLeft($CodeA, 1) = "0"
	$CodeA = StringTrimLeft($CodeA, 1)
WEnd
While StringLeft($CodeB, 1) = "0"
	$CodeB = StringTrimLeft($CodeB, 1)
WEnd
While StringRight($CodeB, 1) = "0"
	$CodeB = StringTrimRight($CodeB, 1)
WEnd
If $CodeA = "" Then Return " "
If StringLen($CodeA) < 5 Then
	If $CodeA == "11" Then
		Select
			Case $CodeB == ""
				Return "i"
			Case $CodeB == "1"
				Return "'"
			Case $CodeB == "11"
				Return "j"
			Case $CodeB == "111"
				Return ":"
		EndSelect
	EndIf

	If $CodeA == "1011" Then
		Select	
			Case $CodeB == ""
				Return "s"
			Case $CodeB == "1"
				Return "h"
			Case $CodeB == "1101"
				Return "3"
			Case $CodeB == "111"
				Return "6"
			Case $CodeB == "11"
				Return "7"
			Case $CodeB == "101"
				Return "8"
			Case $CodeB == "1111"
				Return "9"
			Case $CodeB == "11"
				Return "7"
			Case $CodeB == "1011"
				Return "z"
		EndSelect
	EndIf			

	If $CodeA == "111" Then
		Select	
			Case $CodeB == "1"
				Return "1"
			Case $CodeB == "111"
				Return "("
			Case $CodeB == "11"
				Return "J"
		EndSelect
	EndIf
	
	If $CodeA == "101" Then
		Select
			Case $CodeB == "101"
				Return "-"
			Case $CodeB == "1"
				Return ")"
			Case $CodeB == "11"
				Return "I"
		EndSelect
	EndIf
	
	If  $CodeA == "1111" Then
		Return "S"
	EndIf
	
	If $CodeA == "1101" Then
		Select		
			Case $CodeB == ""
				Return "B"
			Case $CodeB == "1"
				Return "F"
		EndSelect
	EndIf
	Return "?"
EndIf

Select
	Case $CodeA == "11101" 
		Return "e"
	Case $CodeA == "10101011" 
		Return "a"		
	Case $CodeA == "1101101" 
		Return "t"
	Case $CodeA == "1010111" 
		Return "n"		
	Case $CodeA == "10101111" 
		Return "o"		
	Case $CodeA == "111101" 
		Return "d"
	Case $CodeA == "101101" 
		Return "+"		
	Case $CodeA == "1011111" 
		Return "g"		
	Case $CodeA == "111011" 
		Return "c"
	Case $CodeA == "10110101" 
		Return "m"
	Case $CodeA == "1010101" 
		Return "r"		
	Case $CodeA == "10101" 
		Return "l"
	Case $CodeA == "11101011" 
		Return "%"
	Case $CodeA == "11010111" 
		Return "R"		
	Case $CodeA == "10110111" 
		Return "D"		
	Case $CodeA == "1011011" 
		Return "2"
	Case $CodeA == "101010101" 
		Return "A"		
	Case $CodeA == "101011" 
		Return "k"		
	Case $CodeA == "10111101" 
		Return "u"		
	Case $CodeA == "110111" 
		Return "5"
	Case $CodeA == "101011011" 
		Return "0"
	Case $CodeA == "1101111" 
		Return "4"
	Case $CodeA == "11011" 
		Return "f"		
	Case $CodeA == "101011101" 
		Return "M"
	Case $CodeA == "110101" 
		Return "L"		
	Case $CodeA == "11111" 
		Return "p"		
	Case $CodeA == "101111" 
		Return "E"
	Case $CodeA == "11011011" 
		Return "v"
	Case $CodeA == "1110101" 
		Return "C"		
	Case $CodeA == "11011101" 
		Return "y"					
	Case $CodeA == "10111111" 
		Return "x"
	Case $CodeA == "10111" 
		Return "b"
	Case $CodeA == "1011101" 
		Return "P"		
	Case $CodeA == "101011111" 
		Return "O"		
	Case $CodeA == "101111011" 
		Return "U"					
	Case $CodeA == "1110111" 
		Return "H"
	Case $CodeA == "101110111" 
		Return "w"		
	Case $CodeA == "1101011" 
		Return "/"
	Case $CodeA == "11011111" 
		Return "N"
	Case $CodeA == "101101101" 
		Return "T"
	Case $CodeA == "1111011" 
		Return "K"
	Case $CodeA == "10111011" 
		Return "q"		
	Case $CodeA == "11010101" 
		Return "G"
	Case $CodeA == "101111101011" 
		Return "W"
	Case $CodeA == "101101111" 
		Return "V"
	Case $CodeA == "10101101" 
		Return "Z"
	Case $CodeA == "101101011" 
		Return "Q"
	Case $CodeA == "101010111" 
		Return "X"
	Case $CodeA == "11010111" 
		Return "R"
	Case $CodeA == "101110101" 
		Return "Y"
EndSelect
Return "?"
EndFunc

;--------------------------------------------------------
;Func ReadItem ($X, $Y, $CloseInv=0)
;X - The X value of where it is in inventory (0-9 for inv etc...)
;Y - The Y value of where it is in invenotry (0-3 for inv etc...)
;CloseInv - Set to 1 to close inventory when done
;On Success:
;	Returns Array with item info
;Notes:
;This will use the memory to read the stats of the item under cursor
;It puts all the info into a array and returns
;$sItem[0][0] - Item Name(Grand Charm, Flail etc....)
;$sItem[0][1] - Quality ID (0= White, 4= Rare, 5=Unique etc...)
;$sItem[0][2] - Group (Body Armors, Weapons etc...)
;$sItem[0][3] - Class (I'm not quite sure:x Ripped the itemarr from mmBOT so)
;$sItem[0][4] - Hands (Again not sure)
;$sItem[0][5] - X Size (Size of the item left to right)
;$sItem[0][6] - Y Size (Size of the item top to bottom)
;$sItem[1][0] - Amount of stats
;$sItem[x][0] - Raw stat (Like Required Level: 32)
;--------------------------------------------------------
Func ReadItem($X, $Y, $CloseInv=0)
	If Check("Inv") = 0 Then
		SendKey("ClearScreen");Clear Screen
		SendKey("Inventory");Open Inventory
	EndIf
	MouseInv("Inv", $X, $Y);Move mouse over item we want to read
	SetPrivilege ("SeDebugPrivilege", 1);Sets debug priv
	Local $sHandle = _MemoryOpen (WinGetProcess("ClassName=Diablo II"));Opens D2's memory
	Local $sItem[2][7], $iStat = 2;Couple local variables
	Local $sRet = _MemoryReadWideString ('0x' & Hex(Dec("6F9A8E20") + 0), $sHandle, 'ushort[1000]');Reads item stats(Stats over cursor)
	_MemoryClose ($sHandle);Closes Memory
	If StringInStr($sRet, "Unid") <> 0 Then;Check to see if item is unid
		MoveMouse ();Hides mouse (So we can properly find id scroll)
		Local $sJ = FindItem("NPC", "IDScroll");Find ID Scroll In NPC's inv
		If Not @error Then;Make sure we found if not, do not ID
			ItemClick("NPC", $sJ[0], $sJ[1], "right");Buy Scroll
			Sleep(200);Sleep for scroll to appear
			Local $sID = FindItem("Inv", "IDScroll");Find where ID scroll landed in inv
			If Not @error Then;Check to make sure we found scroll
				ItemClick("Inv", $sID[0], $sID[1], "right");Right click scroll to be used
				Sleep(200);Sleep for a second to get scroll on
				ItemClick("Inv", $X, $Y, "left");Id Item
			EndIf
		EndIf
	EndIf
	Local $sStat = StringSplit($sRet, @LF);Split stats by line
	_ArrayReverse($sStat, 1);Reverse stats (By default it goes last line to first)
	For $i = 1 To $sStat[0] Step 1;Loop all stats
		If StringInStr($sStat[$i], "]]]]]]]]") <> 0 Then;check to find item and quality
			$sItems = _StringBetween($sStat[$i], "]]]] ", " ÿc");Get Item Name
			If @error Then ContinueLoop
			$sItem[0][0] = $sItems[0];Put item name in array
			Local $sStats = StringRegExp($sStat[$i], "(?s)(?i)ÿc(\d+).*?ÿc(;|-|:|\+)", 3);Find item quality id
			For $h = 0 To 6 Step 1;Loop all possible ÿc colors against there quality eqv.
				If $sYC[$h] = $sStats[0] Then;Compare ÿc color vs qual
					$sItem[0][1] = $h;Store quality id in array
					ExitLoop;Get out of loop
				EndIf
			Next
		EndIf
		$sStat[$i] = StringRegExpReplace($sStat[$i], "(?:ÿc([0-9:;+']))","");Remove ALL ÿc colors from stat
		$sItem[1][0] = $iStat;Updates amount of stats in array
		ReDim $sItem[$iStat + 1][7];Redim array for to add new stat
		$sItem[$iStat][0] = $sStat[$i];Store stat in array
		$iStat += 1;Increase stat counter
	Next
	If $CloseInv = 1 Then SendKey("ClearScreen");Close Inv if you want to
	;This grabs the item info based on the reference
	For $b = 1 To 572 Step 1
		If $iItems[$b][1] = $sItem[0][0] Then
			$sItem[0][2] = $iItems[$b][2]
			$sItem[0][3] = $iItems[$b][3]
			$sItem[0][4] = $iItems[$b][4]
			$sItem[0][5] = $iItems[$b][5]
			$sItem[0][6] = $iItems[$b][6]
			ExitLoop
		EndIf
	Next
	Return $sItem
EndFunc   ;==>D2MemRead

;--------------------------------------------------------
;Func Database($sType, $sClear=0)
;$sType - Type of area we are getting a reference for(Inv, Stash, NPC, Belt)
;$sClear - Set to 1 to close area when done(A clearscreen)
;Returns a 2d array
;1 - An item in the spot
;0 - Item isn't in spot
;--------------------------------------------------------
Func Database($sType, $sClear=0)
	Local $cSize;Local Variables
	For $h = 0 To 3 Step 1;Loops all different inventory types(Inv, Stash, NPC, Belt)
		If $cInvSize[$h][0] = $sType Then ;Checks to see if one you wanted
			$cSize = $h;stores array id
			ExitLoop
		EndIf
	Next
	;Check to see if proper area is there
	Switch $cSize
		Case 0;Inv
			;If Check("Inv") = 0 Then
				SendKey("ClearScreen")
				SendKey("Inventory")
			;EndIf
		Case 1;NPC
			Return -1;Not supported here
		Case 2;Stash
			If Check("Stash") = 0 Then Return 0;Not in stash then we can't do shit.
		Case 3;Belt
			SendKey("ClearScreen")
			SendKey("ShowBelt")
		Case Else
			Return -2;Invalid sType
	EndSwitch
	Local $sL[$cInvSize[$cSize][1] + 1][$cInvSize[$cSize][2] + 1];Declare a array to hold database
	For $sY = 0 To $cInvSize[$cSize][1] Step 1; Loop area
		For $sZ = 0 To $cInvSize[$cSize][2] Step 1
			Sleep(1);To reduce CPU usage
			Local $sB = PixelChecksum( _
				$cInvSize[$cSize][3] + ($sZ * $cInvSize[$cSize][5]) + 12, _
				$cInvSize[$cSize][4] + ($sY * $cInvSize[$cSize][6]) + 12, _
				$cInvSize[$cSize][3] + ($sZ * $cInvSize[$cSize][5]) + 17, _
				$cInvSize[$cSize][4] + ($sY * $cInvSize[$cSize][6]) + 17, 2);Checksum a 1x1 spot
				If $sEmptyRefInv[$cSize][$sY][$sZ] = $sB Then ;Compare against checksum to figure out if item is there
					$sL[$sY][$sZ] = "0";Empty
				Else
					$sL[$sY][$sZ] = "1";Something there
				EndIf
		Next
	Next
	If $sClear = 1 Then SendKey("ClearScreen");Clearscreen
	Return $sL
EndFunc

;--------------------------------------------------------
;Func DatabaseCompare($sType, $sCompare, $sClear=0, $sRetStr=0)
;$sType - Type of area we are getting a reference for(Inv, Stash, NPC, Belt)
;$sCompare - Array from which we are comparing (Returned from Database ())
;$sClear - Set to 1 to close area when done(A clearscreen)
;$sRetStr - Set to 1 to return a string for debugging purposes
;Returns a 2d array
;1 - The area has changed (Item added/removed)
;0 - The area is the same (There was/n't a item there then and now)
;--------------------------------------------------------
Func DatabaseCompare($sType, $sCompare, $sClear=0, $sRetStr=0)
	Local $sDiff = Database($sType, $sClear), $sTemp;Take a snapshot of inv now to compare against old one
	Local $sMaxX = UBound($sCompare), $sMaxY = UBound($sCompare, 2);Local variables
	Local $sReturn[$sMaxX][$sMaxY];Array we return 
	For $x = 0 To $sMaxX - 1 Step 1
		For $y = 0 To $sMaxY - 1 Step 1
			Sleep(1)
			If $sCompare[$x][$y] = $sDiff[$x][$y] Then;Compare the two databases to see if they are the same
				$sReturn[$x][$y] = 0;Store "Nothing has changed" in array
				$sTemp &= "0";adds to a string variable(For debugging etc...)
			Else
				$sReturn[$x][$y] = 1;Store "Something changed here" in array
				$sTemp &= "1"
			EndIf
		Next
		$sTemp &= @CRLF;Adds a newline to string variable
	Next
	If $sRetStr = 1 Then Return $sTemp;Decides what to return
	Return $sReturn
EndFunc


;--------------------------------------------------------
;Func EmptyDatabase($sType)
;$sType - Type of area we are getting a reference for(Inv, Stash, NPC, Belt)
;Returns a 2d array full of 0's (An Empty database)
;Notes:
;Too lazy to add comments, not to hard to figure out, just makes an array and adds 0's :P
;--------------------------------------------------------
Func EmptyDatabase($sType)
	Local $cSize
	For $h = 0 To 3 Step 1
		If $cInvSize[$h][0] = $sType Then 
			$cSize = $h
			ExitLoop
		EndIf
	Next
	Local $sL[$cInvSize[$cSize][1] + 1][$cInvSize[$cSize][2] + 1]
	For $j = 0 To UBound($sL) - 1 Step 1
		For $l = 0 To UBound($sL,2) - 1 Step 1
			$sL[$j][$l] = "0"
		Next
	Next
	Return $sL
EndFunc