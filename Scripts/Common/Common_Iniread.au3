;Common_IniRead.au3
Global $iKey[30]
Global Const Enum $kClearScreen = 0, $kInventory, $kQuest, $kHireling, $kTownPortal, $kBattleCommands, $kBattleOrders, $kStandstill, $kShowBelt, $kBelt1, _
$kBelt2, $kBelt3, $kBelt4, $kSwap, $kShowItems, $kAutomap, $kHolyShield, $kMedi, $kRedempt, $kCleansing, $kVigor, $kZeal, $kFant, $kSmite, $kFoh, $kConv, _
$kHammer, $kConc, $kTeleport

Global $iConfig[2]
Global Const Enum $nClass = 0,$nBuild

$iStashGoldAm = Int(IniRead(@ScriptDir & "\Config\D2Au3.ini", "Item", "StashGoldAmount", 100000))
$iKey[$kClearScreen] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "ClearScreen", "")
$iKey[$kInventory] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Inventory", "")
$iKey[$kQuest] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "QuestLog", "")
$iKey[$kHireling] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Hireling", "")
$iKey[$kTownPortal] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "TownPortal", "")
$iKey[$kBattleOrders] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "BattleOrders", "")
$iKey[$kBattleCommands] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "BattleCommands", "")
$iKey[$kStandstill] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Standstill", "")
$iKey[$kShowBelt] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "ShowBelt", "")
$iKey[$kBelt1] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Belt1", "")
$iKey[$kBelt2] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Belt2", "")
$iKey[$kBelt3] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Belt3", "")
$iKey[$kBelt4] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Belt4", "")
$iKey[$kSwap] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Swap", "")
$iKey[$kShowItems] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "ShowItems", "")
$iKey[$kAutomap] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Automap", "")
$iKey[$kTeleport] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Teleport", "")

$iConfig[$nClass] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "D2Au3", "Class", "")

Switch $iConfig[$nClass]
	Case "Paladin"
		$iConfig[$nBuild] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "D2Au3", "Build", "")
		$iKey[$kHolyShield] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "HolyShield", "")
		$iKey[$kMedi] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Medi", "")
		$iKey[$kRedempt] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Redemption", "")
		$iKey[$kCleansing] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Cleansing", "")
		$iKey[$kVigor] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Vigor", "")
		Switch $iConfig[$nBuild]
			Case "Zealer"
				$iKey[$kZeal] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Zeal", "")
				$iKey[$kFant] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Fant", "")
			Case "Smiter"
				$iKey[$kSmite] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Smite", "")
				$iKey[$kFant] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Fant", "")
			Case "Foher"
				$iKey[$kFoh] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "FoH", "")
				$iKey[$kConv] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Conv", "")
			Case "Hammerdin"
				$iKey[$kHammer] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Hammer", "")
				$iKey[$kConc] = IniRead(@ScriptDir & "\Config\D2Au3.ini", "Keys", "Conc", "")
			Case Else
				LogEvent("You chose an invalid build for a paladin.", 2)
				Exit
		EndSwitch
	Case "Sorceress"
	Case "Necromancer"
	Case "Amazon"
	Case "Barbarian"
	Case "Druid"
	Case "Assassin"
EndSwitch