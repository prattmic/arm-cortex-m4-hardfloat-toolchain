BINUTILS = binutils-2.22
NEWLIB = newlib-1.20.0
GCC = gcc-4.7.2
GDB = gdb-7.5.1

MAKEOPTIONS = -j8

WORKING = $(PWD)
PREFIX ?= $(PWD)

all: $(BINUTILS) $(GCC) $(GDB)

prefix:
	mkdir -p $(WORKING)/src

$(BINUTILS).tar.bz2: prefix
	cd $(WORKING)/src/	&&	\
	wget -c http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2	&&	\
	tar xvf $(BINUTILS).tar.bz2

$(NEWLIB).tar.gz: prefix
	cd $(WORKING)/src/	&&	\
	wget -c ftp://sourceware.org/pub/newlib/$(NEWLIB).tar.gz	&&	\
	tar xvf $(NEWLIB).tar.gz

$(GCC).tar.bz2: prefix
	cd $(WORKING)/src/	&&	\
	wget -c ftp://mirrors.kernel.org/gnu/gcc/$(GCC)/$(GCC).tar.bz2	&&	\
	tar xvf $(GCC).tar.bz2

$(GDB).tar.bz2: prefix
	cd $(WORKING)/src/	&&	\
	wget -c http://ftp.gnu.org/gnu/gdb/$(GDB).tar.bz2	&&	\
	tar xvf $(GDB).tar.bz2


$(BINUTILS): $(BINUTILS).tar.bz2
	cd $(WORKING)/src/$(BINUTILS)	&&	\
	patch -p1 -i $(WORKING)/patches/binutils.patch	&&	\
	./configure  --target=arm-none-eabi --prefix=$(PREFIX) --enable-interwork --enable-multilib --disable-nls --disable-libssp	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(WORKING)/src/$(BINUTILS) all	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(WORKING)/src/$(BINUTILS) install

$(NEWLIB): $(NEWLIB).tar.gz $(GCC).tar.bz2
	cd $(WORKING)/src/$(NEWLIB)	&&	\
	patch -p1 -i $(WORKING)/patches/newlib.patch	&&	\
	cp -r newlib/ libgloss/ -t $(WORKING)/src/$(GCC)/

$(GCC): $(NEWLIB) $(GCC).tar.bz2
	cd $(WORKING)/src/$(GCC)	&&	\
	mkdir -p $(PREFIX)/arm-none-eabi/lib/thumb/	&& \
	echo "patch -p1 -i $(WORKING)/patches/gcc-multilib.patch"	&&	\
	echo "mkdir $(WORKING)/src/$(GCC)/objdir" && cd $(WORKING)/src/$(GCC)/objdir	&&	\
	../configure --target=arm-none-eabi --prefix=$(PREFIX) --enable-interwork --enable-multilib --enable-languages="c" --with-newlib --with-headers=$(WORKING)/src/$(GCC)/newlib/libc/include/ --disable-libssp --disable-nls --disable-shared --disable-threads --with-system-zlib --disable-newlib-supplied-syscalls	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(WORKING)/src/$(GCC)/objdir all	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(WORKING)/src/$(GCC)/objdir install	&&	\
	cp $(WORKING)/src/$(GCC)/objdir/arm-none-eabi/thumb/cortex-m4/float-abi-hard/fpuv4-sp-d16/libgloss/arm/crt0.o $(PREFIX)/arm-none-eabi/lib/thumb/cortex-m4/float-abi-hard/fpuv4-sp-d16/

$(GDB): $(GDB).tar.bz2
	cd $(WORKING)/src/$(GDB)	&&	\
	./configure --target=arm-none-eabi --prefix=$(PREFIX) --enable-interwork --enable-multilib --disable-libssp --disable-nls --with-python	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(WORKING)/src/$(GDB) all	&&	\
	$(MAKE) $(MAKEOPTIONS) -C $(WORKING)/src/$(GDB) install
