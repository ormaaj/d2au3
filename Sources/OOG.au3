;================================================
;This file contains included functions called in the "Out Of Game" process which are not related to LifeChecking. PotThread.au3 deals with lifechecking.
;Functions dealing with game creation, login, character selection, etc can be found here.
;================================================
;================================================
;Launches D2, logs in, and gets you to the lobby, Or if single player, just launch d2.
;Returns 0 if failed
;Returns 1 if success
;Returns 2 if its a fatal error (cdkey in use)
;================================================
Func LaunchD2($CharMode)
	LogEvent(0, "Launching Diablo II LOD for " & $CharMode & " mode.")
	Run($D2Path & "\" & $D2Executable & " " & $Parameters, $D2Path)
	WinWaitActive($D2WName,"",5)
	If WinExists($D2WName) = 0 Then
		LogEvent(1, "Failed to launch Diablo using " & $D2Path & "\" & $D2Executable & " " & $Parameters & " Check your D2_Path variable in Config.au3")
		Return 0
	Else
		LogEvent(0, "D2 Loaded successfully!")
	EndIf
	Sleep(1000)
	WinMove($D2WName, "", 0, 0)
	MouseClick("Left", 100, 100, 1, $MenuMouseSpeed)                                               ;Click to get past the D2 splash screen
	If ScreenWait("TitleScreen", 5000) = 0 Then Return 0
	If $CharMode = "Single" Then Return 1                                                         ;If its single player... we're done!
	MouseClick("Left", 394, 353, 1, $MenuMouseSpeed)        	;Click the bnet button
;~ 	Local $LoginTimer = TimerInit ()
;~ 	While ScreenCheck("LoginScreen") = 0 AND TimerDiff($LoginTimer) < Round($LoginTimeout / 60)
;~ 		Sleep(10)
;~ 	WEnd
	If ScreenWait("LoginScreen", 10000) = 0 Then 
		If PixelChecksum(170, 215, 592, 250, 1)  = 1297468801 Then
			LogEvent(2, "CdKey" & $SetID & " is Currently In Use.")
			Return 2
		Else
			LogEvent(1, "Failed to Log into Bnet for an unknown reason.")
			Return 0
		EndIf
	EndIf
	MouseClickDrag("Left", 477, 336, 300, 336, $MenuMouseSpeed)                                    ;Drag-select the account field
	Sleep($MenuStaticDelay)
	Send($CharAccount)
	Sleep($MenuStaticDelay)
	Send("{TAB}")
	Sleep($MenuStaticDelay)
	Send($CharPassword)
	Sleep($MenuStaticDelay)
	MouseClick("Left", 395, 470, 1, $MenuMouseSpeed)                                               ;Click the button to get to the character select screen.
	If ScreenWait("CharacterSelect", 10000) = 0 Then Return 0
	MouseClick("Left", 173 + (IsInt($CharSlot / 2) * 277), 140 + (93 * Floor(($CharSlot - 1) / 2)), 1, $MenuMouseSpeed) ;Click the character at the appropriate slot
	Sleep($MenuStaticDelay)
	MouseClick("Left", 692, 557, 1, $MenuMouseSpeed)                                               ;Click to get to the lobby from the character select screen.
	If ScreenWait("Lobby", 10000) = 0 Then Return 0
	Return 1
EndFunc   ;==>LaunchD2

;================================================
;Create a game in battlenet with dynamic waits & retries.
;Returns 0 if failed, and a retry is needed
;Returns 1 if success
;Returns 2 if failed with a fatal error, bot will terminate.
;================================================
Func CreateGame($CharMode, $Run_GameName = "error", $Run_PasswordType = "error", $CharSlot = 1)
	If ($Run_GameName = "error") Or ($Run_PasswordType = "error") Then
		LogEvent(1, "$CharMode must be either ""Battle"" or ""Single"". Please read the manual and configure the bot.")
		Return 2
	EndIf
	Select
		Case $CharMode = "Battle"
			For $Retry = 1 To 5
				LogEvent(0, "Attempting to create the game " & $GameName & $RunCount & " This is attempt number " & $Retry)
				MouseClick("Left", 590, 462, 1, $MenuMouseSpeed)
				If ScreenWait("CreateButton", 5000) = 0 Then
					MouseClick("Left", 712, 461, 1, $MenuMouseSpeed)
					Sleep(2000)
					ContinueLoop
				EndIf
				
				;Send the Game Name
				If $Run_GameName = "Random" Then
					For $N = 0 To Random(8, 10, 1)
						$rand = Random(0, 1, 1)
						Send(Chr(Mod(Random(1, 26, 1), ($rand * 16) + 10) + (($rand * 49) + 48))) ;Send an alphaneumeric random Digit
					Next
				Else
					Send($Run_GameName & $RunCount)
				EndIf
				
				Sleep(200)
				Send("{TAB}")
				
				;Send the Password
				If $Run_PasswordType = "Random" Then
					Send(Random(100, 999999, 1))
				ElseIf $Run_PasswordType = "Numbered" Then
					Send($RunCount)
				EndIf
				
				;Select difficulty
				Switch $CharDifficulty
					Case 0
						MouseClick("Left", 440, 375, 1, $MenuMouseSpeed)
					Case 1
						MouseClick("Left", 565, 375, 1, $MenuMouseSpeed)
					Case 2
						MouseClick("Left", 707, 375, 1, $MenuMouseSpeed)
				EndSwitch
				
				MouseClick("Left", 676, 418, 1, $MenuMouseSpeed) ;Click create game
				If ScreenWait("GameJoin", 5000) = 0 Then
					LogEvent(1, "Game create screen not detected after 5 seconds... will retry the game join.")
					MouseClick("Left", 711, 461, 1, $MenuMouseSpeed)
					ContinueLoop
				EndIf
				Local $Timeout = TimerInit()
				While ScreenCheck("GameJoin") = 1
					If TimerDiff($Timeout) > 30000 Then
						LogEvent(1, "Looks like we got stuck on the game create screen for over 30 seconds...")
						Return 0
					EndIf
					Sleep(500)
				WEnd
				If ScreenCheck("Lobby") = 1 Then
					LogEvent(1, "Failed to Join! Bnet needs to fix their damn servers!!! Lets just retry...")
					ContinueLoop
				ElseIf IsInGame() = 1 Then
					LogEvent(0, "Successfully joined the game after " & Round((TimerDiff($Timeout) / 1000), 2) & " seconds.")
					Return 1
				Else
					LogEvent(1, "Hmm, looks like we got lost somewhere while attempting to create a game...")
					Return 0
				EndIf
			Next
			LogEvent(1, "Failed to create a game after 5 retries.")
			Return 0
		Case $CharMode = "Single"
			MouseClick("Left", 394, 310, 1, $MenuMouseSpeed) ;Click the Single Player button on the main menu.
			Sleep($MenuStaticDelay)
			If ScreenWait("CharacterSelect", 10000) = 0 Then Return 0
			;MouseClick("Left", 173 + (IsInt($CharSlot / 2) * 277), 140 + (93 * (($CharSlot / 2) - 1)), 1, $MenuMouseSpeed) ;Click the character at the appropriate slot
			MouseClick("Left", 173 + (IsInt($CharSlot / 2) * 277), 140 + (93 * Floor(($CharSlot - 1) / 2)), 1, $MenuMouseSpeed) ;Click the character at the appropriate slot
			Sleep($MenuStaticDelay)
			MouseClick("Left", 690, 556, 1, $MenuMouseSpeed) ;Click OK
			Sleep($MenuStaticDelay)
			$Time = TimerInit()
			While TimerDiff($Time) < 10000
				Sleep(100)
				If ScreenCheck("GameJoin") = 1 Then ExitLoop
				If ScreenCheck("SinglePlayerDifficulty") = 1 Then
					MouseClick("Left", 400, 280 + ($CharDifficulty * 45), 1, $MenuMouseSpeed) ;Click the difficulty
					If ScreenWait("GameJoin", 5000) = 0 Then
						Return 0
					Else
						ExitLoop
					EndIf
				EndIf
			WEnd
			Local $Timeout = TimerInit()
			While ScreenCheck("GameJoin") = 1
				If TimerDiff($Timeout) > 30000 Then
					LogEvent(1, "Looks like we got stuck on the game create screen for over 30 seconds...")
					Return 0
				EndIf
				Sleep(500)
			WEnd
			If IsInGame() = 1 Then
				LogEvent(0, "Successfully joined the game after " & Round((TimerDiff($Timeout) / 1000), 2) & " seconds.")
				Return 1
			Else
				LogEvent(1, "Hmm, looks like we got lost somewhere while attempting to create a game...")
				Return 0
			EndIf
	EndSelect
EndFunc   ;==>CreateGame

;================================================
;Dynamic wait for a screen.
;Feed a screen to wait for from Checksums.au3, or define your own. Also supply a timeout.
;Returns 0 if failed
;Returns 1 if success
;================================================
Func ScreenWait($ScreenName, $Timeout = 5000)
	Local $Checksum[5]
	Local $Sum
	$Checksum = Eval($ScreenName)
	$Time = TimerInit()
	Do
		Sleep(200)
		$Sum = PixelChecksum($Checksum[1], $Checksum[2], $Checksum[3], $Checksum[4])
		If $Sum = $Checksum[0] Then Return 1
	Until TimerDiff($Time) > $Timeout
	LogEvent(1, $Sum & " does not match the expected the checksum of " & $Checksum[0] & " for the menu " & $ScreenName & " at coordinates (" & $Checksum[1] & " ," & $Checksum[2] & " ," & $Checksum[3] & " ," & $Checksum[4] & ") and timed out after " & $Timeout & " milliseconds.")
	Return 0
EndFunc   ;==>ScreenWait

;================================================
;Simple screen detection.
;Returns 0 if screen does not match
;Returns 1 if the screen matches
;================================================
Func ScreenCheck($ScreenName)
	Local $Checksum[5]
	$Checksum = Eval($ScreenName)
	If PixelChecksum($Checksum[1], $Checksum[2], $Checksum[3], $Checksum[4]) = $Checksum[0] Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>ScreenCheck

;================================================
;Quit D2.
;will try to chicken first if we are in-game.
;Returns 0 if failed
;Returns 1 if success
;================================================
Func D2Kill()
	If IsInGame() = 1 Then
		If Chicken() = 0 Then
			LogEvent(1, "Failed to chicken while attempting to quit Diablo II...")
			Return 0
		EndIf
	EndIf
	For $Retry = 0 To 9
		Send("{ESC}")
		If Not WinExists($D2WName) Then ExitLoop
		Sleep(500)
	Next
	WinClose($D2WName)
	WinKill($D2WName)
	If WinExists($D2WName) Then
		LogEvent(1, "A Diablo window still exists even though we tried killing it!")
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>D2Kill

Func ToBin($s)
	Return Number(Asc($s) - 18)
EndFunc

Func FromBin($s)
	Return Number($s - 30)
EndFunc

Func RealmChange ($RealmID)
	If IsAdmin () = 0 Then 
		LogEvent(1, "You must have adminstrative access to use realm chooser.")
		Return -2
	EndIf
	D2Close ()
	Local $sCurrent =  RegRead ('HKEY_CURRENT_USER\' & 'Software\Battle.Net\Configuration', "Diablo II Battle.net gateways")
	If @error Then
		LogEvent(1, "There was an error while getting current realm information.")
		Return -3
	EndIf
	Local $sStr
	For $s = 1 To Number(StringLen($sCurrent) / 2) Step 1
		$sStr &= StringLeft($sCurrent, 2) & " "
		$sCurrent = StringTrimLeft($sCurrent, 2)
	Next
	$sCurrent = StringSplit($sStr, " ")
	If $sCurrent[0] > 8 Then
		If $sCurrent[7] = $RealmID Then
			Return 1
		Else
			If $RealmID < 0 Then
				LogEvent(1, "Invalid RealmID choice, it needs to be a numerical value (1-x)")
				Return -1
			EndIf
			$sTemp = $sCurrent[7]
			$sCurrent[7] = ToBin($RealmID)
			RegWrite('HKEY_CURRENT_USER\' & 'Software\Battle.Net\Configuration', "Diablo II Battle.net gateways", "REG_BINARY", _ArrayToString($sCurrent, "", 1))
			If @error Then
				LogEvent(1, "Failed to update realm information, realm was not set.")
				Return 0
			EndIf
		EndIf
	Else
		LogEvent(1, "Failed to properly read realms, realm was not set.")
		Return -4
	EndIf
	Return 1
EndFunc


Func D2Close()
	Local $sRet = Opt("WinTitleMatchMode", 4)
	While WinExists("ClassName=Diablo II") = 1
	Sleep(10)
	If WinExists("ClassName=Diablo II") = 1 Then
	If MsgBox(33, "D2Au3 v" & $VersionNb, "Do you wish for D2Au3 to close '" & WinGetTitle("ClassName=Diablo II") & "'") = 1 Then
		WinKill("ClassName=Diablo II")
		WinClose("ClassName=Diablo II")
	EndIf
EndIf
WEnd
Opt("WinTitleMatchMode", $sRet)
EndFunc

;================================================
;Do a quick & effective game exit.
;Suitable for both emergency chickens, and standard save & exits.
;Returns 0 if failed
;Returns 1 if success
;================================================
Func Chicken()
	For $Retries = 1 To $ChickenRetries
		Send($KEY_ClearScreen)
		MouseUp("Right")
		MouseUp("Left")
		Send("{ESC}")
		$Timeout = TimerInit()
		While 1
			If IsMenuOpen() = 0 Then
				ExitLoop
			ElseIf TimerDiff($Timeout) > 500 Then
				LogEvent(2, "Failed to open the main menu, will retry... Retry # " & $Retries)
				ContinueLoop 2
			EndIf
			Sleep(100)
		WEnd
		MouseClick("Left", 400, 280, 1, 0)
		$Timeout = TimerInit()
		While TimerDiff($Timeout) < $ChickenTimeout
			If IsInGame() = 0 Then ExitLoop 2
			Sleep(100)
		WEnd
		If $Retries >= $ChickenRetries Then
			Return 0
		Else
			LogEvent(2, "Failed to chicken, Will retry the chicken...")
		EndIf
	Next
	Return 1
EndFunc   ;==>Chicken

;================================================
;Returns 0 if either a menu is open or we aren't in game.
;Returns 1 if the minipanel is in its expected position. (this requires it to be open)
;================================================
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

;================================================
;Determines weather or not we are in game by checking for the presence of the GUI bar
;Note: Will not work during act switching
;Returns 0 if not in game.
;Returns 1 if in game.
;================================================
Func IsInGame()
	If PixelGetColor(177, 559) <> 6579300 Then
		If PixelGetColor(610, 559) <> 3684408 Then
			Return 0
		EndIf
	EndIf
	Return 1
EndFunc   ;==>IsInGame

;================================================
;Puts the bot into sleep mode for $Sleep SECONDS. Usually used in case of non-fatal errors.
;================================================
Func BotSleep($Sleep = 60)
	$Timeout = TimerInit()
	While TimerDiff($Timeout) < ($Sleep * 1000)
		SplashTextOn("", "D2Au3 is in sleep mode for " & Round($Sleep - (TimerDiff($Timeout) / 1000)) & " seconds." & @CRLF & "See the logs to find out why." ,400, 44, 312, 375,-1 ,"System")
		Sleep(500)
	WEnd
EndFunc	

;================================================
; Provide the bot events log
; Event type:
; 0 = Information
; 1 = Error
; 2 = Warning
;================================================
Func LogEvent($Code, $String)
	$LogFile = FileOpen(@ScriptDir & "\Logs\Events.txt", 1)
	Select
		Case $Code = 0
			FileWriteLine($LogFile, @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " [" & @ScriptName & "][I]> " & $String)
		Case $Code = 1
			FileWriteLine($LogFile, @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " [" & @ScriptName & "][E]> " & $String)
		Case $Code = 2
			FileWriteLine($LogFile, @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " [" & @ScriptName & "][W]> " & $String)
	EndSelect
	FileClose($LogFile)
EndFunc   ;==>LogEvent

;================================================
; Displays a message box upon a fatal error.
;================================================
Func FatalErrorMsg($Message)
	MsgBox(16, "D2au3 Fatal Error!", $Message & @CRLF & @CRLF & "Please check the Event log at " & @ScriptDir & "\Logs\Events.txt for details." _
	& @CRLF & "Please be sure to include this log when either asking questions or reporting bugs.")
EndFunc

;================================================
; Function to stop the bot.
;================================================
Func ExitBot()
	ClearKeys()
	WinActivate($D2WName, "")
	LogEvent(1, "User has stopped the bot.")
	Exit
EndFunc   ;==>ExitBot

;================================================
; Function to pause the bot.
;================================================
Global $Paused
HotKeySet("{" & $Bot_PAUSE_HotKey & "}", "TogglePause")
Func TogglePause()
	$Paused = Not $Paused
	While $Paused
		Sleep(100)
		ToolTip('D2Au3 is "Paused"', 0, 0)
	WEnd
	ToolTip("")
EndFunc   ;==>TogglePause

;==============================
; Ensure the QOS of keyboard...
;==============================
Func ClearKeys()
	MouseUp("left")
	MouseUp("right")
EndFunc   ;==>ClearKeys

;================================================
;Debug function... replace the search pattern with whatever you need.
;Used for AdLibEnable Func for continuous checksum checking for those hard-to-find checksums.
;================================================
Func ShowSum()
	ToolTip(PixelChecksum($GameJoin[1], $GameJoin[2], $GameJoin[3], $GameJoin[4]), 0, 0)
EndFunc   ;==>ShowSum

;===============================================================
; Load Up keys and check if any user changes in mm.MultiKeys.ini
; Returns 0 upon failure to parse multikeys.ini Else returns 1
;===============================================================
Func LoadKeys()
	$LastKeysDate = IniRead(@ScriptDir & "\Config\mm.BotState.ini", "mmBotState", $LastKeysState, "0")
	$TS_KeysDate = FileGetTime($KeysFile_F, 0, 1)

	Local $D2_KeySetDump = IniReadSection($KeysFile_F, "MyD2CdKeys")
	
	If @error Then
		FatalErrorMsg("Failed while reading multikeys.ini. Check to make sure that it is formatted correctly.")
		LogEvent (1, "Failed while reading multikeys.ini. Check to make sure that it is formatted correctly.")
		Return 0
	EndIf

	Global $D2_KeySet[$D2_KeySetDump[0][0]][2]
	
	For $SetID = 1 To $D2_KeySetDump[0][0]
		If StringLen($D2_KeySetDump[$SetID][1]) <> 16 Then
			ReDim $D2_KeySet[Floor($SetID / 2) + 1][2]
			ExitLoop
		EndIf
		If StringInStr($D2_KeySetDump[$SetID][0], "D2_Classic-Key_") Then
			$D2_KeySet[StringReplace($D2_KeySetDump[$SetID][0], "D2_Classic-Key_", "") ][0] = $D2_KeySetDump[$SetID][1]
		Else
			$D2_KeySet[StringReplace($D2_KeySetDump[$SetID][0], "D2_Expansi-Key_", "") ][1] = $D2_KeySetDump[$SetID][1]
		EndIf
	Next

	If (StringLen($D2_KeySet[1][0]) <> 16) Or (StringLen($D2_KeySet[2][0]) <> 16) Then
		FatalErrorMsg("You must have at least 2 sets of working cdkeys in the " & $KeysFile_F & " file. Ensure these are correct.")
		LogEvent (3, "You must have at least 2 working complete cdkey sets in the " & $KeysFile_F & " file. Ensure these are correct. Stop.")
		Return 0
	EndIf
	
	For $SetID = 1 To UBound($D2_KeySet, 1) - 1
		If $TS_KeysDate <> $LastKeysDate Then
			CreateKeyFiles($SetID)
		EndIf
	Next

	LogEvent (1, UBound($D2_KeySet, 1) - 1 & " Cd-key sets available.")
	IniWrite(@ScriptDir & "\Config\mm.BotState.ini", "mmBotState", $LastKeysState, " " & $TS_KeysDate)
	Return 1
EndFunc   ;==>LoadKeys

;==================================
; Swapping d2 launching parameters.
;==================================
Func CdKeySwap()
	If $MultiKeys = "Yes" Then
		$SetID = IniRead(@ScriptDir & "\Config\mm.BotState.ini", "mmBotState", "LastUsedSet", 1)
		$SetID = $SetID + 1
		If $SetID > (UBound($D2_KeySet, 1) - 1) Then
			$SetID = 1
		EndIf
		InjectKeys($SetID)
	EndIf
EndFunc   ;==>CdKeySwap


;====================================================================================
; Inject the passed ID extracted-encrypted keyfiles into Diablo II Mpq files.
;====================================================================================

Func InjectKeys($SetID)
	If (ProcessExists("Game.exe") Or ProcessExists("Diablo II.exe")) Then
		FatalErrorMsg("Warning: A Diablo II process already exists. Close it and click OK.")
	EndIf
	SplashTextOn("", "D2Au3 : Cd-Key set " & $SetID & " : injecting...", 400, 22, 312, 375, 1, "system", "", "")
	For $CheckInject = 1 To 10
		If Not FileExists(@ScriptDir & '\Config\KeySet-' & $SetID) Then
			FatalErrorMsg("Could not find the " & @ScriptDir & "\Config\KeySet-" & $SetID & " folder. Edit and SAVE your Multikeys.ini or PlayKeys.ini files.")
			LogEvent (3, "Could not find set \Config\KeySet-" & $SetID & " folder. Stop.")
			Exit
		EndIf
		$injectTimer = TimerInit()
		$TS1_d2sfx = FileGetTime($D2Path & '\d2sfx.mpq', 0, 1)
		$TS1_d2char = FileGetTime($D2Path & '\d2char.mpq', 0, 1)
		$Mpq2k_F = @ScriptDir & '\Config\System\mpq2k.exe'
		$Mpq2k_D = @ScriptDir & '\Config\System'
		$D2sfx_F = $D2Path & '\d2sfx.mpq'
		$D2char_F = $D2Path & '\d2char.mpq'
		$Owner_M = 'data\global\sfx\cursor\curindx.wav'
		$ClaKey_M = 'data\global\sfx\cursor\wavindx.wav'
		$ExpKey_M = 'data\global\chars\am\cof\amblxbow.cof'
		$Owner_F = @ScriptDir & '\Config\KeySet-' & $SetID & '\curindx.wav'
		$ClaKey_F = @ScriptDir & '\Config\KeySet-' & $SetID & '\wavindx.wav'
		$ExpKey_F = @ScriptDir & '\Config\KeySet-' & $SetID & '\amblxbow.cof'
		RunWait('"' & $Mpq2k_F & '" a "' & $D2sfx_F & '" "' & $Owner_F & '" "' & $Owner_M & '"', $Mpq2k_D, @SW_HIDE)
		RunWait('"' & $Mpq2k_F & '" a "' & $D2sfx_F & '" "' & $ClaKey_F & '" "' & $ClaKey_M & '"', $Mpq2k_D, @SW_HIDE)
		RunWait('"' & $Mpq2k_F & '" a "' & $D2char_F & '" "' & $ExpKey_F & '" "' & $ExpKey_M & '"', $Mpq2k_D, @SW_HIDE)
		$InjectElapsed = TimerDiff($injectTimer)
		Sleep(1000 - $InjectElapsed)
		$TS2_d2sfx = FileGetTime($D2Path & '\d2sfx.mpq', 0, 1)
		$TS2_d2char = FileGetTime($D2Path & '\d2char.mpq', 0, 1)
		For $CheckDates = 1 To 50
			If $TS1_d2sfx <> $TS2_d2sfx And $TS1_d2char <> $TS2_d2char Then
				LogEvent (1, "Cd-Key set id " & $SetID & " correctly injected into .mpq files")
				SplashOff()
				Return
			Else
				Sleep(200)
			EndIf
		Next
		Sleep(1000)
	Next
	FatalErrorMsg("Error while injecting keys, Impossible to inject key set " & $SetID)
	LogEvent (3, "Error while injecting keys : Impossible to inject key set " & $SetID & ". Stop.")
	Exit
EndFunc   ;==>InjectKeys


;====================================================================================
; Create and Extract the encrypted keyfiles through the .mpq to D2Au3 config folder
;====================================================================================

Func CreateKeyFiles($SetID)
	If (ProcessExists("Game.exe") Or ProcessExists("Diablo II.exe")) Then
		FatalErrorMsg("Warning: A Diablo II process already exists. Close it and retry.")
	EndIf

	SplashTextOn("", "D2Au3 : Cd-Key set " & $SetID & " : Files -creation- and -extraction- Please wait...", 500, 22, 312, 375, 1, "system", "", "")

	DirRemove(@ScriptDir & '\Config\KeySet-' & $SetID, 1)
	DirCreate(@ScriptDir & '\Config\KeySet-' & $SetID)

	$D2Path_Reg = $D2Path & "\"
	$D2Path_Reg = StringReplace($D2Path_Reg, "\\", "\")

	$HKCU_b = 'HKEY_LOCAL_MACHINE\Software\Blizzard Entertainment\Diablo II'
	RegWrite($HKCU_b, 'owner', 'REG_SZ', $SetID)
	RegWrite($HKCU_b, 'd2cdkeympq', 'REG_SZ', 'd2sfx.mpq')
	RegWrite($HKCU_b, 'd2xcdkeympq', 'REG_SZ', 'd2char.mpq')
	RegWrite($HKCU_b, 'InstallPath', 'REG_SZ', $D2Path_Reg)
	RegWrite($HKCU_b, 'Save Path', 'REG_SZ', $D2Path_Reg & 'save\')
	RegWrite($HKCU_b, 'd2cdkey', 'REG_SZ', $D2_KeySet[$SetID][0])
	RegWrite($HKCU_b, 'd2xcdkey', 'REG_SZ', $D2_KeySet[$SetID][1])
	$HKLM_b = 'HKEY_CURRENT_USER\Software\Blizzard Entertainment\Diablo II'
	RegWrite($HKLM_b, 'owner', 'REG_SZ', $SetID)
	RegWrite($HKLM_b, 'd2cdkeympq', 'REG_SZ', 'd2sfx.mpq')
	RegWrite($HKLM_b, 'd2xcdkeympq', 'REG_SZ', 'd2char.mpq')
	RegWrite($HKLM_b, 'InstallPath', 'REG_SZ', $D2Path_Reg)
	RegWrite($HKLM_b, 'Save Path', 'REG_SZ', $D2Path_Reg & 'save\')
	RegWrite($HKLM_b, 'd2cdkey', 'REG_SZ', $D2_KeySet[$SetID][0])
	RegWrite($HKLM_b, 'd2xcdkey', 'REG_SZ', $D2_KeySet[$SetID][1])

	WinClose('Refill CdKey', '')
	ProcessWaitClose('d2-cdkey.exe', 5)

	Run(@ScriptDir & '\Config\System\d2-cdkey.exe', @ScriptDir & '\Config\System')

	$MpqSuccess = 0
	For $R = 1 To 50
		WinActivate('Refill CdKey', '')
		If WinActive('Refill CdKey') Then
			Send('^r')
			For $T = 1 To 50
				$T_d2sfx = FileGetTime($D2Path & '\d2sfx.mpq')
				$T_d2char = FileGetTime($D2Path & '\d2char.mpq')
				If $T_d2sfx[3] == @HOUR And $T_d2sfx[4] == @MIN And $T_d2char[3] == @HOUR And $T_d2char[4] == @MIN Then
					$MpqSuccess = 1
					ExitLoop 2
				EndIf
				Sleep(100)
			Next
		EndIf
		Sleep(100)
	Next

	Sleep(2000)
	WinClose('Refill CdKey', '')
	ProcessWaitClose('d2-cdkey.exe', 5)

	If $MpqSuccess == 0 Then
		FatalErrorMsg("Error with D2 Cd-Keys Unable to modify .mpq files")
		LogEvent (3, "Error with D2 Cd-Keys: Unable to modify .mpq files. Stop.")
		Exit
	EndIf
	LogEvent (1, 'D2 Cd-Keys: .mpq files refilled for Key set ' & $SetID & ' successfully.')

	$HKCU_b = 'HKEY_LOCAL_MACHINE\Software\Blizzard Entertainment\Diablo II'
	RegDelete($HKCU_b, 'owner')
	RegDelete($HKCU_b, 'd2cdkeympq')
	RegDelete($HKCU_b, 'd2xcdkeympq')
	RegDelete($HKCU_b, 'd2cdkey')
	RegDelete($HKCU_b, 'd2xcdkey')
	$HKLM_b = 'HKEY_CURRENT_USER\Software\Blizzard Entertainment\Diablo II'
	RegDelete($HKLM_b, 'owner')
	RegDelete($HKLM_b, 'd2cdkeympq')
	RegDelete($HKLM_b, 'd2xcdkeympq')
	RegDelete($HKLM_b, 'd2cdkey')
	RegDelete($HKLM_b, 'd2xcdkey')

	$Mpq2k_F = @ScriptDir & '\Config\System\mpq2k.exe'
	$Mpq2k_D = @ScriptDir & '\Config\System'
	$D2sfx_F = $D2Path & '\d2sfx.mpq'
	$D2char_F = $D2Path & '\d2char.mpq'
	$Owner_M = 'data\global\sfx\cursor\curindx.wav'
	$ClaKey_M = 'data\global\sfx\cursor\wavindx.wav'
	$ExpKey_M = 'data\global\chars\am\cof\amblxbow.cof'
	$Owner_D = @ScriptDir & '\Config\KeySet-' & $SetID
	$ClaKey_D = @ScriptDir & '\Config\KeySet-' & $SetID
	$ExpKey_D = @ScriptDir & '\Config\KeySet-' & $SetID
	$Owner_F = @ScriptDir & '\Config\KeySet-' & $SetID & '\curindx.wav'
	$ClaKey_F = @ScriptDir & '\Config\KeySet-' & $SetID & '\wavindx.wav'
	$ExpKey_F = @ScriptDir & '\Config\KeySet-' & $SetID & '\amblxbow.cof'

	RunWait('"' & $Mpq2k_F & '" e "' & $D2sfx_F & '" ' & $Owner_M & ' "' & $Owner_D & '"', $Mpq2k_D, @SW_HIDE)
	RunWait('"' & $Mpq2k_F & '" e "' & $D2sfx_F & '" ' & $ClaKey_M & ' "' & $ClaKey_D & '"', $Mpq2k_D, @SW_HIDE)
	RunWait('"' & $Mpq2k_F & '" e "' & $D2char_F & '" ' & $ExpKey_M & ' "' & $ExpKey_D & '"', $Mpq2k_D, @SW_HIDE)

	If FileExists($Owner_F) And FileExists($ClaKey_F) And FileExists($ExpKey_F) Then
		LogEvent (1, 'D2 Cd-Keys: Key set ' & $SetID & ' : Files successfully extracted from .mpq')
	Else
		FatalErrorMsg("Error with D2 Cd-Keys: Unable to extract Files for Key set " & $SetID)
		LogEvent (1, "Error with D2 Cd-Keys: Unable to extract Files for Key set " & $SetID & ". Stop.")
		Exit
	EndIf

	SplashOff()

EndFunc   ;==>CreateKeyFiles