;;; Switch between windows of the same 
  WinSwitch(offset) {
    ; winSwitchList won't retain its value between calls when declared as static (bug in AHK)
    global winSwitchIsActive, winSwitchIndex, winSwitchList
    if (!winSwitchIsActive) {
      WinGetClass winSwitchClass, A
      WinGet winSwitchList, List, ahk_class %winSwitchClass%
      winSwitchIndex := 1
      winSwitchIsActive := True
    }
    ; Add the size of the list to the dividend so it won't go negative when offset is -1
    winSwitchIndex := Mod(winSwitchList + winSwitchIndex + offset - 1, winSwitchList) + 1
    WinActivate % "ahk_id" winSwitchList%winSwitchIndex%
  }
  !+CapsLock::WinSwitch(-1)
  !CapsLock::WinSwitch(1)
  ~Alt Up::winSwitchIsActive := False
