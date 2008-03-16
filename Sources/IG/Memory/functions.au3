#include "../../Sources/NomadMemory.au3"

;--------------------------------------------------------
;Func MemDetectAct()
; @ Purpose: Checks memory at 6FBCBF2C for current act
; @ Returns: Current Act {1,2,3,4,5}
; @ ToDo: Error Handling
;--------------------------------------------------------
Func MemDetectAct()
	Local $sHandle = _MemoryOpen(ProcessExists("Diablo II.exe")) ;Get D2 process id
	Local $sRet = _MemoryRead('0x' & Hex(Dec("6FBCBF2C") + 0), $sHandle, 'dword') ;read act # (0-4) Act 1 is 0, Act2 is 1, etc..
	_MemoryClose($sHandle) ;Close our pointer
	
	LogEvent(0, "Act " & $sRet + 1 & " Detected")
	Return $sRet + 1
EndFunc

;--------------------------------------------------------
;Func MemDetectWeaponSet()
; @ Purpose: Checks memory at 6FBCBC38 for weapon set
; @ Returns: Current Weapon Set {1,2}
; @ ToDo: Error Handling
;--------------------------------------------------------
Func MemDetectWeaponSet()
	Local $sHandle = _MemoryOpen(ProcessExists("Diablo II.exe")) ;Get D2 process id
	Local $sRet = _MemoryRead('0x' & Hex(Dec("6FBCBC38") + 0), $sHandle, 'dword') ;read act # (0-4) Act 1 is 0, Act2 is 1, etc..
	_MemoryClose($sHandle) ;Close our pointer
	
	LogEvent(0, "Weapon Set " & $sRet + 1 & " Detected")
	Return $sRet + 1
EndFunc

;--------------------------------------------------------
;Func MemGetCurrentLife()
; @ Purpose: Checks memory at 01E3322D for current life
; @ Returns: current life as decimal
; @ ToDo: Error Handling
;--------------------------------------------------------
Func MemGetCurrentLife()
	Local $sHandle = _MemoryOpen(ProcessExists("Diablo II.exe")) ;Get D2 process id
	Local $sRet = _MemoryRead('0x' & Hex(Dec("01E3322D") + 0), $sHandle, 'dword') ;read act # (0-4) Act 1 is 0, Act2 is 1, etc..
	_MemoryClose($sHandle) ;Close our pointer
	
	LogEvent(0, "Current Life of " & $sRet + 1 & " Detected")
	Return $sRet + 1
EndFunc