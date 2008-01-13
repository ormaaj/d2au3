#include-once
#region _NomadMemory
Dim $FF_MemEnd
Func _MemoryOpen($iv_Pid, $iv_DesiredAccess = 0x1F0FFF, $iv_InheritHandle = 1)
    
    If Not ProcessExists($iv_Pid) Then
        SetError(1)
        Return 0
    EndIf
    
    Local $ah_Handle[2] = [DllOpen('kernel32.dll') ]
    
    If @error Then
        SetError(2)
        Return 0
    EndIf
    
    Local $av_OpenProcess = DllCall($ah_Handle[0], 'int', 'OpenProcess', 'int', $iv_DesiredAccess, 'int', $iv_InheritHandle, 'int', $iv_Pid)
    
    If @error Then
        DllClose($ah_Handle[0])
        SetError(3)
        Return 0
    EndIf
    
    $ah_Handle[1] = $av_OpenProcess[0]
    
    Return $ah_Handle
    
EndFunc   ;==>_MemoryOpen

Func _MemoryClose($ah_Handle)
    
    If Not IsArray($ah_Handle) Then
        SetError(1)
        Return 0
    EndIf
    
    DllCall($ah_Handle[0], 'int', 'CloseHandle', 'int', $ah_Handle[1])
    If Not @error Then
        DllClose($ah_Handle[0])
        Return 1
    Else
        DllClose($ah_Handle[0])
        SetError(2)
        Return 0
    EndIf
    
EndFunc   ;==>_MemoryClose

; =============================================================
;; uses ushort[] because it consumes 2 bytes/char, and the "wide strings" are 2 bytes/char
Func _MemoryReadWideString($iv_Address, $ah_Handle, $sv_Type)
    $FF_MemEnd = 1
    If Not IsArray($ah_Handle) Then
        SetError(1)
        Return 0
    EndIf
    Local $v_Buffer = DllStructCreate($sv_Type)
    If @error Then
        SetError(@error + 1)
        Return 0
    EndIf
	DllCall($ah_Handle[0], 'int', 'ReadProcessMemory', 'int', $ah_Handle[1], 'int', $iv_Address, 'ptr', DllStructGetPtr($v_Buffer), 'int', DllStructGetSize($v_Buffer), 'int', '')
    If Not @error Then
        ;; concatenate a string from the array of ushort
        $tmpString = ""
        For $char = 1 To 500
            $v_Value = DllStructGetData($v_Buffer, 1, $char)
            If $v_Value = 0 Then 
;~ 				LogItem0("$FF_MemEnd = 0")
				$FF_MemEnd = 0
				ExitLoop
			EndIf
					$tmpString = $tmpString & Chr($v_Value)
        Next
        Return $tmpString
    Else
        SetError(6)
        Return 0
    EndIf
    
EndFunc   ;==>_MemoryReadWideString
; =============================================================

Func SetPrivilege($privilege, $bEnable)
    Const $TOKEN_ADJUST_PRIVILEGES = 0x0020
    Const $TOKEN_QUERY = 0x0008
    Const $SE_PRIVILEGE_ENABLED = 0x0002
    Local $hToken, $SP_auxret, $SP_ret, $hCurrProcess, $nTokens, $nTokenIndex, $priv
    $nTokens = 1
    $LUID = DllStructCreate("dword;int")
    If IsArray($privilege) Then $nTokens = UBound($privilege)
    $TOKEN_PRIVILEGES = DllStructCreate("dword;dword[" & (3 * $nTokens) & "]")
    $NEWTOKEN_PRIVILEGES = DllStructCreate("dword;dword[" & (3 * $nTokens) & "]")
    $hCurrProcess = DllCall("kernel32.dll", "hwnd", "GetCurrentProcess")
    $SP_auxret = DllCall("advapi32.dll", "int", "OpenProcessToken", "hwnd", $hCurrProcess[0], _
            "int", BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY), "int_ptr", 0)
    If $SP_auxret[0] Then
        $hToken = $SP_auxret[3]
        DllStructSetData($TOKEN_PRIVILEGES, 1, 1)
        $nTokenIndex = 1
        While $nTokenIndex <= $nTokens
            If IsArray($privilege) Then
                $priv = $privilege[$nTokenIndex - 1]
            Else
                $priv = $privilege
            EndIf
            $ret = DllCall("advapi32.dll", "int", "LookupPrivilegeValue", "str", "", "str", $priv, _
                    "ptr", DllStructGetPtr($LUID))
            If $ret[0] Then
                If $bEnable Then
                    DllStructSetData($TOKEN_PRIVILEGES, 2, $SE_PRIVILEGE_ENABLED, (3 * $nTokenIndex))
                Else
                    DllStructSetData($TOKEN_PRIVILEGES, 2, 0, (3 * $nTokenIndex))
                EndIf
                DllStructSetData($TOKEN_PRIVILEGES, 2, DllStructGetData($LUID, 1) , (3 * ($nTokenIndex - 1)) + 1)
                DllStructSetData($TOKEN_PRIVILEGES, 2, DllStructGetData($LUID, 2) , (3 * ($nTokenIndex - 1)) + 2)
                DllStructSetData($LUID, 1, 0)
                DllStructSetData($LUID, 2, 0)
            EndIf
            $nTokenIndex += 1
        WEnd
        $ret = DllCall("advapi32.dll", "int", "AdjustTokenPrivileges", "hwnd", $hToken, "int", 0, _
                "ptr", DllStructGetPtr($TOKEN_PRIVILEGES), "int", DllStructGetSize($NEWTOKEN_PRIVILEGES), _
                "ptr", DllStructGetPtr($NEWTOKEN_PRIVILEGES), "int_ptr", 0)
        $f = DllCall("kernel32.dll", "int", "GetLastError")
    EndIf
    $NEWTOKEN_PRIVILEGES = 0
    $TOKEN_PRIVILEGES = 0
    $LUID = 0
    If $SP_auxret[0] = 0 Then Return 0
    $SP_auxret = DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hToken)
    If Not $ret[0] And Not $SP_auxret[0] Then Return 0
    Return $ret[0]
EndFunc   ;==>SetPrivilege

;=================================================================================================
; Function:   _MemoryRead($iv_Address, $ah_Handle[, $sv_Type])
; Description:    Reads the value located in the memory address specified.
; Parameter(s):  $iv_Address - The memory address you want to read from. It must be in hex
;                          format (0x00000000).
;               $ah_Handle - An array containing the Dll handle and the handle of the open
;                         process as returned by _MemoryOpen().
;               $sv_Type - (optional) The "Type" of value you intend to read.  This is set to
;                        'dword'(32bit(4byte) signed integer) by default.  See the help file
;                        for DllStructCreate for all types.
;                        An example: If you want to read a word that is 15 characters in
;                        length, you would use 'char[16]'.
; Requirement(s):   The $ah_Handle returned from _MemoryOpen.
; Return Value(s):  On Success - Returns the value located at the specified address.
;               On Failure - Returns 0
;               @Error - 0 = No error.
;                      1 = Invalid $ah_Handle.
;                      2 = $sv_Type was not a string.
;                      3 = $sv_Type is an unknown data type.
;                      4 = Failed to allocate the memory needed for the DllStructure.
;                      5 = Error allocating memory for $sv_Type.
;                      6 = Failed to read from the specified process.
; Author(s):        Nomad
; Note(s):      Values returned are in Decimal format, unless specified as a 'char' type, then
;               they are returned in ASCII format.  Also note that size ('char[size]') for all
;               'char' types should be 1 greater than the actual size.
;=================================================================================================
Func _MemoryRead($iv_Address, $ah_Handle, $sv_Type = 'dword')
   
    If Not IsArray($ah_Handle) Then
        SetError(1)
        Return 0
    EndIf
   
    Local $v_Buffer = DllStructCreate($sv_Type)
   
    If @Error Then
        SetError(@Error + 1)
        Return 0
    EndIf
   
    DllCall($ah_Handle[0], 'int', 'ReadProcessMemory', 'int', $ah_Handle[1], 'int', $iv_Address, 'ptr', DllStructGetPtr($v_Buffer), 'int', DllStructGetSize($v_Buffer), 'int', '')
   
    If Not @Error Then
        Local $v_Value = DllStructGetData($v_Buffer, 1)
        Return $v_Value
    Else
        SetError(6)
        Return 0
    EndIf
   
EndFunc

Func _MemoryPointerRead ($iv_Address, $ah_Handle, $av_Offset, $sv_Type = 'dword')
   
    If IsArray($av_Offset) Then
        If IsArray($ah_Handle) Then
            Local $iv_PointerCount = UBound($av_Offset) - 1
        Else
            SetError(2)
            Return 0
        EndIf
    Else
        SetError(1)
        Return 0
    EndIf
   
    Local $iv_Data[2], $i
    Local $v_Buffer = DllStructCreate('dword')
   
    For $i = 0 to $iv_PointerCount
       
        If $i = $iv_PointerCount Then
            $v_Buffer = DllStructCreate($sv_Type)
            If @Error Then
                SetError(@Error + 2)
                Return 0
            EndIf
           
            $iv_Address = '0x' & hex($iv_Data[1] + $av_Offset[$i])
            DllCall($ah_Handle[0], 'int', 'ReadProcessMemory', 'int', $ah_Handle[1], 'int', $iv_Address, 'ptr', DllStructGetPtr($v_Buffer), 'int', DllStructGetSize($v_Buffer), 'int', '')
            If @Error Then
                SetError(7)
                Return 0
            EndIf
           
            $iv_Data[1] = DllStructGetData($v_Buffer, 1)
           
        ElseIf $i = 0 Then
            DllCall($ah_Handle[0], 'int', 'ReadProcessMemory', 'int', $ah_Handle[1], 'int', $iv_Address, 'ptr', DllStructGetPtr($v_Buffer), 'int', DllStructGetSize($v_Buffer), 'int', '')
            If @Error Then
                SetError(7)
                Return 0
            EndIf
           
            $iv_Data[1] = DllStructGetData($v_Buffer, 1)
           
        Else
            $iv_Address = '0x' & hex($iv_Data[1] + $av_Offset[$i])
            DllCall($ah_Handle[0], 'int', 'ReadProcessMemory', 'int', $ah_Handle[1], 'int', $iv_Address, 'ptr', DllStructGetPtr($v_Buffer), 'int', DllStructGetSize($v_Buffer), 'int', '')
            If @Error Then
                SetError(7)
                Return 0
            EndIf
           
            $iv_Data[1] = DllStructGetData($v_Buffer, 1)
           
        EndIf
       
    Next
   
    $iv_Data[0] = $iv_Address
   
    Return $iv_Data

EndFunc
#endregion