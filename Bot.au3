;================================================
;===================== D2Au3 ====================
;============= http://www.mmbot.net =============
;============= irc.omnesia.net:6667 =============
;================================================
;See Credits.txt for a list of contributors
;See OOG.au3 for functions, return codes, and other comments.
;This is the Main out-of-game bot file. It handles cdkeys, D2 process control, game creation, life checking, and In-game thread process control.
;================================================

; VERSION :
Global $VersionNb = "0.01"

;================================================
;Pre-Dim variables. (see the comments)
;================================================
#Include "Sources/DimVars.au3"
;================================================
;Load Vars from D2.Config.ini and internal Declarations
;
;D2au3 dynamically loads all user-configurable variables from D2.Config.ini. Variables are litterally assigned based on their variable name in the config file.
;================================================
If FileExists(@ScriptDir & "\Config\Config.ini") = 0 Then
	LogEvent (1, "Cannot find " & @ScriptDir & "\Config\Config.ini")
	FatalErrorMsg("Cannot find " & @ScriptDir & "\Config\Config.ini")
	Exit
EndIf

$AllVars = IniReadSection(@ScriptDir & "\Config\Config.ini", "oog")
For $n = 1 To $AllVars[0][0]
	Assign($AllVars[$n][0], $AllVars[$n][1])
Next

$KeysFile_F = @ScriptDir & "\Config\MultiKeys.ini"
$LastKeysState = "LastKeysDate"
Dim $D2_KeySet
Dim $SetID

;================================================
; Log event head
;================================================
LogEvent (0, "")
LogEvent (0, "========================================")
LogEvent (0, "D2Au3 " & $VersionNb & " was launched for " & $CharMode & " mode.")
LogEvent (0, "========================================")
LogEvent (0, "")
LogEvent (0, "Config.ini Variables loaded.")

;================================================
;Includes
;================================================
#include <GUIConstants.au3>
#Include <Array.au3>
#Include <String.au3>
#Include "Sources/Common/Checksums.au3"
#Include "Sources/Common/Functions.au3"
#Include "Sources/OOG/Functions.au3"
#include "Sources/OOG/Confirmation.au3"
#Include "Sources/PotThread/PotThread.au3"

;================================================
;Bot Launching GUI This has been changed from mmbot. The Launching GUI now controls both Battle and singleplayer mode. There is no longer a SEQ mode.
;================================================
If ($CharMode <> "Battle") AND ($CharMode <> "Single") Then
	FatalErrorMsg(0, "Invalid Game Mode.", @CRLF _
	& "Ensure CharMode is correct in Config.ini. Valid modes are: 'Single', or 'Battle'" & @CRLF)
	LogEvent (1, "Invalid Character mode selected. Valid modes are: Battle, or Single")
	LogEvent (1, "Stopping the bot.")
	Exit
EndIf
		
Confirmation ($CharMode) ;This function contains the entire GUI and status download functions. (#Include "Confirmation.au3")
While $LoopExit = 0 ;Wait for the user to finish with the gui
	Sleep(100)
WEnd

If $CancelLaunch = 2 Then
	LogEvent (0, "User cancelled the launching.")
	LogEvent (0, "Stopping the bot.")
	Exit
EndIf

GUIDelete()

If $CharMode = "Battle" Then
	If $MMStatus = 1 Then LogEvent (2, "MMBOT launched for battle mode with DETECTABLE status, User was warned.")
	If $MMStatus = 2 Then LogEvent (2, "Error downloading MMstatus, Bot was launched anyways. User was warned.")
EndIf

;================================================
;Miscellaneous pre-botting tasks.
;================================================
Opt("PixelCoordMode", 2)
Opt("MouseCoordMode", 2)
Opt("RunErrorsFatal", 0)

If @OSTYPE == 'WIN32_WINDOWS' Then
	FatalErrorMsg("Incorrect operating system", "mm.BOT is not compatible with win 9x OS' (95/98/Me.) Sorry.")
	Exit
EndIf

;================================================
;Windows: 32bit
;Wine:    24bit
;Other:   ERROR
;================================================
If @DesktopDepth <> 32 AND @DesktopDepth <> 24 Then
	FatalErrorMsg("Incorrect desktop bit depth. You must use 32 bit graphics.")
	Exit
EndIf

If WinExists($D2WName) Then
	FatalErrorMsg("Looks like a d2 window is already open! Close it before launching the bot.")
	Exit
EndIf

If $CharMode = "Battle" Then
	If IsInt($CharRealm) = 0 Then
		Local $Realms = IniReadSection(@ScriptDir & "\Config\Realms.ini", "D2.Realms")
		
		For $i = 1 To $Realms[0][0] Step 1
			If StringUpper($Realms[$i][0]) = StringUpper($CharRealm) Then
				$CharRealmPos = $Realms[$i][1]
				$CharRealm = $Realms[$i][0]
				ExitLoop
			EndIf
		Next
	Else
		$CharRealmPos = $CharRealm
		$CharRealm = "Unknown"
	EndIf
	
	If RealmChange($CharRealmPos) = 1 Then
		LogEvent(0, "Successfully changed realm to '" & $CharRealm & "' Pos " & $CharRealmPos)
	EndIf
EndIf

HotKeySet("{" & $Bot_STOP_HotKey & "}", "ExitBot")
HotKeySet("{" & $Bot_PAUSE_HotKey & "}", "TogglePause")

Global $RunCount = 0

Switch $CharDifficulty
	Case "Normal"
		$CharDifficulty = 0
	Case "Nightmare"
		$CharDifficulty = 1
	Case "Hell"
		$CharDifficulty = 2
	Case Else
		FatalErrorMsg("Valid paramaters for CharDifficulty are: 'Normal', 'Nightmare', or 'Hell'")
		Exit
EndSwitch

; Load up Keys from multikeys.ini
;================================
If $MultiKeys = "Yes" Then
	If $CharMode = "Battle" Then
		If LoadKeys () = 0 Then
			Exit
		EndIf
		
		CdKeySwap ()
	EndIf
EndIf

;================================================
;================ Main Bot Loop =================
;================================================
;Here, we have the game creation loop. While in game, the inner loop will check life and perform any tasks requiring continuous polling, while the gamethread
;runs and performs all in-game tasks. The bot will advance to the next run when either this script terminates the game thread due to chicken settings, or if
;the game thread terminates on its own when the run finishes, or fails for whatever reason.
;================================================
While 1	
	For $Retry = 1 To 4
		If $Retry = 4 Then
			LogEvent(1, "Failed to log in after 3 retries. Bot will sleep.")
			BotSleep($LoginFailSleep)
			ContinueLoop 2
		EndIf
		
		Switch LaunchD2 ($CharMode)
			Case 0
				LogEvent (0, "Failed to Log in. Restarting D2. Retry #" & $Retry)
				If WinExists($D2WName) Then
					D2Kill ()
				EndIf
				ContinueLoop
			Case 1
				LogEvent (0, "Successfully Launched Diablo II and logged in.")
				ExitLoop
			Case 2
				LogEvent (0, "Failed to Log in. Restarting D2. Retry #" & $Retry)
				If WinExists($D2WName) Then
					D2Kill ()
				EndIf
				
				If $MultiKeys = "Yes" Then
					CdKeySwap()
				Else
					LogEvent(2, "CdKey in use and no other keys available. Will sleep and retry. Retry #" & $Retry)
					BotSleep(120)
					ContinueLoop 2
				EndIf
		EndSwitch
	Next

	For $RunCount = 1 To $Run_Interval
		Switch CreateGame ($CharMode, $Run_GameName, $Run_PasswordType, $CharSlot)
			Case 0
				LogEvent (0, "Restarting D2")
				D2Kill ()
				ContinueLoop 2
			Case 1
				LogEvent(0, "Looks like we've made it in-game okay... Bot will now Launch and turn control over to " & $IGPathName & " and proceed with life checking routine.")
				
				If StringRight($IGPathName, 4) = ".au3" Then
					If @Compiled Then
						$InGamePID = Run(@ScriptName & " " & $IGPathName)
					Else
						$InGamePID = Run(@AutoItExe & " " & $IGPathName)
					EndIf
				Else
					$InGamePID = Run(@ScriptDir & "/" & $IGPathName)
				EndIf

				If ProcessWait($InGamePID, 10) = 0 Then
					LogEvent(1, "Main bot thread timed out while attempting to execute the out of game process: " & @ScriptDir & "\" & $IGPathName & " after 10 seconds.")
				EndIf
			Case 2
				LogEvent(1, "Error while attempting to create a game, Probably a configuration problem. Bot will terminate.")
				Exit
		EndSwitch
		
		If $UseMerc = "No" Then $MercPercent = "None" 
		If $RunCount > 1 Then ChickenWait()
		GetStats("Life")
		GetStats("Mana")
		GetStats("Merc")
		ShowTip()
		
;================================================
; IN GAME MAIN LOOP
; All Life Checking and in-game polling goes here!
;================================================
		;While ProcessExists($InGamePID) AND (IsInGame() = 1) ; <--- ProcessExists($InGamePID) does not work.. needs fixed
		While (IsInGame() = 1)
			Exit
			Sleep($ScanDelay) ;Keeps main loop from monopolizing your CPU! It can usually be set pretty low, and will determine how responsive the life check is.
			UpdateStats()
		WEnd 
	Next
WEnd
;================================================