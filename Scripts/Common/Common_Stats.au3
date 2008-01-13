;Common_Stats.au3

Func Life ()
	Local $sPix = PixelSearch(0, 509, 1, 587, 16526336, 0, 1)
	If @error Then
		LogEvent(1, "Unable to ch
EndFunc