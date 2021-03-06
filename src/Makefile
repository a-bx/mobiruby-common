# makefile discription.
# basic build file for cfunc library

# project-specific macros
# extension of the executable-file is modifiable(.exe .out ...)
BASEDIR = $(shell pwd)
TARGET := $(BASEDIR)/../lib/libmobiruby-common.a
MRBCSRC := $(patsubst %.rb,%.c,$(wildcard $(BASEDIR)/mrb/*.rb))

EXCEPT1 := $(MRBCSRC)

OBJ1 := $(patsubst %.c,%.o,$(filter-out $(EXCEPT1),$(wildcard $(BASEDIR)/*.c)))
OBJ2 := $(patsubst %.m,%.o,$(filter-out $(EXCEPT1),$(wildcard $(BASEDIR)/*.m)))
OBJMRB := $(patsubst %.c,%.o,$(MRBCSRC))
OBJS := $(OBJ1) $(OBJ2) $(OBJ3)

MRBC := $(BASEDIR)/../vendors/bin/mrbc

# libraries, includes
INCLUDES = -I $(BASEDIR)/../tmp/mruby/src/


# libffi
LIBFFI_CFLAGS = $(shell pkg-config libffi --cflags)


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

ALL_CFLAGS = -Wall -Werror-implicit-function-declaration -std=c99 $(CFLAGS) $(MRUBY_CFLAGS) $(LIBFFI_CFLAGS) $(CFUNC_CFLAGS)


##############################
# internal variables

export CP := cp
export RM_F := rm -f
export CAT := cat


##############################
# generic build targets, rules

.PHONY : all
all : $(TARGET)

# executable constructed using linker from object files
$(TARGET) : $(OBJS) $(OBJMRB)
	$(AR) r $@ $(OBJS) $(OBJMRB)

-include $(OBJS:.o=.d) $(OBJMRB:.o=.d)

# mrby complie
$(OBJMRB) : %.o : %.rb
	$(MRBC) -Bmruby_data_$(*F) $<
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $(basename $<).c -o $@

# objects compiled from source
$(OBJ1) : %.o : %.c
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

# objects compiled from source
$(OBJ2) : %.o : %.m
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

# clean up
.PHONY : clean #cleandep
clean :
	@echo "make: removing targets, objects and depend files of `pwd`"
	-$(RM_F) $(TARGET) $(OBJS) $(OBJMRB) $(MRB)
	-$(RM_F) $(OBJS:.o=.d) $(OBJY:.o=.d)
	-$(RM_F) $(patsubst %.c,%.o,$(EXCEPT1)) $(patsubst %.c,%.d,$(EXCEPT1))
	-$(RM_F) $(patsubst %.m,%.o,$(EXCEPT1)) $(patsubst %.m,%.d,$(EXCEPT1))
