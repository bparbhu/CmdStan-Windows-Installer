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

# start prerequisites section

Section -Prerequisites "Install Prerequisites needed for Cmdstan"
	SetOutPath $INSTDIR\\Prerequisites
		
	MessageBox MB_YESNO "Install the latest version of MSYS2?" /SD IDYES IDNO endmsys2Setup
		File "..\Prerequisites\msys2-x86_64-20201109.exe"
		ExecWait "$INSTDIR\Prerequisites\msys2-x86_64-20201109.exe"
		ExecWait "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File .\msys2_setup.ps1 -FFFeatureOff"
		Goto endmsys2Setup
	endmsys2Setup:		

SectionEnd

Section close
SetAutoClose true

Section -Installation
	
	MessageBox MB_OK "Cmdstan is now installing on your Windows 10 device"
	
    # set the installation directory as the destination for the following actions
    SetOutPath $INSTDIR
 
    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
 
    # create a shortcut named "new shortcut" in the start menu programs directory
    # point the new shortcut at the program uninstaller
    CreateShortcut "$SMPROGRAMS\new shortcut.lnk" "$INSTDIR\uninstall.exe"
	
SectionEnd
SetAutoClose True

Section -curl file in powershell, untar it, and build cmdstan in MSYS2 "Powershell & MSYS2 Cmdstan installation process"
	
	SetOutPath $INSTDIR

	ExecShell /TOSTACK "curl" "https://github.com/stan-dev/cmdstan/releases/download/v2.26.1/cmdstan-2.26.1.tar.gz"
	
	ExecShell /TOSTACK "tar -xf" $INSTDIR\cmdstan-2.26.1.tar.gz
	
	ExecShell /TOSTACK "cd" $INSTDIR\cmdstan-2.26.1
	
	ExecWait "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File .\cmdstan_install.ps1 -FFFeatureOff"

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

AddBrandingImage left 100