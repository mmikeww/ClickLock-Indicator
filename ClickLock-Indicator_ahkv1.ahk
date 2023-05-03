;// https://github.com/mmikeww/ClickLock-Indicator
#Requires AutoHotkey v1.1.34+
#SingleInstance, Force
CoordMode, Mouse, Screen
SetWinDelay, -1
SetBatchLines, -1

DllCall("SystemParametersInfo", "UInt", 0x101E, "UInt", 0, "UIntP", cl_enabled, "UInt", 0) ;SPI_GETMOUSECLICKLOCK
if (cl_enabled)
   Hotkey, ~LButton, LeftDownHandler, on
else
   MsgBox, % "ClickLock is not enabled in the Control Panel.`n`nExiting."
return

LeftDownHandler()
{
   global tthwnd
   DllCall("SystemParametersInfo", "UInt", 0x2008, "UInt", 0, "UIntP", cl_time, "UInt", 0) ;SPI_GETMOUSECLICKLOCKTIME
   KeyWait, LButton, % "T" cl_time/1000
   if (ErrorLevel) {   ; KeyWait timed out, so button is still held
      ToolTip, % "CLICKLOCK ACTIVATED`nCLICKLOCK ACTIVATED`nCLICKLOCK ACTIVATED"
      tthwnd := WinExist("ahk_class tooltips_class32 ahk_pid " . DllCall("GetCurrentProcessId"))
      SetTimer, TooltipTrackMouse, 10, on
      Loop, Parse, % "~LButton Up|~RButton|~MButton|~XButton1|~XButton2", |
         Hotkey, %A_LoopField%, ClickLockEnd, on
   }
}

ClickLockEnd()
{
   Loop, Parse, % "~LButton Up|~RButton|~MButton|~XButton1|~XButton2", |
      Hotkey, %A_LoopField%, off
   SetTimer, TooltipTrackMouse, off
   ToolTip,   ; turn off tooltip
}

TooltipTrackMouse()
{
   global tthwnd
   VarSetCapacity(buffer, 56, 0)  ; SKAN (tiny.cc/winmovez) and Lexikos (viewtopic.php?t=103459)
   DllCall("GetClientRect", "Ptr", tthwnd, "Ptr", &buffer+8)
   MouseGetPos, mx, my
   DllCall("SetRect", "Ptr", &buffer+24, "Int", mx-10, "Int", my-10, "Int", mx+10, "Int", my+10)
   NumPut(mx+30, buffer, 0, "Int"), NumPut(my+20, buffer, 4, "Int")
   DllCall("CalculatePopupWindowPosition", "Ptr", &buffer, "Ptr", &buffer+16, "UInt", 0x10000, "Ptr", &buffer+24, "Ptr", &buffer+40)  ; TPM_WORKAREA = 0x10000
   WinMove, ahk_id %tthwnd%,, NumGet(buffer, 40, "Int"), NumGet(buffer, 44, "Int")
}

