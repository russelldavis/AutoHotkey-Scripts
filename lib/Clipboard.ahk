ClipboardSave() {
  global ClipboardCopy := ClipboardAll
}

ClipboardRestore() {
  global ClipboardCopy
  Clipboard := ClipboardCopy
}
