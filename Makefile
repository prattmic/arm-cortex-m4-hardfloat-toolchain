BINUTILS = binutils-2.22
NEWLIB = newlib-1.20.0
GCC = gcc-4.7.1
GDB = gdb-7.5

MAKEOPTIONS = -j8

PREFIX = $(PWD)

all: $(BINUTILS) $(GCC) $(GDB)

prefix:
	mkdir -p $(PREFIX)/src

$(BINUTILS).tar.bz2: prefix
	cd $(PREFIX)/src/	&&	\
	wget -c http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2	&&	\
	tar xvf $(BINUTILS).tar.bz2

$(NEWLIB).tar.gz: prefix
	cd $(PREFIX)/src/	&&	\
	wget -c ftp://sources.redhat.com/pub/newlib/$(NEWLIB).tar.gz	&&	\
	tar xvf $(NEWLIB).tar.gz

$(GCC).tar.bz2: prefix
	cd $(PREFIX)/src/	&&	\
	wget -c ftp://mirrors.kernel.org/gnu/gcc/$(GCC)/$(GCC).tar.bz2	&&	\
	tar xvf $(GCC).tar.bz2

$(GDB).tar.bz2: prefix
	cd $(PREFIX)/src/	&&	\
	wget -c http://ftp.gnu.org/gnu/gdb/$(GDB).tar.bz2	&&	\
	tar xvf $(GDB).tar.bz2


$(BINUTILS): $(BINUTILS).tar.bz2
	cd $(PREFIX)/src/$(BINUTILS)	&&	\
	patch -p1 -i $(PREFIX)/patches/binutils.patch	&&	\
	./configure  --target=arm-none-eabi --prefix=$(PREFIX) --enable-interwork --enable-multilib --disable-nls --disable-libssp	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(PREFIX)/src/$(BINUTILS) all	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(PREFIX)/src/$(BINUTILS) install

$(NEWLIB): $(NEWLIB).tar.gz $(GCC).tar.bz2
	cd $(PREFIX)/src/$(NEWLIB)	&&	\
	patch -p1 -i $(PREFIX)/patches/newlib.patch	&&	\
	cp -r newlib/ libgloss/ -t $(PREFIX)/src/$(GCC)/

$(GCC): $(NEWLIB) $(GCC).tar.bz2
	cd $(PREFIX)/src/$(GCC)	&&	\
	mkdir -p $(PREFIX)/arm-none-eabi/lib/thumb/	&& \
	patch -p1 -i $(PREFIX)/patches/gcc-multilib.patch	&&	\
	mkdir $(PREFIX)/src/$(GCC)/objdir && cd $(PREFIX)/src/$(GCC)/objdir	&&	\
	../configure --target=arm-none-eabi --prefix=$(PREFIX) --enable-interwork --enable-multilib --enable-languages="c" --with-newlib --with-headers=$(PREFIX)/src/$(GCC)/newlib/libc/include/ --disable-libssp --disable-nls --disable-shared --disable-threads --with-system-zlib --disable-newlib-supplied-syscalls	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(PREFIX)/src/$(GCC)/objdir all	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(PREFIX)/src/$(GCC)/objdir install	&&	\
	cp $(PREFIX)/src/$(GCC)/objdir/arm-none-eabi/thumb/cortex-m4/float-abi-hard/fpuv4-sp-d16/libgloss/arm/crt0.o $(PREFIX)/arm-none-eabi/lib/thumb/cortex-m4/float-abi-hard/fpuv4-sp-d16/

$(GDB): $(GDB).tar.bz2
	cd $(PREFIX)/src/$(GDB)	&&	\
	./configure --target=arm-none-eabi --prefix=$(PREFIX) --enable-interwork --enable-multilib --disable-libssp --disable-nls --with-python	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(PREFIX)/src/$(GDB) all	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(PREFIX)/src/$(GDB) install
