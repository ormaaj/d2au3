#include-once
Func TeleMonster ()
	Local $sPixel = PixelSearch(0, 0, 800, 600, 16537640, 2, 10)
	If @error Then
		Return 0
	EndIf
	Local $sRight = $sPixel[0]
	Do
		$sRight += 1
	Until PixelGetColor($sRight, $sPixel[1]) <> 16537640
	If ($sRight - $sPixel[0]) < 5 Then Return 0
	Local $sBottom = $sPixel[1]
	Do
		$sBottom += 1
	Until PixelGetColor($sPixel[0], $sBottom) <> 16537640
	$sPixel[0] = Number($sRight - 18)
	$sPixel[1] = Number($sBottom - 34)
	SendKey("Teleport")
	FastClick("Right", $sPixel[0], $sPixel[1])
	TeleCheck(500, 50)	
	Return 1
EndFunc

Func AttackMonster($sDura=1000)
	Switch $iConfig[$nBuild]
		Case "Zealer"
			SendKey("Zeal")
			SendKey("Fant")
			MouseDown("left")
			SendKey("Standstill", "Down")
			Sleep($sDura)
			SendKey("Standstill", "Up")
			MouseUp("left")
		Case "Hammerdin"
			SendKey("Hammer")
			SendKey("Conc")
			SendKey("Standstill", "Down")
			MouseDown("left")
			Sleep($sDura)
			SendKey("Standstill", "Up")
			MouseUp("left")
	EndSwitch
EndFunc

Func Attack ($sTimeOut = 10000)
	LogEvent(0, "Starting attack sequence")
	For $i = 1 To 3 Step 1
		While TeleMonster () = 1
			AttackMonster ()
			Sleep(10)
		WEnd
	Next
	Pickit ()
EndFunc