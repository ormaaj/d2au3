;================================================
;This file contains the Bot Launching GUI functions.
;It also downloads and interprets the mmstatus and mmnews files.
;================================================

#Include <array.au3>
Func Confirmation($CharMode)

	Opt("GUIOnEventMode", 1)
	Global $LoopExit = 0
	Global $StatFileName = "MMstatus.ini"
	Global $NewsFileName = "MMnews.ini"
	
	If $CharMode = "Battle" Then
		SplashTextOn("", "D2Au3: Downloading MMstatus...", 400, 22, 312, 375, 1, "system", "", "")
		If FileExists(@ScriptDir & "\Logs\" & $StatFileName) Then FileDelete(@ScriptDir & "\Logs\" & $StatFileName)
		InetGet($MMstatusURL, $StatFileName, 1)
		FileMove(@ScriptDir & "\" & $StatFileName, @ScriptDir & "\Logs\" & $StatFileName, 1)
		SplashOff()
	EndIf

	$Confirmation = " * You MUST read ALL bot documentation before running this bot! D2au3 will not function without configuration!" & @CRLF _
			 & " * D2au3 is 100% FREEWARE and should never be sold for money!!" & @CRLF _
			 & " * USE OF THIS BOT IS AT YOUR OWN RISK!!! The creators of D2au3 take no responsibility if you get banned!" & @CRLF _
			 & " * Enjoy D2au3? Please consider a Donation to help cover hosting and beer costs!"

	;Dimensions:
	$IndicatorY = 305
	$NewsY = 70
	$MessageY = 10
	$ButtonsY = 360
	$ButtonWidth = 85
	$ButtonInterval = 12

	$GUI = GUICreate("O_o  O_o  D2Au3 v. " & $VersionNb & ": Launching D2Au3 for " & $CharMode & " Mode  o_O  o_O", 600, 420)
	GUICtrlCreateLabel("", 5, $IndicatorY, 590, 45, $SS_ETCHEDFRAME) ;Ctrl id: 3
	GUICtrlCreateLabel("D2Au3 Detectability Status:", 10, $IndicatorY + 5, 200, 15) ;ctrl id: 4
	GUICtrlSetFont(4, 9, 600)
	GUICtrlCreateLabel("", 210, $IndicatorY + 5, 60, 13) ;Detectability indicator, ctrl id: 5
	GUICtrlCreateLabel("", 10, $IndicatorY + 25, 580, 15) ;Detectability note, ctrl id: 6

	GUICtrlCreateLabel("mm.News:", 10, $NewsY, 75, 20) ;MMnews Label, ctrl id: 7
	GUICtrlSetFont(7, 9, 600)
	GUICtrlCreateEdit("", 10, $NewsY + 20, 580, 200, $WS_VSCROLL) ;Omnesia News, ctrl id: 8

	GUICtrlCreateLabel("", 5, 5, 590, 65, $SS_ETCHEDFRAME) ;Message Frame, ctrl id: 9
	GUICtrlCreateLabel($Confirmation, 10, $MessageY, 580, 55) ;Message, ctrl id: 10

	$Buttonpos = 15
	$LaunchButton = GUICtrlCreateButton("Launch D2Au3", $Buttonpos, $ButtonsY, $ButtonWidth, 30) ;ctrl id: 12
	$Buttonpos = $Buttonpos + ($ButtonWidth + $ButtonInterval)
	$ManualButton = GUICtrlCreateButton("D2Au3 Manual", $Buttonpos, $ButtonsY, $ButtonWidth, 30) ;ctrl id: 13
	$Buttonpos = $Buttonpos + ($ButtonWidth + $ButtonInterval)
	$ForumButton = GUICtrlCreateButton("Visit mmbot.net", $Buttonpos, $ButtonsY, $ButtonWidth, 30) ;ctrl id: 14
	$Buttonpos = $Buttonpos + ($ButtonWidth + $ButtonInterval)
	$MMButton = GUICtrlCreateButton("Donate", $Buttonpos, $ButtonsY, $ButtonWidth, 30) ;ctrl id: 15
	$Buttonpos = $Buttonpos + ($ButtonWidth + $ButtonInterval)
	$CreditsButton = GUICtrlCreateButton("Credits", $Buttonpos, $ButtonsY, $ButtonWidth, 30) ;ctrl id: 16
	$Buttonpos = $Buttonpos + ($ButtonWidth + $ButtonInterval)
	$ExitButton = GUICtrlCreateButton("Exit", $Buttonpos, $ButtonsY, $ButtonWidth, 30) ;ctrl id: 17
	
	;Create the menus/menu items
	Local $ConfigID[6] ;Contains ControlIDs of config menu items
	$ConfigID[0] = GuiCtrlCreateMenu("Configuration")
	$ConfigID[1] = GUICtrlCreateMenuItem ("Launch Bot", $ConfigID[0])
	$ConfigID[2] = GUICtrlCreateMenuItem ("Bot Configuration", $ConfigID[0])
	$ConfigID[3] = GUICtrlCreateMenuItem ("PKID Configuration", $ConfigID[0])
	$ConfigID[4] = GUICtrlCreateMenuItem ("Multikeys Configuration", $ConfigID[0])
	$ConfigID[5] = GUICtrlCreateMenuItem ("Exit", $ConfigID[0])
	
	Local $HelpID[6] ;Contains ControlIDs of Help menu items
	$HelpID[0] = GuiCtrlCreateMenu("Help")
	$HelpID[1] = GUICtrlCreateMenuItem ("Bot Documentation", $HelpID[0])
	$HelpID[2] = GUICtrlCreateMenuItem ("Visit mmbot.net", $HelpID[0])
	$HelpID[3] = GUICtrlCreateMenuItem ("Ask a Question", $HelpID[0])
	$HelpID[4] = GUICtrlCreateMenuItem ("Donate", $HelpID[0])
	$HelpID[5] = GUICtrlCreateMenuItem ("Credits", $HelpID[0])
	
	;Menu Events
	GUICtrlSetOnEvent($ConfigID[1], "Launch")
	GUICtrlSetOnEvent($ConfigID[2], "Config")
	GUICtrlSetOnEvent($ConfigID[3], "PkidConfig")
	GUICtrlSetOnEvent($ConfigID[4], "Multikeys")
	GUICtrlSetOnEvent($ConfigID[5], "Terminate")
	
	;Button Events
	GUICtrlSetOnEvent($LaunchButton, "Launch")
	GUICtrlSetOnEvent($ManualButton, "Manual")
	GUICtrlSetOnEvent($ForumButton, "Forums")
	GUICtrlSetOnEvent($MMButton, "MMSite")
	GUICtrlSetOnEvent($CreditsButton, "Credits")
	GUICtrlSetOnEvent($ExitButton, "terminate")
	GUICtrlSetOnEvent($ConfigID, "Credits")
	GUISetOnEvent($GUI_Event_Close, "Terminate") ;Terminate when the gui is closed.
	
	GUICtrlSetState($LaunchButton, $GUI_FOCUS)

	If FileExists(@ScriptDir & "\Logs\" & $StatFileName) And $CharMode = "Battle" Then
		Global $MMNewsVersionA = IniRead(@ScriptDir & "\logs\" & $StatFileName, "Status", "Version", "")
		Global $MMNewsVersionB = IniRead(@ScriptDir & "\logs\" & $NewsFileName, "News", "Version", "")
		If $MMNewsVersionA <> $MMNewsVersionB Or FileExists(@ScriptDir & "\Logs\" & $NewsFileName) = 0 Then
			SplashTextOn("", "D2Au3: Downloading MMnews...", 400, 22, 312, 375, 1, "system", "", "")
			If InetGet($MMnewsURL, $NewsFileName, 1) = 1 Then
				If FileExists(@ScriptDir & "\Logs\" & $NewsFileName) Then FileDelete(@ScriptDir & "\Logs\" & $NewsFileName)
				FileMove(@ScriptDir & "\" & $NewsFileName, @ScriptDir & "\Logs\" & $NewsFileName, 1)
			EndIf
			SplashOff()
		EndIf
		Global $MMStatus = IniRead(@ScriptDir & "\Logs\" & $NewsFileName, "News", "Status", 2)
	Else
		Global $MMStatus = "2"
		LogEvent (3, "Error Downloading MMstatus files. Check to ensure you are connected to the internet, and that your firewall isn't blocking the download.")
	EndIf

	If ($CharMode = "Single") And FileExists(@ScriptDir & "\Logs\" & $StatFileName) Then
		GUICtrlSetBkColor(5, 0xffff00)
		GUICtrlSetData(5, "SinglePlayer")
		GUICtrlSetData(6, "MMstatus file exists, Displaying last known news download.")
	ElseIf ($CharMode = "Single") And FileExists(@ScriptDir & "\Logs\" & $StatFileName) = 0 Then
		GUICtrlSetBkColor(5, 0xffff00)
		GUICtrlSetData(5, "SinglePlayer")
		GUICtrlSetData(6, "No news file has been downloaded.")
	ElseIf $MMStatus = 0 Then
		GUICtrlSetBkColor(5, 0x00ff00)
		GUICtrlSetData(5, "Safe")
		GUICtrlSetData(6, "MMstatus file downloaded successfully. D2Au3 is currently indicated as 'safe' for battlenet use.")
	ElseIf $MMStatus = 1 Then
		GUICtrlSetBkColor(5, 0x0000ff)
		GUICtrlSetData(5, "Detectable")
		GUICtrlSetData(6, "WARNING: D2Au3 has been flagged as 'Detectable'. If you proceed to use the bot, there is a very high chance of ban.")
		LogEvent (1, "WARNING: D2Au3 has been flagged as Detectable. Running the bot is EXTREMELY dangerous!")
	Else
		GUICtrlSetBkColor(5, 0xff0000)
		GUICtrlSetData(5, "Error")
		GUICtrlSetData(6, "WARNING: Error reading the D2Au3 status file. File is either corrupt, or there was a problem downloading the file.")
		LogEvent (1, "WARNING: There was an error in downloading the MMstatus file.")
	EndIf

	$MMNews = IniRead(@ScriptDir & "\Logs\" & $NewsFileName, "News", "News", "No News is Good News. =/")
	$MMNews = StringReplace($MMNews, "|", "" & @CRLF & "")
	
	If FileExists(@ScriptDir & "\Logs\" & $NewsFileName) Then
		GUICtrlSetData(8, $MMNews)
	ElseIf $CharMode = "Single" Then
		GUICtrlSetData(8, "No news file found. Launching bot for Single Player.")
	Else
		GUICtrlSetData(8, "No news file found. Check to make sure the download urls in your mm.bot.ini file are correct, and that you are connected to the internet.")
	EndIf
	GUISetState(@SW_SHOW)
EndFunc   ;==>Confirmation

Func Launch()
	Global $CancelLaunch = 0
	If $CharMode = "Battle" Then
		If $MMStatus = 2 Then
			Global $CancelLaunch = MsgBox(257, "WARNING, Error Downloading MMStatus File!", "There was an error downloading the MMStatus.ini file." & @CRLF _
					 & "Without this, you cannot recieve information about bot detectability status & news regarding the bot." & @CRLF _
					 & "Check to make sure you are connected to the internet and that your firewall isn't obstructing the download." & @CRLF _
					 & "Press 'OK' to launch the bot anyways. Press 'Cancel' to terminate.")
		EndIf
		If $MMStatus = 1 Then
			Global $CancelLaunch = MsgBox(257, "WARNING, Bot is Detectable!", "The D2Au3 team has determined that the D2Au3 is currently Detectable." & @CRLF _
					 & "If you proceed to launch the bot, there is a VERY high risk of you being banned. Please visit: http://www.mmbot.net/" & @CRLF _
					 & "Press 'OK' to launch the bot anyways. Press 'Cancel' to terminate (Recomended)")
		EndIf
	EndIf
	Global $LoopExit = 1
EndFunc   ;==>Launch

Func Config ()
	ShellExecute(@ScriptDir & "\Config.ini")
EndFunc

Func PkidConfig ()
	ShellExecute(@ScriptDIr & "\Config\mm.PKID.ini")
EndFunc

Func Multikeys ()
	ShellExecute(@ScriptDir & "\Config\mm.MultiKeys.ini")
EndFunc

Func Manual ()
	ShellExecute("mm.bot.manual.htm")
EndFunc   ;==>Manual

Func Forums ()
	ShellExecute("http://www.mmbot.net/")
EndFunc   ;==>Forums

Func MMsite ()
	ShellExecute("http://www.mmbot.net/modules.php?name=Forums&file=lwdonate")
EndFunc   ;==>MMsite

Func Credits ()
	ShellExecute(@ScriptDir & "\credits.txt")
EndFunc   ;==>Credits

Func terminate ()
	Global $CancelLaunch = 2
	Global $LoopExit = 1
EndFunc   ;==>terminate