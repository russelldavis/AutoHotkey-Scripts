;;; # = Win
;;; ^ = Ctrl
;;; ! = Alt
;;; + = Shift

;;; Setup
  ;#Warn All
  #SingleInstance force
  #NoEnv
  #WinActivateForce
  #Include %A_ScriptDir%  ; Sets the directory for future includes
  SetWorkingDir %A_ScriptDir%
  SendMode Input
  ListLines Off
  SetTitleMatchMode 2 ; Match anywhere in title
  
  WinGet explorerPid, PID, ahk_class Shell_TrayWnd
  GroupAdd explorer, ahk_pid %explorerPid%
;;; End setup
  
;;; Lib Includes (must come first for auto-execute sections to run)
  #Include lib\Clipboard.ahk
  
;;; Hotkey includes
  #Include WinSwitch.ahk

;;;;;;;;;; Functions ;;;;;;;;;;

Explorer_GetSelectedFile() {
    ClipboardSave()
    SendPlay ^c
    fileName := Clipboard
    ClipboardRestore()
    return % fileName
}

;;;;;;;;;; Hotkeys ;;;;;;;;;;

;;; Sending any other way than SendPlay causes it to send on keyup rather than keydown
#\::
  if (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 3000)
    SendPlay dropbox\progs
  else
    SendPlay c:\users\russell\
  return
  
;;; Minimize active window
#Escape::WinMinimize,A

;;; Firefox
#IfWinActive, ahk_class MozillaWindowClass
  ;;; Clear and hide the search box
  ^+f::SendPlay {Control Down}f{Control Up}{Delete}{Escape}
#IfWinActive
  
;;; Auto-reloads the script when saved in an editor with ctrl+s
#IfWinActive, AutoHotkey.ahk
  ~^s::
    ToolTip, Reloading...
    Sleep 500
    Reload
    ToolTip
  return
#IfWinActive

;;; AHK hotkeys
#+s::ListHotkeys
#+a::Edit

;;; IntelliJ/PhpStorm fixes
#IfWinActive, JetBrains ahk_class SunAwtFrame
  ^f::SendInput ^f^a ;;; Make ctrl+f not suck
#IfWinActive

;;; SciTE has issues with some numpad keys
#IfWinActive, ahk_class SciTEWindow
  NumpadAdd::+
  NumpadSub::-
#IfWinActive

;;; Always-On-Top toggle
#z::WinSet, AlwaysOnTop, Toggle, A

;;; Paste from saved clipboard files
#v::
  Input, Key, L1,{Esc}{Enter}
  if (Key = "s")
      ClipFile=code-span.clip
  else if (Key = "d")
      ClipFile=code-div.clip
  else if (Key = "t")
      ClipFile=clipboard.txt
  else if (Key = "w") {
      FileAppend, %ClipboardAll%, C:\clipboard.txt ; The file extension doesn't matter.
      return
  } else {
      SoundBeep
      return
  }

  ClipboardSave()
  FileRead, Clipboard, *c %A_ScriptDir%\ahkclipboard\%ClipFile%
  SendPlay ^v
  ClipboardRestore()
return

;;;
#q::SendPlay !{F4}
  
;;; Fix the ridiculously broken play/pause button behavior caused by intellitype
;;; (set the button to disabled in the intellitype settings). Must use a keyboard
;;; hook here to intercept it from itype.exe. We can then send through the exact
;;; same keystroke and everything works how it should.
$Media_Play_Pause::
  ; Make sure winamp is runing
  if (!WinExist(ahk_class BaseWindow_RootWnd)) {
    Run winamp.exe
    WinWaitActive ahk_class BaseWindow_RootWnd
  }
  Send {Blind}{Media_Play_Pause}
return

;;; Run winamp, load media library, set to local media, focus search box
#w::
  Run winamp.exe
  DetectHiddenWindows on ;For finding the media library window
  WinWait ahk_class Winamp Gen ;media library window
  WinWaitActive ahk_class BaseWindow_RootWnd ;main window
  ControlFocus SysTreeView321 ;Media library
  SendPlay l
  Sleep 100
  SendPlay {Tab}
return

;;; winamp hotkeys
#IfWinActive, ahk_class BaseWindow_RootWnd
  ;;; Override this script's default minimize behavior. Sending a minimize message to the active winamp
  ;;; window (ahk_class BaseWindow_RootWnd) causes weird behavior -- the winamp window only partially
  ;;; minimizes, and restoring it causes this other proxy window to initially gain the focus, which causes
  ;;; problems for this script. Minimizing the proxy window instead makes everything work normally.
  #Escape::WinMinimize ahk_class Winamp v1.x
  ^e::ControlFocus Winamp Playlist Editor
  ^m::ControlFocus SysTreeView321 ;Media library
#IfWinActive

;;; Make RWin by itself act as AppsKey
RWin & Browser_Refresh::return
RWin::AppsKey

;;; Remap browser buttons to mouse buttons
Browser_Back::LButton
Browser_Forward::RButton

;;; Replace mintty's buggy intra-app window switching
#IfWinActive ahk_class mintty
  ^+Tab::WinSwitch(-1)
  ^Tab::WinSwitch(1)
#IfWinActive

;;; Show the start menu
#+r::SendEvent {Blind}{RWin up}{Shift up}{RWin}
  
;;; Restore focus to the previously focused window (rather than the taskbar window)
;;; when pressing Esc in the run dialog or start menu
#IfWinActive Run ahk_class #32770 ahk_group explorer
  ~Esc:: ;Fallthrough
#IfWinActive Start menu ahk_class DV2ControlHost
  ~Esc::SendPlay {Alt down}{Esc}{Alt up}
#IfWinActive

;;; Copy item to shortcuts folder
#IfWinActive ahk_class CabinetWClass
  ^s::
    fileName := Explorer_GetSelectedFile()
    SplitPath fileName, , , , nameNoExt
    EnvGet homeDrive, HOMEDRIVE
    EnvGet homePath, HOMEPATH
    shortcutPath := homeDrive . homePath . "\dropbox\progs\shortcuts\" . nameNoExt . ".lnk"
    FileCreateShortcut % fileName, %shortcutPath% ; wtf, 2nd arg requires %
    Run explorer /select`,%shortcutPath%
#IfWinActive

;;; For testing
#Numpad5::
return
