# makefile discription.
# basic build file for mruby

# compiler, linker (gcc), archiver, parser generator
export CC = gcc
export LL = gcc

ifeq ($(strip $(COMPILE_MODE)),)
  # default compile option
  COMPILE_MODE = debug
endif

ifeq ($(COMPILE_MODE),debug)
  CFLAGS = -g -O3
else ifeq ($(COMPILE_MODE),release)
  CFLAGS = -O3
else ifeq ($(COMPILE_MODE),small)
  CFLAGS = -Os
endif

BASEDIR = $(shell pwd)
INCLUDES = -I$(BASEDIR)/include -I$(BASEDIR)/vendors/include

MRUBY_CFLAGS = -I$(BASEDIR)/vendors/include
MRUBY_LIBS = -L$(BASEDIR)/vendors/lib -lmruby

CFUNC_CFLAGS = -I$(BASEDIR)/vendors/include
CFUNC_LIBS = -L$(BASEDIR)/vendors/lib -lmruby-cfunc

LIBFFI_CFLAGS = $(shell pkg-config $(BASEDIR)/vendors/lib/pkgconfig/libffi.pc --cflags)
LIBFFI_LIBS = $(shell pkg-config $(BASEDIR)/vendors/lib/pkgconfig/libffi.pc --libs)

ALL_CFLAGS = $(CFLAGS) $(INCLUDES) $(MRUBY_CFLAGS)
MAKE_FLAGS = --no-print-directory CC='$(CC)' LL='$(LL)' CFLAGS='$(ALL_CFLAGS)' \
	LIBFFI_CFLAGS='$(LIBFFI_CFLAGS)' LIBFFI_LIBS='$(LIBFFI_LIBS)' \
	CFUNC_CFLAGS='$(CFUNC_CFLAGS)' CFUNC_LIBS='$(CFUNC_LIBS)' \
	MRUBY_CFLAGS='$(MRUBY_CFLAGS)' MRUBY_LIBS='$(MRUBY_LIBS)'


##############################
# internal variables

export CP := cp
export RM_F := rm -f
export CAT := cat


##############################
# generic build targets, rules

# mruby test
.PHONY : test
test : all
	@$(MAKE) -C test $(MAKE_FLAGS) run

.PHONY : all
all : vendors/lib/libffi.a vendors/lib/libmruby.a vendors/lib/libmruby-cfunc.a $(TARGET)
	@$(MAKE) -C src $(MAKE_FLAGS)

# clean up
.PHONY : clean
clean :
	@$(MAKE) clean -C src $(MAKE_FLAGS)
	@$(MAKE) clean -C test $(MAKE_FLAGS)


##################
# libmruby-cfunc.a
tmp/mruby-cfunc:
	mkdir -p tmp
	cd tmp && git clone https://github.com/mobiruby/mruby-cfunc.git

vendors/lib/libmruby-cfunc.a: tmp/mruby-cfunc vendors/lib/libffi.a vendors/lib/libmruby.a
	cd tmp/mruby-cfunc/src && make MRBC="$(BASEDIR)/vendors/bin/mrbc" \
		CFLAGS="$(CFLAGS)" \
		TARGET="$(BASEDIR)/vendors/lib/libmruby-cfunc.a" \
		MRUBY_CFLAGS="$(MRUBY_CFLAGS)" \
		MRUBY_LIBS="$(MRUBY_LIBS)" \
		LIBFFI_CFLAGS="$(shell pkg-config $(BASEDIR)/vendors/lib/pkgconfig/libffi.pc --cflags)" \
		LIBFFI_LIBS="$(shell pkg-config $(BASEDIR)/vendors/lib/pkgconfig/libffi.pc --libs)"
	cp -r tmp/mruby-cfunc/include/* vendors/include


##################
# libffi.a
tmp/libffi:
	mkdir -p tmp
	cd tmp && git clone https://github.com/atgreen/libffi.git

vendors/lib/libffi.a: tmp/libffi
	echo $(BASEDIR)
	cd tmp/libffi && ./configure --prefix=$(BASEDIR)/vendors && make install


##################
# libmruby.a
tmp/mruby:
	mkdir -p tmp/mruby
	cd tmp; git clone https://github.com/mruby/mruby.git

vendors/lib/libmruby.a: tmp/mruby
	cd tmp/mruby && make
	cp -r tmp/mruby/include vendors/
	cp -r tmp/mruby/lib vendors/
	cp -r tmp/mruby/bin vendors/
