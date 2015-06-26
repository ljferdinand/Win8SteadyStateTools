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

; Look for the Drive where the VHDs actually exist
For $i = 1 To $aArray[0]
   $sFilePath = $aArray[$i]
   $iFileExists = FileExists( $sFilePath & "\Win7.vhd" )
   if $iFileExists Then
		 $aFileLocation = $sFilePath & "\Win7.vhd"
		 $aDriveLetter = $sFilePath
        ; Show all the drives found and convert the drive letter to uppercase.
        ;#MsgBox($MB_SYSTEMMODAL, "", $aFileLocation)
   EndIf
Next
;MsgBox($MB_SYSTEMMODAL, "", $aDriveLetter)

;Delete old vhd
RunWait(@ComSpec & " /c del " & $aDriveLetter & "\temp*.vhd /s","",@SW_HIDE)

;Generate new unique VHD
$timestamp = TimerInit()
$guid1 = FileRead('c:\windows\system\guid.txt', FileGetSize('c:\windows\system\guid.txt'))
$guid1 = StringReplace($guid1, "The entry was successfully copied to ", "")
$guid1 = StringReplace($guid1, ".", "")
FileCopy($aDriveLetter & "\temp.vhd.orig", $aDriveLetter & "\temp" & $timestamp & ".vhd")

; configure BCD Store
RunWait('cmd /c bcdedit -timeout 0',"",@SW_HIDE)
RunWait('cmd /c bcdedit -set ' & $guid1 & ' device vhd=' & Chr(91) & $aDriveLetter & Chr(93) & '\temp' & $timestamp & '.vhd',"",@SW_HIDE)
RunWait('cmd /c bcdedit -set ' & $guid1 & ' osdevice vhd=' & Chr(91) & $aDriveLetter & Chr(93) & '\temp' & $timestamp & '.vhd',"",@SW_HIDE)
RunWait('cmd /c bcdedit -default ' & $guid1,"",@SW_HIDE)

If @OSArch = "X64" Then
	Local $stOldVal = DllStructCreate("dword")
	DllCall("kernel32.dll", "int", "Wow64RevertWow64FsRedirection", "ptr", DllStructGetPtr($stOldVal))
EndIf