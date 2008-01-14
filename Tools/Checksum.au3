;--------------------------------------------------------------------
;-----------------------Smorg's Checksum Reader----------------------
;--------------------------------------------------------------------
#include <GUIConstants.au3>
Opt("GUIOnEventMode",1)
$coordlabely = 135
$coordinputy = $coordlabely + 15
$buttony = 175

GUICreate("Checksum", 145, 200, 1000, 0)
GUICtrlCreateInput("", 0, 15)  ;checksum readout
GUICtrlCreateInput("1", 70, 35) ;resolution
GUICtrlCreateInput("1", 70, 55) ;colormode
GUICtrlCreateInput("1", 70, 75) ;pixelcoordmode
GUICtrlCreateInput("D2Loader v1.11b - Built On Dec 29 2006", 70, 95) ;window title

;coordinate inputs
GUICtrlCreateInput("170", 0, $coordinputy, 35) ;x1
GUICtrlCreateInput("212", 35, $coordinputy, 35) ;y1
GUICtrlCreateInput("610", 70, $coordinputy, 35) ;x2
GUICtrlCreateInput("322", 105, $coordinputy, 35) ;y2

GUICtrlCreateLabel("Checksum:", 0, 0, 200, 15)
GUICtrlCreateLabel("Resolution:", 0, 35, 60, 15)
GUICtrlCreateLabel("Color Mode:", 0, 55, 60, 15)
GUICtrlCreateLabel("Pixel Mode:", 0, 75, 60, 15)
GUICtrlCreateLabel("Window:", 0, 95, 60, 15)

GUICtrlCreateLabel("x1", 5, $coordlabely, 60, 15)
GUICtrlCreateLabel("y1", 40, $coordlabely, 60, 15)
GUICtrlCreateLabel("x2", 75, $coordlabely, 60, 15)
GUICtrlCreateLabel("y2", 110, $coordlabely, 60, 15)

$okbutton = GUICtrlCreateButton("Show", 5, $buttony, 60)
$exitbutton = GUICtrlCreateButton("Exit", 65, $buttony, 60)
GUICtrlSetOnEvent($okbutton, "OK")
GUICtrlSetOnEvent($exitbutton, "Terminate")
GUISetState(@SW_SHOW)

GUICtrlCreateCheckbox ("zero window", 0, 115)
;--------------------------------------------------------------------

While 1
Sleep(1000)
Wend

Func OK()
WinActivate(GUICtrlRead(7))
If GUICtrlRead(23) = $GUI_CHECKED Then WinMove(GUICtrlRead(7),"",0,0)
Opt("PixelCoordMode", GUICtrlRead(6))
Opt("ColorMode", GUICtrlRead(5))
$x1 = GUICtrlRead(8)
$y1 = GUICtrlRead(9)
$x2 = GUICtrlRead(10)
$y2 = GUICtrlRead(11)
GUICtrlSetData(3, PixelCheckSum($x1, $y1, $x2, $y2, GUICtrlRead(4)))
ClipPut("PixelChecksum(" & $x1 & ", " & $y1 & ", " & $x2 & ", " & $y2 & ", " & GUICtrlRead(4) & ") " & " = " & PixelCheckSum($x1, $y1, $x2, $y2, GUICtrlRead(4)))
EndFunc

Func Terminate()
Exit
EndFunc
;--------------------------------------------------------------------