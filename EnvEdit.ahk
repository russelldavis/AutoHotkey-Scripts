;;; Brings up the system dialog for editing environment variables, which is otherwise quite buried.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Run % "control.exe sysdm.cpl,System,3"
WinWaitActive System Properties ahk_class #32770, ,2
if (ErrorLevel)
  Exit
Send !n!sp
