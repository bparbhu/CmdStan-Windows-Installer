# This is the script that updates MSYS2 for the user
bash -l -c  "pacman -Syuu --noconfirm"
bash -1 -c "pacman -Sy mingw-w64-x86_64-make --noconfirm"
bash -1 -c "pacman -Syu gcc --noconfirm"
!include psexec.nsh
