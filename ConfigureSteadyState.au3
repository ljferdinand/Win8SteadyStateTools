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

;Create a task using the supplied xml
RunWait('schtasks /Create /XML C:\windows\system\steadystate.xml /TN "SteadyState Startup Script"',"",@SW_HIDE)

;Export BCD Store for in-use VHD to guid.txt then format file for future use
RunWait('cmd /c bcdedit -copy {current} /d "SteadyState" > c:\windows\system\guid.txt',"",@SW_HIDE)
$guid1 = FileRead('c:\windows\system\guid.txt', FileGetSize('c:\windows\system\guid.txt'))
$guid1 = StringReplace($guid1, "The entry was successfully copied to ", "")
$guid1 = StringReplace($guid1, ".", "")

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

;Copy the Diff'd vhd to temp.vhd.orig so it can be used later, then delete temp.vhd
FileCopy($aDriveLetter & "\temp.vhd", $aDriveLetter & "\temp.vhd.orig")
FileDelete($aDriveLetter & "\temp.vhd")

;Assign unique name to new temp vhd so it is deleted on reboot, while retaining "template" temp.vhd.orig
$timestamp = TimerInit()
FileCopy($aDriveLetter & "temp.vhd.orig", $aDriveLetter & "\temp" & $timestamp & ".vhd")

;Configure BCD Store- change timeout as necessary but with Windows 8  you may need to go to "Advanced Startup Options" to access other VHDs
RunWait('cmd /c bcdedit -default ' & $guid1,"",@SW_HIDE)
RunWait('cmd /c bcdedit -timeout 0',"",@SW_HIDE)
RunWait('cmd /c bcdedit -set {default} device vhd=' & Chr(91) & $aDriveLetter & Chr(93) & '\temp' & $timestamp & '.vhd',"",@SW_HIDE)
RunWait('cmd /c bcdedit -set {default} osdevice vhd=' & Chr(91) & $aDriveLetter & Chr(93) & '\temp' & $timestamp & '.vhd',"",@SW_HIDE)


If @OSArch = "X64" Then
	Local $stOldVal = DllStructCreate("dword")
	DllCall("kernel32.dll", "int", "Wow64RevertWow64FsRedirection", "ptr", DllStructGetPtr($stOldVal))
EndIf