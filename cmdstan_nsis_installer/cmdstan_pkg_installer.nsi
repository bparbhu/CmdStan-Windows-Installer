!define VERSION "0.1"
!define PRODUCT_NAME "Cmdstan Installer"
!define PRODUCT_PUBLISHER "Brian Parbhu"
SetCompressor lzma
ManifestSupportedOS Win10
Name	"Cmdstan windows 10 installer ${VERSION}"
OutFile	CmdStan-Installer-${VERSION}.exe
InstallDir $PROGRAMFILES\CmdStan
RequestExecutionLevel User
ShowInstDetails show
ShowUninstDetails show


; CmdStan Installer

!include "MUI2.nsh"



; General settings
Outfile "CmdStanInstaller.exe"



; Stan logo
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "stan_logo.bmp"
!define MUI_HEADERIMAGE_RIGHT

; Default installation pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; Default uninstallation pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Set languages
!insertmacro MUI_LANGUAGE "English"

Section "CmdStan" SecCmdStan

  SetOutPath $INSTDIR

  ; Get the latest CmdStan release version number
  StrCpy $0 "https://api.github.com/repos/stan-dev/cmdstan/releases/latest"
  StrCpy $1 "$TEMP\latest_release.json"
  NSISdl::download /TIMEOUT=30000 "$0" "$1"
  Pop $R0
  DetailPrint "Download status: $R0"
  FileRead $1 $R1

  ; Extract version number from JSON
  StrCpy $R2 "tag_name"
  ClearErrors
  StrCpy $R3 $R1 -1
  loop:
    IntOp $R3 $R3 + 1
    StrCpy $R4 $R1 1 $R3
    StrCmp $R4 $R2 loop
    IntOp $R3 $R3 + 9
    StrCpy $R5 $R1 -1 $R3
    StrCmp $R5 '"' "" loop
    StrCpy $R3 $R5

  DetailPrint "Latest CmdStan version: $R3"

  ; Download and extract CmdStan release from GitHub
  StrCpy $0 "https://github.com/stan-dev/cmdstan/releases/download/$R3/"
  StrCpy $1 "cmdstan-$R3.tar.gz"
  NSISdl::download /TIMEOUT=30000 "$0$1" "$TEMP\$1"
  Pop $R0
  DetailPrint "Download status: $R0"

  ; Include 7za.exe in your installer
  File "7za.exe"
  ExecWait '"$INSTDIR\7za.exe" x "$TEMP\$1" -so | "$INSTDIR\7za.exe" x -si -ttar -o"$INSTDIR"'

  ; Navigate to the extracted CmdStan directory
  FindFirst $R2 $R3 "$INSTDIR\cmdstan-*"
  StrCpy $INSTDIR "$INSTDIR\$R3"
  SetOutPath $INSTDIR

  ; Run make commands
  DetailPrint "Running make clean-all"
  ExecWait '"$INSTDIR\make" clean-all'

  DetailPrint "Running make build"
  ExecWait '"$INSTDIR\make" build'

  DetailPrint "Compiling example model"
  ExecWait '"$INSTDIR\make" -j2 build examples\bernoulli\bernoulli'

  ; Create a shortcut in the Start menu
  CreateDirectory $SMPROGRAMS\CmdStan
  CreateShortCut "$SMPROGRAMS\CmdStan\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Uninstall"

  ; Remove the Start menu shortcut
  Delete "$S