;;; # = Win
;;; ^ = Ctrl
;;; ! = Alt
;;; + = Shift

;;; Setup
  ;#Warn All
  #SingleInstance force
  #NoEnv
  #WinActivateForce
  SendMode Input
  SetWorkingDir %A_ScriptDir%
  ListLines Off
  SetTitleMatchMode 2 ; Match anywhere in title
;;; End setup
  
;;; Includes
  #Include WinSwitch.ahk

;;; Sending any other way than SendPlay causes it to send on keyup rather than keydown
  #\::SendPlay c:\users\russell\

;;; Minimize active window
  #Escape::WinMinimize,A

;;; Firefox
  #IfWinActive, ahk_class MozillaWindowClass
    ;;; Clear and hide the search box
    ^+f::SendPlay {Control Down}f{Control Up}{Delete}{Escape}
  #IfWinActive
  
;;; Auto-reloads the script when saved in an editor with ctrl+s
  ~^s::
    SetTitleMatchMode 2
    IfWinActive, .ahk
    {
        Sleep, 1000
        ToolTip, Reloading...
        Sleep, 500
        Reload
        ToolTip
    }
  return

;;;
  #+s::ListHotkeys

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
    Clipboard := ClipFile

    ClipSave=%ClipboardAll%
    FileRead, Clipboard, *c %A_ScriptDir%\ahkclipboard\%ClipFile%
    SendPlay ^v
    Clipboard=%ClipSave%
  return

;;;
  #q::SendPlay !{F4}
;;;
  #+a::Edit

;;; Run winamp, load media library, set to local media, focus search box
  #w::
    Run winamp.exe
    WinWaitActive ahk_class BaseWindow_RootWnd
    ControlFocus SysTreeView321 ;Media library
    SendPlay l
    Sleep 100
    SendPlay {Tab}
  return

#IfWinActive, ahk_class BaseWindow_RootWnd ;Winamp
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
  #+r::Send {Blind}{RWin up}{Shift up}{RWin}
  
;;;
