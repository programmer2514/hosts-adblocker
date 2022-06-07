;-----------------------------;
; Hosts File Adblocker v1.1.0 ;
;      By Benjamin Pryor      ;
;-----------------------------;

; Navigate to correct starting directory
SetWorkingDir, %A_AppData%

If not (InStr(FileExist("hosts-adblocker"), "D"))
{
    FileCreateDir, hosts-adblocker
}

SetWorkingDir, %A_AppData%\hosts-adblocker

; Read settings values
hostsFileLength   := 0
blocklistURL      := ""

; Make sure ini file exists
if not (FileExist("hosts-adblocker.ini"))
{
    ; Get length of hosts file
    fileLength := -1
    Loop, Read, C:\Windows\System32\Drivers\etc\hosts
        fileLength = %A_Index%
        
      If (ErrorLevel == 1)
      {
          MsgBox, 0x10, Fatal error!, Could not read hosts file!
          Return
      }
    
    ; Create new ini file
    FileAppend, [Settings]`nhostsFileLength=%fileLength%`nblocklistURL=https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt, hosts-adblocker.ini
    
    MsgBox, 0x34, Warning!, No previous settings detected!`nWould you like to double-check the auto-generated ones?
    IfMsgBox Yes
    {
        Run, notepad hosts-adblocker.ini
        Return
    }
}

IniRead, hostsFileLength, hosts-adblocker.ini, Settings, hostsFileLength
  If (ErrorLevel == 1)
  {
      MsgBox, 0x10, Fatal error!, Could not read hostsFileLength from settings file!
      Return
  }

IniRead, blocklistURL, hosts-adblocker.ini, Settings, blocklistURL
  If (ErrorLevel == 1)
  {
      MsgBox, 0x10, Fatal error!, Could not read blocklistURL from settings file!
      Return
  }

; Handle command line arguments
showPrompt      := True
appendBlocklist := True

For n, param in A_Args
{
    If ((param == "/S") or (param == "/s"))
    {
        showPrompt := False
    }
    
    If ((param == "/P") or (param == "/p"))
    {
        FileRecycle, hosts.bak.*
        MsgBox, 0x40, Success!, Backups purged successfully!
        Return
    }
    
    If ((param == "/U") or (param == "/u"))
    {
        appendBlocklist := False
    }
    
    If (param == "/?")
    {
        MsgBox, 0x20, Help, Hosts File Adblocker`n  By Benjamin Pryor`n    - v1.1.0`n`nAppends an external blocklist to a hosts file of a specified length.`n`nArguments:`n    /S - Silent mode, do not display reboot prompt`n    /P - Purge all backup files`n    /U - Uninstall blocklist from hosts file`n    /? - Show this help dialog
        Return
    }
}

; Make sure script is running as administrator
If not (A_IsAdmin)
{
    MsgBox, 0x10, Fatal error!, This script must be run as administrator!
    Return
}

; Clean up files
FileDelete, blocklist.tmp
FileDelete, newhosts.tmp

; Download new blocklist
If (appendBlocklist)
{
    UrlDownloadToFile, %blocklistURL%, blocklist.tmp
      If (ErrorLevel == 1)
      {
          MsgBox, 0x10, Fatal error!, Failed to download blocklist!
          Return
      }
}

; Read hosts file
Loop, Read, C:\Windows\System32\Drivers\etc\hosts, newhosts.tmp
{
    If (A_Index <= hostsFileLength)
        FileAppend, %A_LoopReadLine%`n
}
  If (ErrorLevel == 1)
  {
      MsgBox, 0x10, Fatal error!, Could not read hosts file!
      Return
  }

; Append blocklist to temp hosts file
If (appendBlocklist)
{
    Loop, Read, blocklist.tmp, newhosts.tmp
        FileAppend, `n%A_LoopReadLine%
}

; Back up hosts file to temp directory
FileMove, C:\Windows\System32\Drivers\etc\hosts, hosts.bak.%A_NowUTC%
  If (ErrorLevel == 1)
  {
      MsgBox, 0x34, Warning!, Unable to back up hosts file!`nContinue?
      IfMsgBox, No
          Return
  }

; Write changes to actual hosts file
FileMove, newhosts.tmp, C:\Windows\System32\Drivers\etc\hosts
  If (ErrorLevel == 1)
  {
      MsgBox, 0x10, Fatal error!, Could not write changes to hosts file!
      Return
  }

; Clean up files
FileDelete, blocklist.tmp
FileDelete, newhosts.tmp

; Display reboot prompt
If (showPrompt)
{
    MsgBox, 0x24, Success!, Hosts file modified successfully!`nReboot now?
    IfMsgBox, Yes
        Shutdown, 2
}

Return
