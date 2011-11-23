InputKey() {
  Input key, L1, {Esc}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{PrintScreen}{Pause}
  if (InStr(ErrorLevel, "Endkey")) {
    key := SubStr(ErrorLevel, 8) ;8 is StrLen("EndKey:") + 1
  }
  return %key%
}
