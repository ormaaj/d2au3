Opt("MouseCoordMode", 2)
Opt("PixelCoordMode", 2)
Opt("WinTitleMatchMode", 4)
Opt("GUIOnEventMode", 1) 
Opt("TrayIconDebug", 1)

;------------------------------
;External Includes
;------------------------------
#include "Sources/Common/NomadMemory.au3"
#include <Date.au3>
#include <File.au3>
#include <Array.au3>
#include <String.au3>
#include <GUIConstants.au3>

;------------------------------
;Common Includes
;------------------------------
#include "Sources/Common/Checksums.au3"
#include "Sources/Common/Functions.au3"
#include "Sources/Common/INIRead.au3"

;------------------------------
;Pathing Includes
;------------------------------
#include "Sources/IG/Path/Path_Common.au3"
;#include "Sources/IG/Path/Path_Hack.au3"

;------------------------------
;Attack Includes
;------------------------------
#include "Sources/IG/Attack/Attack_Common.au3"

;------------------------------
;Item Includes
;------------------------------
#include "Sources/IG/Item/Item_Checksums.au3"
#include "Sources/IG/Item/Item_ItemArr.au3"
#include "Sources/IG/Item/Item_Pickit.au3"
#include "Sources/IG/Item/Item_Common.au3"
#include "Sources/IG/Item/Item_Stash.au3"
#include "Sources/IG/Item/Item_NPC.au3"

ReadPickit ()
WinActivate("ClassName=Diablo II")

Global $sDatabase = Database("Inv", 1)


;Temperary func i Made to look @ my 4d array
Func ReadArr ($Array)
If IsArray($Array) = 0 Then Return
$sLo = Opt("GUIOnEventMode", 0) 
$Form1 = GUICreate("Array Read", 693, 474, 193, 115)
$TreeView1 = GUICtrlCreateTreeView(8, 0, 681, 465)
$Base = GUICtrlCreateTreeViewItem("Array", $TreeView1)
Local $sUB = UBound($Array, 0)
GUICtrlCreateTreeViewItem($sUB & " dimensions.", $Base)
For $i = 0 To UBound($Array, 1) - 1 Step 1
	If $sUB = 1 Then;1-D Arr
		GUICtrlCreateTreeViewItem("[" & $i & "] = " & $Array[$i], $Base)
	ElseIf $sUB = 2 Then;2-D Arr
		Local $s2DBase = GUICtrlCreateTreeViewItem("[" & $i & "][x]", $Base)
		For $b = 0 To UBound($Array, 1) - 1 Step 1
			GUICtrlCreateTreeViewItem("[" & $i & "][" & $b & "] = " & $Array[$i][$b], $s2DBase)
		Next
	ElseIf $sUB = 3 Then;3-D Arr
		Local $s3DBase = GUICtrlCreateTreeViewItem("[" & $i & "][x][x]", $Base)
		For $b = 0 TO UBound($Array, 1) - 1 Step 1
			Local $s3DBase1 = GUICtrlCreateTreeViewItem("[" & $i & "][" & $b & "][x]", $s3DBase)
			For $n = 0 To UBound($Array, 2) - 1 Step 1
				GUICtrlCreateTreeViewItem("[" & $i & "][" & $b & "][" & $n & "] = " & $Array[$i][$b][$n], $s3DBase1)
			Next
		Next
	ElseIf $sUB = 4 Then;4-D Arr
		Local $s4DBase = GUICtrlCreateTreeViewItem("[" & $i & "][x][x][x]", $Base)
		For $b = 0 TO UBound($Array, 2) - 1 Step 1
			Local $s4DBase1 = GUICtrlCreateTreeViewItem("[" & $i & "][" & $b & "][x][x]", $s4DBase)
			For $n = 0 To UBound($Array, 3) - 1 Step 1
				Local $s4DBase2 = GUICtrlCreateTreeViewItem("[" & $i & "][" & $b & "][" & $n & "][x]", $s4DBase1)
				For $m = 0 To UBound($Array, 4) - 1 Step 1
					GUICtrlCreateTreeViewItem("[" & $i & "][" & $b & "][" & $n & "][" & $m & "] = " & $Array[$i][$b][$n][$m], $s4DBase2)
				Next					
			Next
		Next		
	EndIf
Next
GUISetState(@SW_SHOW)

While 1
	Sleep(10)
	$msg = GUIGetMsg ()
	Switch $msg
		Case $GUI_EVENT_CLOSE
			GUIDelete ($Form1)
			Opt("GUIOnEventMode", $sLo) 
			Return 1
	EndSwitch
WEnd
EndFunc

	