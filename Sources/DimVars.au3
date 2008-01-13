;================================================
;	Pre-variable declarations.
;	This file will manually declare all variables contained within config.ini before the dynamic assigning of their corresponding values.
;
;	I consider it a bug (or at least a flaw) in autoit that autoit cannot predict in advance variables declared using the Assign() method, as this is the only way to
;	declare a variable whose name is contained within a string, in this case, loaded from config.ini. This dynamic variable loading method is very convienient since
;	all we have to do to add a variable is just insert it into config.ini, and the bot will automatically declare the variable with the corresponding variable name.
;	Normally, you would have to use Eval() every time you wanted to use a variable in order to avoid au3 wrapper "Variable used without being declared" errors.
;	This is obviously not very practical since assign() is used to declare nearly every user-defined variable in the entire script. Technically, since assign() does
;	the declaration itself already, any errors encountered can be safely ignored, but a "false" error for every single variable makes debugging almost impossible.
;	Since we must use assign() to avoid the need to use a massive list of inireads to load the ini variables, we also have to manually pre-dim every variable used in
;	config.ini. This makes it so all vars are already dimmed before they are assigned, and therefore autoit will not complain.
;
;	Long story short, there is no algorhythmic or shorter way to do this properly. Every time you add or change a variable in config.ini, you must also
;	do so in DimVars.au3. I know, annoying. Don't like it? Bitch at the autoit devs until they fix it.
;
;	If anybody can think of an easier way, I'd love to hear it! Comment out this #include in Bot.au3 and you'll see what I mean.
;	~Smorg
;================================================

;================================================
; Character & Account Settings
;================================================
Dim $CharMode
Dim $CharAccount
Dim $CharPassword
Dim $CharSlot
Dim $CharDifficulty
Dim $CharStartRunDelay
Dim $CharRealm
Dim $CharRealmPos

;================================================
; Run Settings
;================================================
Dim $D2Path
Dim $D2Executable
Dim $D2WName
Dim $MultiKeys

Dim $Run_PasswordType
Dim $Run_GameName
Dim $Run_Interval

Dim $Run_IntervalDelay
Dim $Run_CreateGameDelay

;================================================
; Life Managment Settings
;================================================

; Life/Mana
Dim $LifeRpotDrinkPercent
Dim $LifeFpotDrinkPercent
Dim $ManaRpotDrinkPercent
Dim $ManaFpotDrinkPercent
Dim $ChickenLife
Dim $ChickenMana

; Merc
Dim $UseMerc
Dim $MercChicken
Dim $MercHealPercent
Dim $MercChickenPercent

; Misc
Dim $ScanDelay
Dim $DrinkDelay
Dim $ChickenWaitDelay
Dim $MaxLife
Dim $MaxMana
Dim $ChickenTimeout
Dim $ChickenRetries

;================================================
; Speed and Delays
;================================================
Dim $MenuMouseSpeed
Dim $MenuStaticDelay
Dim $LoginFailSleep
Dim $LoginTimeout

;================================================
; Advanced
;================================================
Dim $Parameters
Dim $Bot_STOP_HotKey
Dim $Bot_PAUSE_HotKey
Dim $MMstatusURL
Dim $MMnewsURL
Dim $IGScriptName

;================================================
; Keyboard Configuration
;================================================
Dim $Key_ClearScreen
Dim $Key_Switch
Dim $Key_AutoMap
Dim $Key_Inventory
Dim $Key_ShowItems
Dim $Key_ShowBelt
Dim $Key_PotionsRow1
Dim $Key_PotionsRow2
Dim $Key_PotionsRow3
Dim $Key_PotionsRow4
Dim $Key_PauseBot

;================================================
; Colors Definition... don't edit these unless you know what you're doing.
;================================================
Dim $XUNIQUES_Color
Dim $SETS_Color
Dim $XRARES_Color
Dim $MAGICS_Color
Dim $GRAYS_Color
Dim $WHITES_Color
Dim $NPC_BODY_Color
Dim $NPC_MENU_Color
Dim $GREEN_BLOCKS_Color
Dim $MERC_GREEN_BAR_Color
Dim $MERC_ORANGE_BAR_Color
Dim $UNID_RED_Color
Dim $CRAFTED_Color
Dim $TP_color

;================================================
; Other Misc things not in Config.ini
;================================================
Dim $GameName
Dim $RunCount
Dim $MMStatus
Dim $LoopExit
Dim $CancelLaunch

;================================================
; Misc Vars
;================================================
Dim $IGPathName

Global $Char_Key_PotionsRow[5]  ;Potion drink keys 
$Char_Key_PotionsRow[1] = $Key_PotionsRow1
$Char_Key_PotionsRow[2] = $Key_PotionsRow2
$Char_Key_PotionsRow[3] = $Key_PotionsRow3
$Char_Key_PotionsRow[4] = $Key_PotionsRow4