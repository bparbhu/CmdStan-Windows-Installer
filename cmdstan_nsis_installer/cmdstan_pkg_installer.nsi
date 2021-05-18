!define VERSION "1.0"
!define PRODUCT_NAME "Cmdstan Installer"
!define PRODUCT_PUBLISHER "Brian Parbhu"
SetCompressor lzma
ManifestSupportedOS Win10
Name	"Cmdstan windows 10 installer ${VERSION}"
OutFile	Cmdstan-Installer-${VERSION}.exe
InstallDir $DESKTOP
RequestExecutionLevel User
ShowInstDetails show
ShowUninstDetails show
!ifndef PSEXEC_INCLUDED
!define PSEXEC_INCLUDED



# start prerequisites section

Section -Prerequisites "Install Prerequisites needed for Cmdstan"
	SetOutPath $INSTDIR\\Prereqresites
		
	MessageBox MB_YESNO "Install the latest version of MSYS2?" /SD IDYES IDNO endmsys2Setup
		File "Prereqresites\msys2-x86_64-20201109.exe"
		ExecWait "$INSTDIR\Prereqresites\msys2-x86_64-20201109.exe"
		ExecWait "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File powershell_scripts\msys2_setup.ps1 -FFFeatureOff"
		Goto endmsys2Setup
	endmsys2Setup:		

SectionEnd

Target x86-unicode
;Target x86-ansi

!AddPluginDir /x86-unicode   "NScurl\x86-unicode"
!AddPluginDir /x86-ansi      "NScurl\x86-ansi"

!include "MUI2.nsh"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Name NScurl-Test
ShowInstDetails show

Section Download
  DetailPrint 'Downloading...'
  NScurl::http get "https://github.com/stan-dev/cmdstan/releases/download/v2.26.1/cmdstan-2.26.1.tar.gz" "$INSTDR\cmdstan-2.26.1.tar.gz" /CANCEL /INSIST /Zone.Identifier /END
  Pop $0
  DetailPrint "Status: $0"
SectionEnd


Section close
SetAutoClose true

Section -Installation "Powershell & MSYS2 Cmdstan installation process"
	
	MessageBox MB_OK "Cmdstan is now installing on your Windows 10 device"
	
    # set the installation directory as the destination for the following actions
	SetOutPath $INSTDIR
		
	untgz::extract "-x""-f" $INSTDIR\cmdstan-2.26.1.tar.gz
	
	ExecDos::exec /TOSTACK "cd" $INSTDIR\cmdstan-2.26.1
	
	ExecWait "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File powershell_scripts\cmdstan_install.ps1 -FFFeatureOff"

    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
 
    # create a shortcut named "new shortcut" in the start menu programs directory
    # point the new shortcut at the program uninstaller
    CreateShortcut "$SMPROGRAMS\new shortcut.lnk" "$INSTDIR\uninstall.exe"
	
SectionEnd
SetAutoClose True

!echo "Cmdstan has been properly installed!"

# uninstaller section
Section -Uninstall
 
    # first, delete the uninstaller
    Delete "$INSTDIR\uninstall.exe"
 
    # second, remove the link from the start menu
    Delete "$SMPROGRAMS\new shortcut.lnk"
 
    RMDir $INSTDIR

# uninstaller section end
SectionEnd
SetAutoClose True