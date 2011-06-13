ClipboardSave() {
  global ClipboardCopy := ClipboardAll
}

ClipboardRestore() {
  global ClipboardCopy
  Clipboard := ClipboardCopy
}

GetSelectionViaClipboard() {
    ClipboardSave()
    Clipboard := ""
    Send ^c
    ClipWait
    fileName := Clipboard
    ClipboardRestore()
    return % fileName
}
