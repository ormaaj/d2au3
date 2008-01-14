#include-once
#region _NomadMemory
; NOTE: this library has been modified by Fuhrmanator to include some other useful
;         D2 functions (_MemoryReadWideString(), SetPrivilege(), etc.)
;
; NOTE: this library has been modified by Thespore to be compatible with now defunct
;       int_ptr.  replaced with int*
;==================================================================================
; AutoIt Version:     3.1.127 (beta or later)
; Language:               English
; Platform:               All Windows
; Author:               Nomad
; Requirements:          These functions will only work with beta.
;==================================================================================
; Credits:     wOuter - These functions are based on his original _Mem() functions.
;               But they are easier to comprehend and more reliable.  These
;               functions are in no way a direct copy of his functions.  His
;               functions only provided a foundation from which these evolved.
;==================================================================================
;
; Functions:
;
;==================================================================================
; Function:               _MemoryOpen($iv_Pid[, $iv_DesiredAccess[, $iv_InheritHandle]])
; Description:          Opens a process and enables all possible access rights to the
;                         process.  The Process ID of the process is used to specify which
;                         process to open.  You must call this function before calling
;                         _MemoryClose(), _MemoryRead(), or _MemoryWrite().
; Parameter(s):          $iv_Pid - The Process ID of the program you want to open.
;                         $iv_DesiredAccess - (optional) Set to 0x1F0FFF by default, which
;                                                  enables all possible access rights to the
;                                                  process specified by the Process ID.
;                         $iv_InheritHandle - (optional) If this value is TRUE, all processes
;                                                  created by this process will inherit the access
;                                                  handle.  Set to 1 (TRUE) by default.  Set to 0
;                                                  if you want it FALSE.
; Requirement(s):     None.
; Return Value(s):      On Success - Returns an array containing the Dll handle and an
;                                         open handle to the specified process.
;                         On Failure - Returns 0
;                         @Error - 0 = No error.
;                                    1 = Invalid $iv_Pid.
;                                    2 = Failed to open Kernel32.dll.
;                                    3 = Failed to open the specified process.
; Author(s):          Nomad
; Note(s):
;==================================================================================
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

;==================================================================================
; Function:               _MemoryRead($iv_Address, $ah_Handle[, $sv_Type])
; Description:          Reads the value located in the memory address specified.
; Parameter(s):          $iv_Address - The memory address you want to read from. It must
;                                          be in hex format (0x00000000).
;                         $ah_Handle - An array containing the Dll handle and the handle
;                                         of the open process as returned by _MemoryOpen().
;                         $sv_Type - (optional) The "Type" of value you intend to read.
;                                        This is set to 'dword'(32bit(4byte) signed integer)
;                                        by default.  See the help file for DllStructCreate
;                                        for all types.  An example: If you want to read a
;                                        word that is 15 characters in length, you would use
;                                        'char[16]' since a 'char' is 8 bits (1 byte) in size.
; Return Value(s):     On Success - Returns the value located at the specified address.
;                         On Failure - Returns 0
;                         @Error - 0 = No error.
;                                    1 = Invalid $ah_Handle.
;                                    2 = $sv_Type was not a string.
;                                    3 = $sv_Type is an unknown data type.
;                                    4 = Failed to allocate the memory needed for the DllStructure.
;                                    5 = Error allocating memory for $sv_Type.
;                                    6 = Failed to read from the specified process.
; Author(s):          Nomad
; Note(s):               Values returned are in Decimal format, unless specified as a
;                         'char' type, then they are returned in ASCII format.  Also note
;                         that size ('char[size]') for all 'char' types should be 1
;                         greater than the actual size.
;==================================================================================
Func _MemoryRead($iv_Address, $ah_Handle, $sv_Type = 'dword')
    
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
        Local $v_Value = DllStructGetData($v_Buffer, 1)
        Return $v_Value
    Else
        SetError(6)
        Return 0
    EndIf
    
EndFunc   ;==>_MemoryRead

;==================================================================================
; Function:               _MemoryWrite($iv_Address, $ah_Handle, $v_Data[, $sv_Type])
; Description:          Writes data to the specified memory address.
; Parameter(s):          $iv_Address - The memory address which you want to write to.
;                                          It must be in hex format (0x00000000).
;                         $ah_Handle - An array containing the Dll handle and the handle
;                                         of the open process as returned by _MemoryOpen().
;                         $v_Data - The data to be written.
;                         $sv_Type - (optional) The "Type" of value you intend to write.
;                                        This is set to 'dword'(32bit(4byte) signed integer)
;                                        by default.  See the help file for DllStructCreate
;                                        for all types.  An example: If you want to write a
;                                        word that is 15 characters in length, you would use
;                                        'char[16]' since a 'char' is 8 bits (1 byte) in size.
; Return Value(s):     On Success - Returns 1
;                         On Failure - Returns 0
;                         @Error - 0 = No error.
;                                    1 = Invalid $ah_Handle.
;                                    2 = $sv_Type was not a string.
;                                    3 = $sv_Type is an unknown data type.
;                                    4 = Failed to allocate the memory needed for the DllStructure.
;                                    5 = Error allocating memory for $sv_Type.
;                                    6 = $v_Data is not in the proper format to be used with the
;                                         "Type" selected for $sv_Type, or it is out of range.
;                                    7 = Failed to write to the specified process.
; Author(s):          Nomad
; Note(s):               Values sent must be in Decimal format, unless specified as a
;                         'char' type, then they must be in ASCII format.  Also note
;                         that size ('char[size]') for all 'char' types should be 1
;                         greater than the actual size.
;==================================================================================
Func _MemoryWrite($iv_Address, $ah_Handle, $v_Data, $sv_Type = 'dword')
    
    If Not IsArray($ah_Handle) Then
        SetError(1)
        Return 0
    EndIf
    
    Local $v_Buffer = DllStructCreate($sv_Type)
    
    If @error Then
        SetError(@error + 1)
        Return 0
    Else
        DllStructSetData($v_Buffer, 1, $v_Data)
        If @error Then
            SetError(6)
            Return 0
        EndIf
    EndIf
    
    DllCall($ah_Handle[0], 'int', 'WriteProcessMemory', 'int', $ah_Handle[1], 'int', $iv_Address, 'ptr', DllStructGetPtr($v_Buffer), 'int', DllStructGetSize($v_Buffer), 'int', '')
    
    If Not @error Then
        Return 1
    Else
        SetError(7)
        Return 0
    EndIf
    
EndFunc   ;==>_MemoryWrite

;==================================================================================
; Function:               _MemoryClose($ah_Handle)
; Description:          Closes the process handle opened by using _MemoryOpen().
; Parameter(s):          $ah_Handle - An array containing the Dll handle and the handle
;                                         of the open process as returned by _MemoryOpen().
; Return Value(s):     On Success - Returns 1
;                         On Failure - Returns 0
;                         @Error - 0 = No error.
;                                    1 = Invalid $ah_Handle.
;                                    2 = Unable to close the process handle.
; Author(s):          Nomad
; Note(s):
;==================================================================================
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

;##################################
;Function
;##################################
Func Read_Diablo_Memory($processID, $address, $format)
    
    ;##################################
    ;Define Local Variables
    ;##################################
    Local $Value
    
    ;##################################
    ;Open the Diablo II process using
    ;the Process ID retrieved from
    ;ProcessExists above.
    ;##################################
    Local $DllInformation = _MemoryOpen($processID)
    If @error Then
        MsgBox(4096, "ERROR", "Failed to open memory.")
        Exit
    EndIf
    
    ;##################################
    ;Read the process and add the
    ;necessary offsets in the chain
    ;of pointers to get to the value
    ;##################################
    $Value = _MemoryRead($address, $DllInformation, $format)
    If @error Then
        MsgBox(4096, "ERROR", "Failed to read memory.")
        Exit
    EndIf
    
    ;##################################
    ;Close the process
    ;##################################
    _MemoryClose($DllInformation)
    If @error Then
        MsgBox(4096, "ERROR", "Failed to close memory.")
        Exit
    EndIf
    
    ;##################################
    ;Return the Strength value
    ;##################################
    Return $Value
    
EndFunc   ;==>Read_Diablo_Memory

; =============================================================
;; uses ushort[] because it consumes 2 bytes/char, and the "wide strings" are 2 bytes/char
Func _MemoryReadWideString($iv_Address, $ah_Handle, $sv_Type = 'ushort[255]')
    
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
        For $char = 1 To 255
            $v_Value = DllStructGetData($v_Buffer, 1, $char)
            ; MsgBox(4096, '$v_Value', $v_Value & " = " & chr($v_Value))
            If $v_Value = 0 Then ExitLoop
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
            "int", BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY), "int*", 0)
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
                "ptr", DllStructGetPtr($NEWTOKEN_PRIVILEGES), "int*", 0)
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

#endregion