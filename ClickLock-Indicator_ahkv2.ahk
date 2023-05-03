;// https://github.com/mmikeww/ClickLock-Indicator
#Requires AutoHotkey v2.0.2+
#SingleInstance Force
CoordMode("Mouse", "Screen")
SetWinDelay(-1)

DllCall("SystemParametersInfo", "UInt", 0x101E, "UInt", 0, "UIntP", &cl_enabled := 0, "UInt", 0) ;SPI_GETMOUSECLICKLOCK
if (cl_enabled)
   Hotkey("~LButton", LeftDownHandler, "on")
else
   MsgBox("ClickLock is not enabled in the Control Panel.`n`nExiting.")
return

LeftDownHandler(ThisHotkey)
{
   global tthwnd
   DllCall("SystemParametersInfo", "UInt", 0x2008, "UInt", 0, "UIntP", &cl_time := 0, "UInt", 0) ;SPI_GETMOUSECLICKLOCKTIME
   if !KeyWait("LButton",  "T" cl_time/1000) {   ; KeyWait timed out, so button is still held
      ToolTip("CLICKLOCK ACTIVATED`nCLICKLOCK ACTIVATED`nCLICKLOCK ACTIVATED")
      tthwnd := WinExist("ahk_class tooltips_class32 ahk_pid " . DllCall("GetCurrentProcessId"))
      SetTimer(TooltipTrackMouse, 10)
      Loop Parse, "~LButton Up|~RButton|~MButton|~XButton1|~XButton2", "|"
         Hotkey(A_LoopField, ClickLockEnd, "on")
   }
}

ClickLockEnd(ThisHotkey)
{
   Loop Parse, "~LButton Up|~RButton|~MButton|~XButton1|~XButton2", "|"
      Hotkey(A_LoopField, "off")
   SetTimer(TooltipTrackMouse, 0)
   ToolTip("")   ; turn off tooltip
}

TooltipTrackMouse()
{
   global tthwnd
   buf := Buffer(56)   ; SKAN (tiny.cc/winmovez) and Lexikos (viewtopic.php?t=103459)
   DllCall("GetClientRect", "Ptr", tthwnd, "Ptr", buf.Ptr+8)
   MouseGetPos(&mx, &my)
   DllCall("SetRect", "Ptr", buf.Ptr+24, "Int", mx-10, "Int", my-10, "Int", mx+10, "Int", my+10)
   NumPut("int", mx+30, "int", my+20, buf)
   DllCall("CalculatePopupWindowPosition", "Ptr", buf.Ptr, "Ptr", buf.Ptr+16, "UInt", 0x10000, "Ptr", buf.Ptr+24, "Ptr", buf.Ptr+40)  ; TPM_WORKAREA = 0x10000
   WinMove(NumGet(buf, 40, "Int"), NumGet(buf, 44, "Int"),,, "ahk_id" tthwnd)
}

