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



; Default installation page
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; Default uninstallation page
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Set languages
!insertmacro MUI_LANGUAGE "English"


Section "CmdStan" SecCmdStan

  SetOutPath $INSTDIR

  ; Download and extract CmdStan release from GitHub
  StrCpy $0 "https://github.com/stan-dev/cmdstan/releases/download/v2.31.0"
  StrCpy $1 "cmdstan-2.31.0.tar.gz"
  StrCpy $R0 "0"
  StrCpy $R1 "3" ; Maximum number of retries
  loop:
    NSISdl::download /TIMEOUT=30000 "$0$1" "$TEMP\$1"
    Pop $R0
    DetailPrint "Download status: $R0"
    IntOp $R1 $R1 - 1
    StrCmp $R0 "success" success
    StrCmp $R1 "0" end loop
  success:
  end:

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
  ExecWait '"$INSTDIR\make" -j2 build examples/bernoulli/bernoulli'

  ; Create a shortcut in the Start menu
  CreateDirectory $SMPROGRAMS\CmdStan
  CreateShortCut "$SMPROGRAMS\CmdStan\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Uninstall"

  ; Remove the Start menu shortcut
  Delete "$SMPROGRAMS\CmdStan\Uninstall.lnk"
  RMDir "$SMPROGRAMS\CmdStan"

  ; Remove installed files and directories
  RMDir /r "$INSTDIR"

SectionEnd