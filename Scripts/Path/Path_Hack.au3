#include-once
Global $sLevel[200] = [ 100, "Rogue Encampment", "Blood Moor", "Cold Plains", "Stony Field", "Dark Wood", "Black Marsh", "Tahome Highland", "Den of Evil", "Cave Level 1", "Underground Passage Level 1", "Hole Level 1", "Pit Level 1", "Cave Level 2", "Underground Passage Level 2", "Hole Level 2", "Pit Level 2", "Burial Grounds", "Crypt", "Mausoleum", "Forgotten Tower", "Tower Cellar Level 1", "Tower Cellar Level 2", "Tower Cellar Level 3", "Tower Cellar Level 4", _
"Tower Cellar Level 5", "Monastery Gate", "Outer Cloister", "Barracks", "Jail Level 1", "Jail Level 2", "Jail Level 3", "Inner Cloister", "Cathedral", "Catacombs Level 1", "Catacombs Level 2", "Catacombs Level 3", "Catacombs Level 4", "Tristram", "The Secret Cow Level", _
"Lut Gholein", "Rocky Waste", "Dry Hills", "Far Oasis", "Lost City", "Valley of Snakes", "Canyon of the Magi", "Sewers Level 1", "Sewers Level 2", "Sewers Level 3", "Harem Level 1", "Harem Level 2", "Palace Cellar Level 1", "Palace Cellar Level 2", "Palace Cellar Level 3", _
"Stony Tomb Level 1", "Halls of the Dead Level 1", "Halls of the Dead Level 2", "Claw Viper Temple Level 1", "Stony Tomb Level 2", "Halls of the Dead 3", "Claw Viper Temple Level 2", "Maggot Lair Level 1", "Maggot Lair Level 2", "Maggot Lair Level 3", "Ancient Tunnels", _
"Tal Rasha's Tomb", "Tal Rasha's Tomb", "Tal Rasha's Tomb", "Tal Rasha's Tomb", "Tal Rasha's Tomb", "Tal Rasha's Tomb", "Tal Rasha's Tomb", "Duriel's Lair", "Arcane Sanctuary", _
"Kurast Docktown", "Spider Forest", "Great Marsh", "Flayer Jungle", "Lower Kurast", "Kurast Bazaar", "Upper Kurast", "Kurast Causeway", "Travincal", "Spider Cave", "Spider Cavern", "Swampy Pit Level 1", "Swampy Pit Level 2", "Flayer Dungeon Level 1", "Flayer Dungeon Level 2", "Swampy Pit Level 3", "Flayer Dungeon Level 3", "Sewers Level 1", "Sewers Level 2", "Ruined Temple", "Disused Fane", "Forgotten Reliquary", "Forgotten Temple", "Ruined Fane", "Disused Reliquary", "Durance of Hate Level 1", "Durance of Hate Level 2", "Durance of Hate Level 3", _
"The Pandemonium Fortress", "Outer Steppes", "Plains of Despair", "City of the Damned", "River of Flame", "Chaos Sanctum", _
"Harrogath", "Bloody Foothills", "Figid Highlands", "Arreat Plateau", "Crystalized Cavern Level 1", "Cellar of Pity", "Crystalized Cavern Level 2", "Echo Chamber", "Tundra Wastelands", "Glacial Caves Level 1", "Glacial Caves Level 2", "Arreat Summit", "Nihlathaks Temple", _
"Halls of Anguish", "Halls of Pain", "Halls of Vaught", "Hell1", "Hell2", "Hell3", "The Worldstone Keep Level 1", "The Worldstone Keep Level 2", "The Worldstone Keep Level 3", "Throne of Destruction", "The Worldstone Chamber", "Matron's Den", "Forgotten Sands", "Furnace of Pain", "Tristram" ]

Opt("WinTitleMatchMode", 4)
Global $ProcessID = WinGetProcess("ClassName=Diablo II","")
If $ProcessID = -1 Then
	MsgBox(4096, "ERROR", "Failed to detect process.")
	Exit
EndIf

Global $sHan = _MemoryOpen($ProcessID)
If @error Then Exit


Func Telweeport ()
	Local $sLevel = GetCurrentLevel ($sHan)
	Switch $sLevel
		Case "Figid Highlands"
			TeleBlock(214, -142)
			TeleBlock(86, -404)
			AttackMonster()
			Attack ()
			BlindTele(450, 528)
			TeleBlock(202, 108)
;~ 			TeleBlock(297, 186)
			TeleBlock(126, 255)
			TeleBlock(282, 488)
			TeleBlock(389, 341)
			TeleBlock(389, 341)
			Attack ()
		Case "Black Marsh"
			TeleTo("Forgotten Tower", "{NUMPAD8}")
			TeleTo("Tower Cellar Level 1")
			TeleTo("Tower Cellar Level 2")
			TeleTo("Tower Cellar Level 3")
			TeleTo("Tower Cellar Level 4")
			TeleTo("Tower Cellar Level 5")
			BlindTele(41, 9)
			TeleBlock(14, -108)
			TeleBlock(175, -297)
			BlindTele(23, 41)
			TeleBlock(-171,130)
			Attack ()
			TeleBlock(-548, 278)
			Attack ()
		Case "Catacombs Level 2"
			TeleTo("Catacombs Level 3")
			TeleTo("Catacombs Level 4")
			TeleBlock(350,-196)
			TeleBlock(34,-453)
			TeleBlock(526,-99)
			Attack ()
		Case "Durance of Hate Level 2"
			TeleTo("Durance of Hate Level 3")
		Case "Arcane Sanctuary"
			Send("{NUMPAD7}")
		Case "Nihlathaks Temple"
			TeleTo("Halls of Anguish")
			TeleTo("Halls of Pain")
			TeleTo("Halls of Vaught")
			Send("{NUMPAD8}")
		Case Else
			ToolTip($sLevel & " does not have a preset tele sequence.")
			Sleep(500)
			ToolTip("")
	EndSwitch
EndFunc

Func GetCurrentLevel ($sHandle=-1)
	Local $sCloseHandle = 0
	If $sHandle = -1 Then;We have to open memory ourselves
		Local $sCloseHandle = 1
		Local $sHa = Opt("WinTitleMatchMode", 4)
		Local $sD2ProID = WinGetProcess("ClassName=Diablo II")
		Opt("WinTitleMatchMode", $sHa)
		If $sD2ProID = -1 Then Return -1
		$sHandle = _MemoryOpen($sD2ProID)
		If @error Then Return 0
	EndIf
	Local $sCurLevelId = _MemoryRead(0x6FBCBAA4, $sHandle)
	If @error Then Return -2
	If $sCurLevelId > UBound($sLevel) Then Return -3
	If $sCloseHandle = 1 Then
		_MemoryClose($sHandle)
	EndIf
	Return $sLevel[$sCurLevelId]
EndFunc

Func GetAct ($sHandle=-1)
	Local $sCloseHandle = 0
	If $sHandle = -1 Then;We have to open memory ourselves
		If IsDeclared("sHan") = 0 Then
			Local $sCloseHandle = 1
			Local $sHa = Opt("WinTitleMatchMode", 4)
			Local $sD2ProID = WinGetProcess("ClassName=Diablo II")
			Opt("WinTitleMatchMode", $sHa)
			If $sD2ProID = -1 Then Return -1
			$sHandle = _MemoryOpen($sD2ProID)
			If @error Then Return 0
		Else
			$sHandle = $sHan
		EndIf
	EndIf
	Local $sCurLevelId = _MemoryRead(0x6FBCBAA4, $sHandle)
	If @error Then Return -2
	If $sCurLevelId > UBound($sLevel) Then Return -3
	If $sCloseHandle = 1 Then
		_MemoryClose($sHandle)
	EndIf
	Select
		Case $sCurLevelId < 40
			Return 1
		Case $sCurLevelId < 75
			Return 2
		Case $sCurLevelId < 103
			Return 3
		Case $sCurLevelId < 109
			Return 4
		Case $sCurLevelId >= 109
			Return 5
	EndSelect
EndFunc

Func TeleTo($sLevel, $sNum="{NUMPAD7}", $sTimeOut=2000)
	Send($sNum)
	Local $sTimer = TimerInit ()
	Do
		If TimerDiff($sTimer) > $sTimeOut Then Send($sNum)
		Sleep(250)
	Until GetCurrentLevel ($sHan) = $sLevel
EndFunc

Func BlindThele($sX, $sY)
	SendKey("Teleport")
	FastClick("Right", $sX, $sY)
	Sleep(200)
	TeleCheck(2500, 100)
	Return 1
EndFunc

Func TeleBblock($sX, $sY)
	Local $sPixel = PixelSearch(0, 0, 800, 600, 1637376, 2, 10)
	If @error Then
;~ 		LogEvent(1, "Failed to find the block.")
;~ 		TPToTown()
		Return SetError(1, 1, 0)
	EndIf
	Local $sRight = $sPixel[0]
	Do
		$sRight += 1
	Until PixelGetColor($sRight, $sPixel[1]) <> 1637376
	Local $sBottom = $sPixel[1]
	Do
		$sBottom += 1
	Until PixelGetColor($sPixel[0], $sBottom) <> 1637376
	$sPixel[0] = Number($sRight - 18) + $sX
	$sPixel[1] = Number($sBottom - 34) + $sY
	MouseMove($sPixel[0], $sPixel[1])
	SendKey("Teleport")
	FastClick("Right", $sPixel[0], $sPixel[1])
	Sleep(200)
	TeleCheck(2500, 200)
	Return $sPixel
EndFunc

Func TeleChehcker()
	Local $sPixel = PixelSearch(0, 0, 800, 600, 1637376, 2, 10)
	If @error Then
;~ 		LogEvent(1, "Failed to find the block.")
;~ 		TPToTown()
		Return SetError(1, 1, 0)
	EndIf
	Local $sRight = $sPixel[0]
	Do
		$sRight += 1
	Until PixelGetColor($sRight, $sPixel[1]) <> 1637376
	Local $sBottom = $sPixel[1]
	Do
		$sBottom += 1
	Until PixelGetColor($sPixel[0], $sBottom) <> 1637376
	Local $sPos = MouseGetPos ()
	$sPixel[0] = $sPos[0] - Number($sRight - 18)
	$sPixel[1] = $sPos[1] - Number($sBottom - 34)
	Return $sPixel
EndFunc

Func TPToTown ()
	Send("{SPACE}")
EndFunc