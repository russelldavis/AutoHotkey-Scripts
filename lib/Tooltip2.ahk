ToolTip2(Text, Timeout = 2000, WhichToolTip = 1) {
  ToolTip %Text%, , ,WhichToolTip
  if (Timeout > 0) {
    SetTimer TT2Remove%WhichToolTip%, % -Timeout
  }
}

; Really ugly, but AHK provides no way to pass data to a timer callback
; (There are 20 because that's AHK's limit for unique ToolTip ids)
TT2Remove1:
TT2Remove2:
TT2Remove3:
TT2Remove4:
TT2Remove5:
TT2Remove6:
TT2Remove7:
TT2Remove8:
TT2Remove9:
TT2Remove10:
TT2Remove11:
TT2Remove12:
TT2Remove13:
TT2Remove14:
TT2Remove15:
TT2Remove16:
TT2Remove17:
TT2Remove18:
TT2Remove19:
TT2Remove20:
  WhichToolTip := SubStr(A_ThisLabel, 0)
  ToolTip, , , , WhichToolTip
return