;========================================================================
;This file gives reference checksums to menus and screens
;All values are: 32 bit, Decimal, RGB, pixelcoordmode 2, and resolution 1
;========================================================================
Global $TitleScreen[5]                           ;Declare the value
$TitleScreen[0] = 3319931069                     ;The resulting checksum
$TitleScreen[1] = 80                             ;Upper left X
$TitleScreen[2] = 400                            ;Upper left Y
$TitleScreen[3] = 85                             ;Lower right X
$TitleScreen[4] = 405                            ;Lower right Y

Global $LoginScreen[5]                           ;Bnet login screen checksum
$LoginScreen[0] = 1831881397
$LoginScreen[1] = 360
$LoginScreen[2] = 250
$LoginScreen[3] = 370
$LoginScreen[4] = 255

Global $CharacterSelect[5]                       ;Detect the character selection screen for both single and battlenet
$CharacterSelect[0] = 2362581377
$CharacterSelect[1] = 107
$CharacterSelect[2] = 177
$CharacterSelect[3] = 117
$CharacterSelect[4] = 178

Global $Lobby[5]                                 ;Detect the battlenet lobby screen       
$Lobby[0] = 1292465505
$Lobby[1] = 400
$Lobby[2] = 450
$Lobby[3] = 410
$Lobby[4] = 460

Global $CreateButton[5]                          ;the selected (greyed out) "Create" lobby button
$CreateButton[0] = 2470124185
$CreateButton[1] = 545
$CreateButton[2] = 455
$CreateButton[3] = 550
$CreateButton[4] = 460

Global $GameJoin[5]                              ;Checksum for the black area of the game loading screen
$GameJoin[0] = 7077889
$GameJoin[1] = 700
$GameJoin[2] = 100
$GameJoin[3] = 705
$GameJoin[4] = 105

Global $GUIBar[5]                                ;Can be used to determine if in-game... but the IsInGame() function is preferable...
$GUIBar[0] = 1671697521
$GUIBar[1] = 5
$GUIBar[2] = 575
$GUIBar[3] = 10
$GUIBar[4] = 580

Global $SinglePlayerDifficulty[5]                ;The single player difficulty selection box
$SinglePlayerDifficulty[0] = 2999391001
$SinglePlayerDifficulty[1] = 500
$SinglePlayerDifficulty[2] = 250
$SinglePlayerDifficulty[3] = 510
$SinglePlayerDifficulty[4] = 260

;========================================================================