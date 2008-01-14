;================================================
; This file contains all functions related to Life Checking. 
; They are mostly derrived from the original PotThread version 5 for mmbot, adapted to use PoweredDeath's nifty one pixel orb mod.
;================================================
$ExtraDebug = "Yes"                                 ;Show Extra pixel info, for debugging purposes only

$Top = 509                                          ;Top of the health/mana orbs
$Bottom = 587                                       ;Bottom of the health/mana orbs

$HealthX = 0                                        ;Xcoord to scan the health orb
$ManaX = 799                                        ;Xcoord to scan the mana orb

$BeltX = 437                                        ;Left Belt Slot pixel reference
$BeltY = 582                                        ;Left Belt Slot pixel reference

$MercBarLeft = 15                                   ;Left side of the merc bar
$MercBarRight = 60                                  ;Right side of the merc bar
$MercBarY = 18                                      ;Merc bar Y coord

$beltfrjchecksum = 713163619                        ;belt checksum for full rejuvs
$beltrjchecksum = 1805125736                        ;belt checksum for regular rejuvs

$ChickenTimeout = 1000                              ;Time to wait for sucessful chicken before retrying
$ChickenRetries = 3                                 ;Times to retry chicken

Global $BarColor[2]
$BarColor[0] = 16526336                             ;Life bar color
$BarColor[1] = 2384088                              ;Mana bar color

Global $BeltData[4]                                 ;Potions info. 0 = no pot, 1 = full rejuv pot, 2 = regular rejuv pot

Dim $DrinkTimer = 0                                 ;Timer flag, weather or not the drink timer is active
Dim $DrinkTimeStamp                                 ;TimerInit($DrinkTimeStamp)
Dim $BotDir = @ScriptDir
;================================================
; Convert drink percents from Config.ini into an array so that the dynamic GetStats() doesn't need to use redundant code
; GetStats() can then just check if we need to chicken based upon either 0 or 1 for Life and Mana
; First Dimension: Checks for percentages of Life if 0, mana if 1, merc if 2
; Second Dimension: 0 will drink a RJ at this percent, 1 will drink a FRJ at this percent, 2 will chicken when you reach this percent without drinking.
;================================================
Dim $DrinkPercent[3][3]
$DrinkPercent[0][0] = $LifeRpotDrinkPercent
$DrinkPercent[0][1] = $LifeFpotDrinkPercent
$DrinkPercent[0][2] = $ChickenLife
$DrinkPercent[1][0] = $ManaRpotDrinkPercent
$DrinkPercent[1][1] = $ManaFpotDrinkPercent
$DrinkPercent[1][2] = $ChickenMana
$DrinkPercent[2][0] = $MercHealPercent
$DrinkPercent[2][1] = "None"                        ;There is no merc FRJ percent. Drink($DrinkType) will always prioritize RJs over FRJs whenever possible for the merc.
$DrinkPercent[2][2] = $MercChickenPercent

;================================================
; All character stats!
; These used to be all different vars such as $HealthPercent and $ManaPixel in PotThread for mmbot. These are now adjusted to this array so that we can use
; the single GetStats() function for all three checks using a neumerical switch. This should greatly reduce the redundant code of using separate GetLife() and GetMana().
; First Dimension: 0 = Life, 1 = Mana, 2 = Merc
; Second Dimension: 0 = Percentage remaining, 1 = The current Y pixel boundry for the bar, or X pixel boundry for merc.
;================================================
Global $CharStats[3][2]
$CharStats[0][1] = $HealthX                      ;Current Health Pixel y coord
$CharStats[1][1] = $ManaX                      ;Current Mana Pixel y coord
$CharStats[2][1] = $MercBarRight             ;Current merc bar pixel

;================================================
; Checks to see if there was a change in any stat, and will update stats if necessary
; Return Value: None
;================================================
Func UpdateStats()
	If IsMenuOpen () = 0 Then Return ;Skip the check if the minimpanel is not visible (means we aren't in game, d2 window isn't open/active, or an ingame menu is open)

	;Check if life has changed and refresh if so
	If PixelGetColor($HealthX, $CharStats[0][1]) <> $BarColor[0] Then
		GetStats ("Life")
	ElseIf $CharStats[0][1] <> $Top Then
		If PixelGetColor($HealthX, $CharStats[0][1] - 1) = $BarColor[0] Then GetStats("Life") EndIf
	Else
		LogEvent(1, "Could not update life stats")	
	EndIf

	;Check if mana has changed and refresh if so
	If PixelGetColor($ManaX, $CharStats[1][1]) <> $BarColor[1] Then
		GetStats("Mana")
	ElseIf $CharStats[1][1] <> $Top Then
		If PixelGetColor($ManaX, $CharStats[1][1] - 1) = $BarColor[1] Then GetStats("Mana") EndIf
	Else
		LogEvent(1, "Could not update mana stats")	
	EndIf

	;Check if merc's life has changed and refresh if so
	If $UseMerc = "Yes" Then
		If PixelGetColor($CharStats[2][1], $MercBarY) = 0 Then
			GetStats("Merc")
		ElseIf $CharStats[2][1] <> $MercBarRight Then
			If PixelGetColor($CharStats[2][1] + 1, $MercBarY) <> 0 Then GetStats("Merc") EndIf
		Else
			LogEvent(1, "Could not update merc life stats")
		EndIf
	EndIf
EndFunc   ;==>UpdateStats

;================================================
; Will search for Life, Mana, or Merc levels, and also check to determine if a chicken is needed based on user configuration.
; If $CheckType = 0 Then will search Life
; If $CheckType = 1 Then will search Mana
; If $CheckType = 2 Then will search Merc
; Return Value: None
;================================================
Func GetStats($CheckType)
	Local $Search
	Local $Check
	
	Switch $CheckType
		Case "Life"
			$Check = 0
		Case "Mana"
			$Check = 1
		Case "Merc"
			$Check = 2
	EndSwitch
	
	If $CheckType = "Merc" Then
		$Search = PixelSearch($MercBarLeft, $MercBarY, $MercBarRight, $MercBarY, 0)
	ElseIf $CheckType = "Life" Then
		$Search = PixelSearch($CharStats[$Check][1], $Top, $CharStats[$Check][1], $Bottom, $BarColor[$Check])
	ElseIf $CheckType = "Mana" Then
		$Search = PixelSearch($CharStats[$Check][1], $Top, $CharStats[$Check][1], $Bottom, $BarColor[$Check])
	Else
		LogEvent(1, "Invalid potthread check type")
	EndIf
	
	If NOT IsArray($Search) Then
		LogEvent(1, "PixelSearch Failed: Check Orb Mod Installed and Pixels Configured Correctly")
		Chicken()
	Else
		If $CheckType = "Merc" Then
			$CharStats[$Check][0] = Round(100 * (($Search - $MercBarLeft) / ($MercBarRight - $MercBarLeft)))
		Else
			$CharStats[$Check][0] = Round(100 * (($Bottom - $Top) - ($Search - $Top)) / ($Bottom - $Top))
		EndIf
		
		$CharStats[$Check][1] = $Search
	EndIf

	ShowTip()
	
	If $DrinkTimer = 1 Then
		If TimerDiff($DrinkTimeStamp) > $DrinkDelay Then $DrinkTimer = 0 EndIf
	EndIf
		
	If $DrinkTimer = 0 Then
		If ($CharStats[$Check][0] < $DrinkPercent[$Check][0]) And ($CharStats[$Check][0] > $DrinkPercent[$Check][1]) Then
			LogEvent (0, $CheckType & " has dropped to " & $CharStats[$Check][0] & "%, Will try to drink a regular rejuv.")
			Drink(1)
			$DrinkTimer = 1
			$DrinkTimeStamp = TimerInit()
		ElseIf $CharStats[$Check][0] < $DrinkPercent[$Check][1] Then
			LogEvent (0, $CheckType & " is critical! " & $CheckType & " has dropped to " & $CharStats[$Check][0] & "%, Will try to drink a Full rejuv.")
			Drink(0)
			$DrinkTimer = 1
			$DrinkTimeStamp = TimerInit()
		EndIf
	EndIf
	
	If $MercChicken = "No" Then Return
	
	If $CharStats[$Check][0] < $DrinkPercent[$Check][2] Then
		LogEvent (0, $CheckType & " is very low! Life has dropped to " & $CharStats[$Check][0] & "%, Bot will attempt to chicken...")
		Chicken ()
	EndIf
EndFunc   ;==>GetStats

;================================================
; Will wait a set amount of time at the start of each run in order to wait to visit an NPC in order to heal.
; Otherwise if our life is too low upon joining a game, and we are out of pots, we could end up in an infinant chickening loop! (Thats bad)
;================================================
Func ChickenWait()
	LogEvent (0, "Sleeping to avoid an infinant chicken loop. Wait to visit malah. Chicken_Wait_Delay = " & $ChickenWaitDelay)
	$DrinkTimeStamp = TimerInit()
	
	While TimerDiff($DrinkTimeStamp) < ($ChickenWaitDelay * 1000)
		ToolTip("Sleep Timer: " & Round($ChickenWaitDelay - (TimerDiff($DrinkTimeStamp) / 1000)), 252, 578)
		Sleep(500)
	WEnd
	
	ToolTip("")
	LogEvent (0, "Chicken Wait finished, Bot will continue checking...")
EndFunc   ;==>ChickenWait

;================================================
; Displays Life and Mana stats while running potthread
;================================================
Func ShowTip()
	If $ExtraDebug = "No" Then
		ToolTip("Life: " & Round($MaxLife * ($CharStats[0][0] / 100)) & " / " & $MaxLife & " - " & Round($CharStats[0][0]) & "%" & @CRLF _
				 & "Mana: " & Round($MaxMana * ($CharStats[1][0] / 100)) & " / " & $MaxMana & " - " & Round($CharStats[1][0]) & "%" & @CRLF _
				 & "Merc: " & Round($CharStats[2][0]) & "%", 252, 578)
	ElseIf $ExtraDebug = "Yes" Then
		ToolTip("Life: " & $MaxLife * ($CharStats[0][0] / 100) & " / " & $MaxLife & " - " & $CharStats[0][0] & "%" & @CRLF _
				 & "Mana: " & $MaxMana * ($CharStats[1][0] / 100) & " / " & $MaxMana & " - " & $CharStats[1][0] & "%" & @CRLF _
				 & "Merc: " & $CharStats[2][0] & "%" & @CRLF _
				 & "HealthPix: " & $CharStats[0][1] - $Top & " ManaPix: " & $CharStats[1][1] - $Top & @CRLF _
				 & "MercPix: " & $CharStats[2][1], 252, 578)
	EndIf
EndFunc   ;==>ShowTip

;================================================
; Drinks pots...
; Type of drink: 0 = Full rejuv, 1 = Regular rejuv, 2 = Merc
;================================================
Func Drink($DrinkType)
	Local $BeltPotInfo
	
	For $N = 0 To 3
		$Check = PixelChecksum(($BeltX + ($N * 31)) - 1, $BeltY - 1, ($BeltX + ($N * 31)) + 1, $BeltY + 1, 1)
		If $Check = $beltfrjchecksum Then
			$BeltData[$N] = 1
		ElseIf $Check = $beltrjchecksum Then
			$BeltData[$N] = 2
		Else
			$BeltData[$N] = 0
		EndIf
	Next
		
	For $N = 0 To 3		; loop through belt slots
		Select
			Case $BeltData[$N] = 1
				$BeltPotInfo = $BeltPotInfo & "(F)"
			Case $BeltData[$N] = 2
				$BeltPotInfo = $BeltPotInfo & "(R)"
			Case Else
				$BeltPotInfo = $BeltPotInfo & "(E)"
		EndSelect
	Next
	
	LogEvent (0, "Belt Data: " & $BeltPotInfo)
	
	Switch $DrinkType
		Case 0                      ;Prioritize Full rejuves
			For $T = 1 To 2
				For $N = 0 To 3
					If $BeltData[$N] = $T Then
						Send($Char_Key_PotionsRow[$N + 1])
						LogEvent (0, "Drank a pot from belt slot " & $N + 1)
						Return
					EndIf
				Next
			Next
			LogEvent (0, "We are out of pots, Chickening...")
			Chicken ()
		Case 1 OR 2                   ;Prioritize Regular rejuves
			For $T = 2 To 1 Step - 1
				For $N = 0 To 3
					If $BeltData[$N] = $T Then
						If $DrinkType = 2 Then Send("{SHIFTDOWN}")
						Send($Char_Key_PotionsRow[$N + 1])
						LogEvent (0, "Drank a pot from belt slot " & $N + 1)
						Send("{SHIFTUP}")
						Return
					EndIf
				Next
			Next
			LogEvent (0, "We are out of pots, Chickening...")
			Chicken ()
	EndSwitch
EndFunc   ;==>Drink
;================================================