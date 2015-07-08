#include <MsgBoxConstants.au3>
Local $aArray = DriveGetDrive("ALL")
Global $aDrive
Global $iFileExists
Global $sFilePath
Global $aDriveLetter

#RequireAdmin
If @OSArch = "X64" Then
	Local $stOldVal = DllStructCreate("dword")
    DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "ptr", DllStructGetPtr($stOldVal))
 EndIf

;Delete SteadyState Task
RunWait('schtasks /Delete /TN "SteadyState Startup Script" /f',"",@SW_HIDE)

RunWait('cmd /c bcdedit -import "C:\windows\system\BCDBACKUP" /clean',"",@SW_HIDE)

If @OSArch = "X64" Then
	Local $stOldVal = DllStructCreate("dword")
	DllCall("kernel32.dll", "int", "Wow64RevertWow64FsRedirection", "ptr", DllStructGetPtr($stOldVal))
EndIf