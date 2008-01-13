Opt("MouseCoordMode", 2)
Opt("PixelCoordMode", 2)
Opt("WinTitleMatchMode", 4)
Opt("GUIOnEventMode", 1) 

HotKeySet("{F2}", "Go")
#include <Misc.au3>

While 1
	Sleep(10)
WEnd

Func Go ()
		While _IsPressed(01) = 0
			Sleep(5)
			Local $FirstX = MouseGetPos ()
		WEnd
		Sleep(10)
		While _IsPressed(01) = 1
			Sleep(10)
		WEnd
		Local $SecondX = MouseGetPos ()
		BlockInput(1)
		WinActivate("ClassName=Diablo II")
		MouseMove(700, 20, 5)
		WinActivate("ClassName=Diablo II")
		MouseMove(800, 0, 1)
		WinActivate("ClassName=Diablo II")
		MouseMove(780, 0, 5)
		Sleep(100)
		Local $sChecksum = PixelChecksum($FirstX[0], $FirstX[1], $SecondX[0], $SecondX[1], 2)
		Sleep(500)
		BlockInput(0)
		Local $Name = InputBox("Name", "Please input a name for your new checksum")
		If @error Then Exit
		Local $sMess = "$" & $Name & "[0] = " & $FirstX[0] & @CRLF & _
		"$" & $Name & "[1] = " & $FirstX[1] & @CRLF & _
		"$" & $Name & "[2] = " & $SecondX[0] & @CRLF & _
		"$" & $Name & "[3] = " & $SecondX[1] & @CRLF & _
		"$" & $Name & "[4] = " & $sChecksum & @CRLF
		ClipPut($sMess)
EndFunc
		
		