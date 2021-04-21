#msys2 cmdstan installation
bash -1 -c "mingw32-make clean-all --noconfirm"
bash -1 -c "mingw32-make install-tbb"
bash -1 -c "mingw32-make -j2 build"
!include psexec.nsh

