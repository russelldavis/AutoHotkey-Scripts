; Adapted from http://www.autohotkey.com/forum/topic8402.html

StrPutVar(string, ByRef var, encoding)
{
    ; Ensure capacity.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    return StrPut(string, &var, encoding)
}

StrToUtf8(str)
{
  utf8 := ""
  StrPutVar(str, utf8, "cp65001")
  return utf8
}

ClipboardSetData(_format, ByRef data, _dataSize=0, _bEmptyClipboard=true)
{
   local res, mem, str, cfFormat, errorCode

   errorCode = 0

   If (_dataSize = 0)
   {
      ; Assume it is a simple string; otherwise, should provide real length...
      _dataSize := StrLen(data) * (A_IsUnicode ? 2 : 1)
      If (_dataSize = 0)
      {
         errorCode = SIZE
         Goto SCD_End
      }
   }

   ; Open the clipboard, and empty it.
   res := DllCall("OpenClipboard", "UInt", 0)
   If (res = 0)
   {
      errorCode = OC
      Goto SCD_End
   }
   If (_bEmptyClipboard)
   {
      DllCall("EmptyClipboard")
   }

   ; Allocate a global memory object for the text
   mem := DllCall("GlobalAlloc"
         , "UInt", 2 ; GMEM_MOVEABLE
         , "UInt", _dataSize + 1 ; +1 in case it is a zero-terminated string
         , "Ptr")
   If (mem = 0)
   {
      errorCode = GA
      Goto SCD_End
   }

   ; Lock the handle and copy the text to the buffer
   str := DllCall("GlobalLock", "Ptr", mem, "Ptr")
   DllCall("RtlMoveMemory"
         , "Ptr", str
         , "Ptr", &data
         , "UInt",_dataSize)
   ; In case it is a zero-terminated string, we put the final zero
   DllCall("RtlZeroMemory", "Ptr", str + _dataSize, "UInt", 1)
   DllCall("GlobalUnlock", "Ptr", mem)

   ; Handle format
   If _format is integer
   {
      cfFormat := _format
   }
   Else
   {
      cfFormat := DllCall("RegisterClipboardFormat", "Str", _format)
      If (cfFormat = 0)
      {
         errorCode = RCF
         Goto SCD_End
      }
   }

   ; Place the handle on the clipboard
   res := DllCall("SetClipboardData"
         , "UInt", cfFormat
         , "Ptr", mem)
   If (res = 0)
   {
      errorCode = SCD
      Goto SCD_End
   }
   
SCD_End:
   If errorCode != 0
   {
      MsgBox errorCode
      errorCode = %errorCode%  (%A_LastError%)
   }

   DllCall("CloseClipboard")
   If (mem = 0)
   {
      DllCall("GlobalFree", "Ptr", mem)
   }

   ErrorLevel := errorCode
}

makeClipboardHtml(sHtmlFragment)
{
  m_sDescription =
  (LTrim
  Version:0.9
  StartHTML:aaaaaaaaaa
  EndHTML:bbbbbbbbbb
  StartFragment:cccccccccc
  EndFragment:dddddddddd

  )
  sContextStart = <HTML><BODY>
  sContextEnd = </BODY></HTML>

  sData := m_sDescription . sContextStart . sHtmlFragment . sContextEnd
  
  mylen := StrLen(m_sDescription)
  thelen := SubStr("0000000000" . mylen, -9)
  StringReplace sData, sData, aaaaaaaaaa, %thelen%

  mylen := StrLen(sData)
  thelen := SubStr("0000000000" . mylen, -9)
  StringReplace sData, sData, bbbbbbbbbb, %thelen%

  mylen :=  StrLen(m_sDescription . sContextStart)
  thelen := SubStr("0000000000" . mylen, -9)
  StringReplace sData, sData, cccccccccc, %thelen%

  mylen :=  StrLen(m_sDescription . sContextStart . sHtmlFragment)
  thelen := SubStr("0000000000" . mylen, -9)
  StringReplace sData, sData, dddddddddd, %thelen% 

  Return sData
}

ClipboardSetHtml(html, emptyClipboard=true)
{
  clipboardHtml := makeClipboardHtml(html)
  len := StrLen(clipboardHtml)
  clipboardHtml := StrToUtf8(clipboardHtml)
  ClipboardSetData("HTML Format", clipboardHtml, len, emptyClipboard)
}
