; Script by Russell Davis, http://russelldavis.blogspot.com/
; with inspiration from http://www.autohotkey.com/forum/topic5702.html
; and http://www.autohotkey.com/forum/topic1662.html

#UseHook
#SingleInstance force
#NoEnv
ListLines Off


setTimer, windowWatch, 500

windowWatch:
  if WinActive("ahk_class TscShellContainerClass") {
    if (!active) {
      active := true
      ; Short sleep to make sure remote desktop's hook is in place first
      Sleep 50
      ; Coming out of suspend mode recreates the keyboard hook, giving
      ; our hook priority over the remote desktop client's.
      suspend off
    }
  } else {
    active := false
    suspend on
  }
return


; Be careful if using a hotkey with an Alt or Win modifier. The modifier's
; keyup event may trigger a system action. AHK is supposed to work around this,
; but it doesn't seem to work in this case.
; See http://www.autohotkey.com/forum/topic22378.html for a related discussion.
^+CapsLock::
  ; Need a short sleep here for focus to restore properly.
  Sleep 50
  WinMinimize ahk_class TscShellContainerClass
return
