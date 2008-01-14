#include-once
;======================================================
;My nice little Per Act Quality colors
;======================================================
#cs
Pretty much the colors vary slightly depending on the act your in
 Act 1 has the pretty much base colors so I use it as a base and replace
 colors as needed, so If you Unique A2 is different, A2 will have all A1 colors EXCEPT unique.
#ce
Global $cItemColors[6][7]
$cItemColors[1][0] = 12895428;White Act1
$cItemColors[1][1] = 5263440;Grey Act1
$cItemColors[1][2] = 5263532;Magic Act1
$cItemColors[1][3] = 14202980;Rare Act1
$cItemColors[1][4] = 1637376;Set Act1
$cItemColors[1][5] = 9732196;Unique Act1
$cItemColors[1][6] = 13665312;Crafted Act1

$cItemColors[2][5] = 10258524;Unique A2

$cItemColors[4][6] = 12092436;Crafted A4

$cItemColors[5][4] = 836636;Set A5

For $x = 0 To UBound($cItemColors) - 1 Step 1
	For $v = 0 To UBound($cItemColors, 2) - 1 Step 1
		If $cItemColors[$x][$v] = "" Then $cItemColors[$x][$v] = $cItemColors[1][$v]
	Next
Next
Global $cColor[7] = [ "White", "Grey", "Magic", "Rare", "Set", "Unique", "Crafted" ]
Global $sYC[7] = [ "0", "5", "3", "9", "2", "4", "8" ]
Global $cNPC = 10756348
;Am, White, Grey, Magic, Rare, Set, Unique

;Item checksums (For use with FindItem ())
Global $I_HealthPot = 4164753909
Global $I_ManaPot = 1484265941
Global $I_TPScroll = 109455537
Global $I_IDScroll = 4270008305
Global $I_TPTome = 1619205517
Global $I_IDTome = 3394572921

; "Name", Inv X, Inv Y, BaseX, BaseY, SquareX, SquareY
Global $cInvSize[4][7] = [ _
[ "Inv", 3, 9, 418, 316, 29, 29 ], _
[ "NPC", 9, 9, 95, 124, 29, 29 ], _
[ "Stash", 7, 5, 153, 143, 29, 29 ], _
[ "Belt", 3, 3, 422, 467, 31, 32 ]]

;Empty area checksums (To check to see if there is an item in the spot)
;There is no NPC reference because it is assumed there is always something there!
Global $sEmptyRefInv[4][10][10] = [ _
[[114163829,174457037,204341425,134873217,264896809,372113777,250216709,106823793,117571705,465699233], _
[426377669,367657345,581304905,400425337,160039117,237371665,104202349,131727517,104202349,104202349], _
[139591837,356122989,279052621,104202349,104202349,109445237,207225033,230818057,160825505,104202349], _
[207225017,311820621,112066681,104202349,157679805,258867509,553779725,427688397,184156357,159252641]], _
[["0"]], _
[[187826365,104202349,202244345,298975529,296354081,175767721], _
[553255489,446562741,206176449,284295477,104464497,136446117], _
[248119581,195952825,104202349,207487149,174457021,206962909], _
[104202349,104202349,147718313,322830657,519701033,456786397], _
[187826365,104202349,202244345,298975529,296354081,175767721], _
[553255489,446562741,206176449,284295477,104464497,136446117], _
[248119581,195952825,104202349,207487149,174457021,206962909], _
[104202349,104202349,147718313,322830657,519701033,456786397]], _
[[367395137,560333421,513147365,111280245], _
[367395137,560333421,513147365,111280245], _
[367395137,560333421,513147365,111280245], _
[429261169,455737829,495583685,110493817]]]











