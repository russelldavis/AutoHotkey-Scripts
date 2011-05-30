Acc_Init()
{
	Static	h
	If Not	h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}
Acc_ObjectFromWindow(hWnd, idObject = -4)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	Return	ComObjEnwrap(9,pacc,1)
}

Acc_Children(pacc, cChildren, ByRef varChildren)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleChildren", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Int", 0, "Int", cChildren, "Ptr", VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*", cChildren)=0
Return	cChildren
}

^CapsLock::
  ControlGet hwnd, hwnd, , MSTaskListWClass1, ahk_class Shell_TrayWnd
  oAcc := Acc_ObjectFromWindow(hwnd)
  Loop, % Acc_Children(oAcc, oAcc.accChildCount, varChildren) {
    If (NumGet(varChildren,(A_Index-1)*(8+2*A_PtrSize))=3 && idChild:=NumGet(varChildren,A_Index*(8+2*A_PtrSize)-(2*A_PtrSize))) {
      If (oAcc.accState(idChild) & 8) {
        If (oAcc.accDefaultAction(idChild) = "Open") {
          WinActivate ahk_class Shell_TrayWnd
          oAcc.accDoDefaultAction(idChild)
        }
        Return
      }
    }
  }
return
