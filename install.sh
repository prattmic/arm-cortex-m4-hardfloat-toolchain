PREFIX=/path/to/your/build/location
export PATH=$PATH:$PREFIX/bin/
mkdir src
cd src

wget http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.bz2
tar jxvf binutils-2.22.tar.bz2
wget ftp://sources.redhat.com/pub/newlib/newlib-1.20.0.tar.gz
tar zxvf newlib-1.20.0.tar.gz
wget ftp://mirrors.kernel.org/gnu/gcc/gcc-4.7.0/gcc-4.7.0.tar.bz2
tar jxvf gcc-4.7.0.tar.bz2
wget http://ftp.gnu.org/gnu/gdb/gdb-7.4.tar.bz2
tar jxvf gdb-7.4.tar.bz2
read -p "Press enter to continue..."

cd binutils-2.22/
patch -p1 -i ../../patches/binutils.patch
read -p "Patch Applied."
./configure  --target=arm-none-eabi --prefix=$PREFIX --enable-interwork --enable-multilib --disable-nls --disable-libssp
make -j8 all
make -j8 install
read -p "Press enter to continue..."
cd ..

cd newlib-1.20.0/
patch -p1 -i ../../patches/newlib.patch
read -p "Newlib patched"
cd ..

cd gcc-4.7.0/
cp -r ../newlib-1.20.0/newlib/ .
cp -r ../newlib-1.20.0/libgloss/ .
patch -p1 -i ../../patches/gcc-multilib.patch
read -p "Patch should be applied."
mkdir objdir
cd objdir/
../configure --target=arm-none-eabi --prefix=$PREFIX --enable-interwork --enable-multilib --enable-languages="c" --with-newlib --with-headers=../../newlib-1.20.0/newlib/libc/include/ --disable-libssp --disable-nls --disable-shared --disable-threads --with-system-zlib --disable-newlib-supplied-syscalls
make -j8 all-gcc
make -j8 install-gcc
read -p "Press enter to continue..."

make -j8 all
sudo make -j8 install
sudo cp arm-none-eabi/thumb/cortex-m4/float-abi-hard/fpuv4-sp-d16/libgloss/arm/crt0.o $PREFIX/arm-none-eabi/lib/thumb/cortex-m4/float-abi-hard/fpuv4-sp-d16/
read -p "Press enter to continue..."

cd ../..
cd gdb-7.4/
./configure --target=arm-none-eabi --prefix=$PREFIX --enable-interwork --enable-multilib --disable-libssp --disable-nls
make -j8 all
sudo make -j8 install
