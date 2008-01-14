;========================================================================
;This file gives reference checksums to menus and screens
;All values are: 32 bit, Decimal, RGB, pixelcoordmode 2, and resolution 1
;Section: Out-of-Game
;========================================================================
Global $TitleScreen[6]                           ;Declare the value
$TitleScreen[0] = 3319931069                     ;The resulting checksum
$TitleScreen[1] = 80                             ;Upper left X
$TitleScreen[2] = 400                            ;Upper left Y
$TitleScreen[3] = 85                             ;Lower right X
$TitleScreen[4] = 405                            ;Lower right Y
$TitleScreen[5] = 1								 ;Resolution / Step

Global $LoginScreen[6]                           ;Bnet login screen checksum
$LoginScreen[0] = 1831881397
$LoginScreen[1] = 360
$LoginScreen[2] = 250
$LoginScreen[3] = 370
$LoginScreen[4] = 255
$LoginScreen[5] = 1

Global $CharacterSelect[6]                       ;Detect the character selection screen for both single and battlenet
$CharacterSelect[0] = 2362581377
$CharacterSelect[1] = 107
$CharacterSelect[2] = 177
$CharacterSelect[3] = 117
$CharacterSelect[4] = 178
$CharacterSelect[5] = 1

Global $Lobby[6]                                 ;Detect the battlenet lobby screen       
$Lobby[0] = 1292465505
$Lobby[1] = 400
$Lobby[2] = 450
$Lobby[3] = 410
$Lobby[4] = 460
$Lobby[5] = 1

Global $CreateButton[6]                          ;the selected (greyed out) "Create" lobby button
$CreateButton[0] = 2470124185
$CreateButton[1] = 545
$CreateButton[2] = 455
$CreateButton[3] = 550
$CreateButton[4] = 460
$CreateButton[5] = 1

Global $GameJoin[6]                              ;Checksum for the black area of the game loading screen
$GameJoin[0] = 7077889
$GameJoin[1] = 700
$GameJoin[2] = 100
$GameJoin[3] = 705
$GameJoin[4] = 105
$GameJoin[5] = 1

Global $GUIBar[6]                                ;Can be used to determine if in-game... but the IsInGame() function is preferable...
$GUIBar[0] = 1671697521
$GUIBar[1] = 5
$GUIBar[2] = 575
$GUIBar[3] = 10
$GUIBar[4] = 580
$GUIBar[5] = 1

Global $SinglePlayerDifficulty[6]                ;The single player difficulty selection box
$SinglePlayerDifficulty[0] = 2999391001
$SinglePlayerDifficulty[1] = 500
$SinglePlayerDifficulty[2] = 250
$SinglePlayerDifficulty[3] = 510
$SinglePlayerDifficulty[4] = 260
$SinglePlayerDifficulty[5] = 1

;========================================================================
;This file gives reference checksums to menus and screens
;All values are: 32 bit, Decimal, RGB, pixelcoordmode 2, and resolution 1
;Section: In-Game
;========================================================================

; Act1 detect via quest screen
Global $Act1[6]									; Rogue Encampment
$Act1[0] = 2734667656
$Act1[1] = 74
$Act1[2] = 54
$Act1[3] = 394
$Act1[4] = 93
$Act1[5] = 2

; Act2 detect via quest screen
Global $Act2[6]									; Lut Gholein
$Act2[0] = 983218200
$Act2[1] = 74
$Act2[2] = 54
$Act2[3] = 394
$Act2[4] = 93
$Act2[5] = 2

; Act3 detect via quest screen
Global $Act3[6]									; Kurast Docks
$Act3[0] = 3445013084
$Act3[1] = 74
$Act3[2] = 54
$Act3[3] = 394
$Act3[4] = 93
$Act3[5] = 2

; Act4 detect via quest screen
Global $Act4[6]									; Pandemonium Fortress
$Act4[0] = 634372400
$Act4[1] = 74
$Act4[2] = 54
$Act4[3] = 394
$Act4[4] = 93
$Act4[5] = 2

; Act5 detect via quest screen
Global $Act5[6]									; Harrogath
$Act5[0] = 1327609896
$Act5[1] = 74
$Act5[2] = 54
$Act5[3] = 394
$Act5[4] = 93
$Act5[5] = 1

Global $cQuest[5]
$cQuest[0] = 288
$cQuest[1] = 443
$cQuest[2] = 345
$cQuest[3] = 491
$cQuest[4] = 2140072352

Global $cChar[5]
$cChar[0] = 245
$cChar[1] = 386
$cChar[2] = 316
$cChar[3] = 505
$cChar[4] = 4177458497

Global $cMerc[5]
$cMerc[0] = 253
$cMerc[1] = 325
$cMerc[2] = 325
$cMerc[3] = 425
$cMerc[4] = 983877117

Global $cInv[5]
$cInv[0] = 410
$cInv[1] = 437
$cInv[2] = 498
$cInv[3] = 463
$cInv[4] = 3937787576

Global $cNPC[5]
$cNPC[0] = 187
$cNPC[1] = 442
$cNPC[2] = 234
$cNPC[3] = 483
$cNPC[4] = 604870260

Global $cStash[5]
$cStash[0] = 137
$cStash[1] = 74
$cStash[2] = 180
$cStash[3] = 129
$cStash[4] = 2370454791
;========================================================================