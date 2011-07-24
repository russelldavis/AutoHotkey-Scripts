#NoEnv

7z := "7z.exe"

path = %1%
if (!path) {
  MsgBox Missing filename
  exit -1
}

EnvGet userDir, USERPROFILE
SplitPath path, file, , ext, fileNoExt 
destBaseDir = %userDir%\Downloads
;Append current timestamp to make sure it's a unique name. We'll attempt to rename it without
;the timestamp later in the script. Doing it this way simplifies some logic.
destDir = %destBaseDir%\%fileNoExt%-%A_Now%

FileCreateDir %destDir%

if (RegExMatch(file, ".*\.(tgz|tar(-\d+)?\.gz)$")) { ;Match tar-X.gz to include automatically renamed tar.gz files (for duplicate downloads)
  RunWait %comspec% /c ""%7z%" x -so "%path%" | "%7z%" x -si -ttar", %destDir%
} else {
  RunWait %comspec% /k ""%7z%" x "%path%"", %destDir%
}

;;;Smart directory handling
;;;If there's only a single file and it's a directory, move it up one level
Loop %destDir%\*.*, 1 ;files & folders
{ 
  if (outPath != "") {
    ;More than one file
    outPath := ""
    break
  }

  outIsDir := InStr(A_LoopFileAttrib, "D")
  outFile := A_LoopFileName
  outPath := A_LoopFileFullPath
}

if (outPath != "" && outIsDir) {
  ;Only one file, and it's a directory, so move it up one level
  newPath = %destBaseDir%\%outFile%
  if (FileExist(newPath)) {
    newPath = %destBaseDir%\%outFile%-%A_Now%-a ;-a at the end so it won't conflict with destDir
  }
  FileMoveDir %outPath%, %newPath%, R
  FileRemoveDir %destDir%
  Run % newPath
} else {
  ;More than one file, or one file that's not a directory.
  ;Try to name the directory the same as the archive
  newPath = %destBaseDir%\%fileNoExt%
  FileMoveDir %destDir%, %newPath%, R
  Run % (ErrorLevel ? destDir : newPath)
}

