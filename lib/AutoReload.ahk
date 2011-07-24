AutoReload(interval = 5000) {
  static modTime
  FileGetTime modTime, %A_ScriptFullPath%, M
  SetTimer AutoReloadTimer, %interval%
  return

  AutoReloadTimer:
  FileGetTime newModTime, %A_ScriptFullPath%, M
  if (modTime != newModTime) {
    modTime := newModTime
    ToolTip Reloading %A_ScriptName%
    Sleep 1000
    ReloadSilent()
  }
  return
}

ReloadSilent(showTooltipOnError = True) {
  RunWait %A_AhkPath% /restart /ErrorStdOut %A_ScriptFullPath%
  if (showTooltipOnError)
    ToolTip2("Error reloading " . A_ScriptName)
}