Opt("MouseCoordMode", 2)
Opt("PixelCoordMode", 2)
Opt("WinTitleMatchMode", 4)
Opt("GUIOnEventMode", 1) 
#include <Misc.au3>

While 1
	Sleep(10)
	Local $s = MouseGetPos ()
	ToolTip("X: " & $s[0] & " Y: " & $s[1] & " Color: " & PixelGetColor($s[0], $s[1]-3),0, 0)
	If _IsPressed(21) = 1 Then
		Pixel ()
	ElseIf _IsPressed(22) = 1 Then
		Pos ()
	EndIf
WEnd

Func Pixel ()
	Local $s = MouseGetPos ()
	ClipPut(PixelGetColor($s[0], $s[1]-3))	
	ToolTip("Got color",0,0)
	Sleep(500)
EndFunc

Func Pos ()
	Local $s = MouseGetPos ()
	ClipPut($s[0] & ", " & $s[1])
	ToolTip("Got coords",0,0)
	Sleep(500)
EndFunc