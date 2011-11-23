; Script by Russell Davis, http://russelldavis.blogspot.com/
#UseHook
#SingleInstance force
#NoEnv
ListLines Off
SendMode Input

arg1 = %1%
if (arg1 == "/exit") {
  DoExit()
}

DoExit() {
  ToolTip "VmwareMac.ahk exiting..."
  Sleep 700
  ToolTip
  ExitApp
}

Run Remap.ahk
ToolTip2("VmwareMac.ahk loaded...", 700)

;;; Failsafe in case the VM loses focus without going through
;;; this script (e.g., user switched windows after using vmware's
;;; hotkey for leaving the vm (instead of this script's hotkey),
;;; or perhaps something like ctrl-alt-delete).
setTimer, windowWatch, 1000
windowWatch:
  if (!WinActive("ahk_class VMUIFrame")) {
    DoExit()
  }
return


;;; Hotkeys with modifiers don't work while VMWare is capturing input
;;; (even when our hook gets called first), presumably due to processing
;;; that happens as soon as the key is pressed that messes with AHK's
;;; knowledge of state of the modifier keys. As a workaround, capture
;;; the primary key and check modifiers using GetKeyState.

CapsLock::
  if (GetKeyState("Ctrl") && !fakingControlDown && GetKeyState("Shift")) {
    Send ^+{Alt}
    DoExit()
  } else {
    ;; Turn Alt+Caps into Win+` (cycle windows on mac vm)
    if (GetKeyState("Alt")) {
      Send {Blind}{RAlt up}{LAlt up}{LControl down}
      fakingControlDown := true
    }
    ; This may have been set just now, or in a previous call to this hotkey
    if (fakingControlDown) {
      Send {Blind}``
    } else {
      Send {CapsLock}
    }
  }
return

;; Turn Alt+Tab into Win+Tab (for mac vm)
Tab::
  if (!fakingAltDown && GetKeyState("Alt")) {
    Send {Blind}{RAlt up}{LAlt up}{LControl down}
    fakingControlDown := true
  } else if (!fakingControlDown && GetKeyState("Control")) {
    Send {Blind}{LControl up}{RControl up}{LWin down}
    fakingWinDown := true
  } else if (!fakingWinDown && (GetKeyState("LWin") || GetKeyState("RWin"))) {
    Send {Blind}{LWin up}{RWin up}{LAlt down}
    fakingAltDown := true
  }
  Send {Blind}{Tab}
return

;; If we faked control-down (for alt-tab or alt-backtick), fake it back up
~Alt up::
  if (fakingControlDown) {
    Send {Blind}{LControl up}
    fakingControlDown := false
  }
return

;; If we faked win-down on (for control-tab), fake it back up
~Control up::
  if (fakingWinDown) {
    Send {Blind}{LWin up}
    fakingWinDown := false
  }
return

;; If we faked alt-down (for win-tab), fake it back up
~LWin up::
~RWin up::
  if (fakingAltDown) {
    Send {Blind}{LAlt up}
    fakingAltDown := false
  }
return

