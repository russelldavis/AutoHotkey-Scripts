7z := "c:\Program Files\7-Zip\7z.exe"

path = %1%
EnvGet userDir, USERPROFILE
SplitPath path, file, , ext, fileNoExt 
destBaseDir = %userDir%\Downloads
destDir = %destBaseDir%\%fileNoExt%
if (FileExist(destDir)) {
  destDir = %destDir%%A_Now%
}

destPath = %destBaseDir%\%file%
if (FileExist(destPath)) {
    destPath = %destBaseDir%\%fileNoExt%%A_Now%.%ext%
}

FileCopy %path%, %destPath%
FileCreateDir %destDir%

if (RegExMatch(file, ".*\.(tgz|tar(-\d+)?\.gz)$")) { ;Match tar-X.gz to include automatically renamed tar.gz files (for duplicate downloads)
  RunWait %comspec% /c ""%7z%" x -so "%destPath%" | "%7z%" x -si -ttar", %destDir%
} else {
  RunWait %7z% x %destPath%, %destDir%
}
FileRecycle %destPath%

Run %destDir%
