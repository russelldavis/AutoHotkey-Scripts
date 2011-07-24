ClipboardSave(clear = True) {
  global ClipboardCopy := ClipboardAll
  if (clear)
    Clipboard := ""
}

ClipboardRestore() {
  global ClipboardCopy
  Clipboard := ClipboardCopy
}

GetSelectionViaClipboard() {
    ClipboardSave()
    Send ^c
    ClipWait
    fileName := Clipboard
    ClipboardRestore()
    return % fileName
}
