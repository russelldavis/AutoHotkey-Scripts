;;; # = Win
;;; ^ = Ctrl
;;; ! = Alt
;;; + = Shift

;;;;;;;;;; Setup ;;;;;;;;;;
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
AutoReload()

;;;;;;;;;; Constants ;;;;;;;;;;
WM_USER = 0x0400
WM_WA_IPC = %WM_USER%
IPC_GET_REPEAT = 251
IPC_SET_REPEAT = 253
IPC_STARTPLAY = 102


;;;;;;;;;; Lib Includes ;;;;;;;;;; (must come first for auto-execute sections to run)
#Include lib\Clipboard.ahk
#include lib\ClipboardData.ahk
#Include extern\Functions.ahk


;;;;;;;;;; Hotkey includes ;;;;;;;;;;
#Include WinSwitch.ahk


;;;;;;;;;; Functions ;;;;;;;;;;

isHotkeyCombo(hotkey, withinTime = 500) {
  return ((A_PriorHotKey = hotkey) && (withinTime <= 0 || A_TimeSincePriorHotkey < withinTime))
}

handleHotkeyCombo(hotkey, sendForCombo = "", sendForDefault = "", withinTime = 500) {
  if (isHotkeyCombo(hotkey, withinTime)) {
    if (sendForCombo != "") {
      Send % sendForCombo
    }
    return True
  } else {
    if (sendForDefault != "") {
      Send % sendForDefault
    }
    return False
  }
}

getHotkeyRepeatCount(withinTime = 0) {
  static repeatCount = {}
  thisHotKey := A_ThisHotKey
  if ((A_PriorHotKey = thisHotKey) && (withinTime <= 0 || A_TimeSincePriorHotkey < withinTime)) {
    repeatCount[thisHotKey]++
  } else {
    repeatCount[thisHotKey] := 0
  }
  return repeatCount[thisHotKey]
}


;;;;;;;;;; Hotkeys ;;;;;;;;;;
;;; Send home dir
;;; Sending any other way than SendPlay causes it to send on keyup rather than keydown
#\::
  count := getHotkeyRepeatCount(1000)
  if (count = 0)
    SendPlay c:\users\russell\
  else if (count = 1)
    SendPlay dropbox\
  else if (count = 2)
    SendPlay progs\
  else if (count = 3)
    SendPlay ahk\
return
  
;;; Minimize active window
#Escape::WinMinimize,A

;;; Firefox
#IfWinActive, ahk_class MozillaWindowClass
  ~^f::return
  ;;; Clear and dismiss the search box on ctrl+f + ctrl+d
  ^d::handleHotkeyCombo("~^f", "{Delete}{Esc}", "^d")
#IfWinActive
  
;;; Auto-reloads the script when saved in an editor with ctrl+s
#IfWinActive, AutoHotkey.ahk
  ~^s::
#IfWinActive, WinSwitch.ahk
  ~^s::
    AutoReload("Off")
    ToolTip, Reloading...
    Sleep 500
    Reload
    ; Reload failed
    AutoReload()
    ToolTip
  return
#IfWinActive

;;; AHK hotkeys
#+s::ListHotkeys
#+a::Edit

;;; IntelliJ/PhpStorm fixes
#IfWinActive, JetBrains ahk_class SunAwtFrame
  ^f::Send ^f^a
  ;;; Dismiss the search box on ctrl+f + ctrl+d
  ;;; Bug in AHK causes A_PriorHotkey to be "~^f" due to its usage elsewhere in the script
  ;;; (even though this version of hotkey still behaves as if the ~ was missing)
  ^d::handleHotkeyCombo("~^f", "{Delete}{Esc}", "^d")
#IfWinActive

;;; SciTE has issues with some numpad keys
#IfWinActive, ahk_class SciTEWindow
  NumpadAdd::+
  NumpadSub::-
#IfWinActive

;;; Always-On-Top toggle
#z::WinSet, AlwaysOnTop, Toggle, A

;;; Paste snippets
#v::
  ToolTip Clipboard Mode...
  Input, Key, L1,{Esc}{Enter}
  ToolTip
  ClipboardSave()
  
  if (Key = "s") {
    html=
      (LTrim
        <span style="font-size: 10pt; font-family: 'Courier New',monospace; padding: 0 1px; color: #444444;
                     background: #F8F8FF; border: 1px solid #DEDEDE;">x</span>
      )
    ClipboardSetHtml(html)
    Send ^v
    Send {Backspace}
  } else if (Key = "d") {
    html=
      (LTrim
        <div></div><div style="font-size: 10pt; font-family: 'Courier New',monospace; padding: 0 0.2em; color: #444444;
                    background: #F8F8FF; border: 1px solid #DEDEDE;">
        <br></div><div></div>
      )
    ClipboardSetHtml(html)
    Send ^v
    Send {Up}
  } else if (Key = "e") {
    ClipboardSetHtml("<span>x</span>")
    Send ^v
    Send {Backspace}
  } else {
    if (!InStr(ErrorLevel, "EndKey"))
      SoundBeep
    return
  }
  
  Sleep 500
  ClipboardRestore()
return

;;;
$^q::Send !{F4}
  
;;; Fix the ridiculously broken play/pause button behavior caused by intellitype
;;; (set the button to disabled in the intellitype settings). Must use a keyboard
;;; hook here to intercept it from itype.exe. We can then send through the exact
;;; same keystroke and everything works how it should.
$Media_Play_Pause::
  ; Make sure winamp is runing
  if (!WinExist("ahk_class BaseWindow_RootWnd")) {
    Run winamp.exe
    WinWaitActive ahk_class BaseWindow_RootWnd
  }
  SendInput {Media_Play_Pause}
return

;;; Run winamp, load media library, set to local media, focus search box
#w::
  Run winamp.exe
  DetectHiddenWindows on ;For ml_pmp_window
  WinWait ahk_class ml_pmp_window ;Top level window that should reflect when the media library is ready
  WinWaitActive ahk_class BaseWindow_RootWnd ;main window
  ControlFocus SysTreeView321
  SendPlay l ;Don't SendInput/SendEvent, it triggers the win+l lockscreen
  Sleep 50
  Send {Tab}
return

;;; Winamp: toggle repeat with status tooltip
#IfWinExist ahk_class Winamp v1.x
  ^!Ins::
    SendMessage WM_WA_IPC, 0, IPC_GET_REPEAT
    if (ErrorLevel != "FAIL") {
      newVal := 1 - ErrorLevel ; Toggle between 1 and 0
      SendMessage WM_WA_IPC, newVal, IPC_SET_REPEAT
      ToolTip2("Repeat: " . (newVal ? "ON" : "OFF"), 1000)
    }
  return
#IfWinExist

;;; Winamp: start playing from the beginning of the playlist. Strangely, this is not exposed
;;; in the Winamp UI (as far as I can tell). This is slightly different than the exposed
;;; "Start of list" function which moves to the start of the list but doesn't start playing.
#IfWinExist ahk_class ahk_class Winamp v1.x
  ^!Home::PostMessage WM_WA_IPC, 0, IPC_STARTPLAY
#IfWinExist

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
~RWin Up::
  ; AHK takes care of bypassing the start menu
  if (A_PriorKey = "RWin")
      Send {AppsKey}
return

;RWin & Browser_Refresh::return
;RWin::AppsKey

;;; Remap browser buttons to mouse buttons
Browser_Back::LButton
Browser_Forward::RButton

;;; mintty
#IfWinActive ahk_class mintty
  ;;; Replace mintty's buggy intra-app window switching
  ^+Tab::WinSwitch(-1)
  ^Tab::WinSwitch(1)
  ;;; mintty sends the same control sequence for space and shift+space
  ;;; so this mapping has to be set externally
  +Space::Send {Esc}
#IfWinActive

;;; Show the start menu
#+r::Send ^{Esc} ; Doing it with the WinKey gets messy
 
;;; Show the run dialog
;#^+r::Send {RWin down}r{RWin up}


;;; Restore focus to the previously focused window (rather than the taskbar window)
;;; when pressing Esc in the run dialog or start menu
#IfWinActive Run ahk_class #32770 ahk_group explorer
  ~Esc:: ;Fallthrough
#IfWinActive Start menu ahk_class DV2ControlHost
  ~Esc::Send !{Esc}
#IfWinActive

;;; Explorer
#IfWinActive ahk_class CabinetWClass
  ;;; Copy item to shortcuts folder
  ^s::
    fileName := GetSelectionViaClipboard()
    SplitPath fileName, , , , nameNoExt
    shortcutPath := EnvGet("USERPROFILE") . "\dropbox\progs\shortcuts\" . nameNoExt . ".lnk"
    FileCreateShortcut % fileName, % shortcutPath
    Run explorer /select`,%shortcutPath%
  return
  ;;; Edit
  ^e::Send {AppsKey}e
  ;;; Sometimes explorer windows don't respond to Ctrl+W. They always respond to Alt+F4.
  ^w::Send !{F4}
  ;;;
  ^+Tab::WinSwitch(-1)
  ^Tab::WinSwitch(1)
#IfWinActive

;;; Remote Desktop 
#IfWinActive ahk_class TscShellContainerClass
  ; Almost all keys are swallowed by remote desktop's keyboard hook which gets installed
  ; on top of AHK's. CapsLock is an exception, which makes it the perfect key to bind to.
  ;
  ; Be careful if an Alt or Win modifier here. The modifier's keyup event may trigger a
  ; system action. AHK is supposed to work around this but it doesn't seem to work in this
  ; case. See http://www.autohotkey.com/forum/topic22378.html for a related discussion.
  ^+CapsLock::
    ; Need a short sleep here for focus to restore properly.
    Sleep 50
    WinMinimize
  return
#IfWinActive

;;; Notepad2
#IfWinActive ahk_class Notepad2U
  ;;; Copy line if nothing selected
  ^c::
    StatusBarGetText status
    if (InStr(status, "Sel Ln 0")) {
      Send ^+c
      return
    }
    send ^c
  return
  
  ;;; Cut line if nothing selected
  ^x::
    StatusBarGetText status
    if (InStr(status, "Sel Ln 0")) {
      Send ^+x
      return
    }
    send ^x
  return

  ^d::Send ^+d
  ^w::Send !{F4}
  ^+w::Send ^w
  ^/::Send ^q
#IfWinActive

;;; Convert clipboard to plain text
#c::Clipboard := Clipboard

;;; Close system tray balloon notification
#+b::SendMessage 0x41c, , , , ahk_class tooltips_class32 ;TTM_POP=0x41c

;;; Fix weird behavior with right-alt key in X-Windows
#IfWinActive ahk_class cygwin/x X rl
  RAlt::LAlt
#IfWinActive

;;;;;;;;;; Hotstrings ;;;;;;;;;;
:*:dp\::c:\users\russell\dropbox\progs\


;;;;;;;;;; Testing ;;;;;;;;;;
F13::
  MsgBox % A_PriorKey
return

F14::
  ClipboardSetHtml("<b>test</b>")
return