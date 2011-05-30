#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;; Copy to clipboard, then write to c:\clipboard.txt
^+c::
clipboard =  ; Start off empty to allow ClipWait to detect when the text has arrived.
Send ^c
ClipWait
FileAppend, %ClipboardAll%, C:\clipboard.txt ; The file extension doesn't matter.
return

;;; Load clipboard from c:\clipboard.txt, then paste
^+v::
FileRead, Clipboard, *c C:\clipboard.txt ; Note the use of *c, which must precede the filename.
Send ^v
return

;;; Save current clipboard contents to c:\clipboard.txt
^!+c::FileAppend, %ClipboardAll%, C:\clipboard.txt ; The file extension doesn't matter.
