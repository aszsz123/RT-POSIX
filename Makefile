#   This file is owned by the Embedded Systems Laboratory of Seoul National University of Science and Technology
#   as a part of RT-AIDE or the RTOS-Agnostic and Interoperable Development Environment for Real-time Systems
#  
#  File: Makefile
#  Author: 2022 Raimarius Delgado
#  Description: Compile rt_posix as a shared object
#
CUR_DIR = .
INC_POSIX = $(CUR_DIR)/include
SRC_POSIX = $(CUR_DIR)/src
OBJ_DIR = $(CUR_DIR)/obj
OUT_DIR = $(CUR_DIR)/lib
DESTDIR ?= /opt
INSTALL_DIR = $(DESTDIR)/rt_posix

PYTHON_WRAPPER_DIR = $(CUR_DIR)/wrapper
# Defaults
CFLAGS_OPTIONS = -Wall -O3 -mtune=native -flto
CFLAGS_DEFAULT = $(CFLAGS_OPTIONS) -I$(INC_POSIX)
CFLAGS   = $(CFLAGS_DEFAULT) --coverage

LDFLAGS_DEFAULT = -lm -lrt -lpthread
LDFLAGS	 = $(LDFLAGS_DEFAULT)

# Sources
SOURCES	+= $(SRC_POSIX)/core/posix_rt.c
SOURCES	+= $(SRC_POSIX)/core/commons.c

# Output  name
POSIX_OUT = librtposix.so

CC		= gcc
CHMOD	= /bin/chmod
MKDIR	= /bin/mkdir
ECHO	= echo
RM	= /bin/rm
#######################################################################################################
OBJECTS = $(addprefix $(OBJ_DIR)/, $(notdir $(patsubst %.c, %.o, $(SOURCES))))
#######################################################################################################
vpath %.c  $(SRC_POSIX)
#######################################################################################################
all: library_posix examples tests 

python: python_wrapper

python_install:
	$(MAKE) -C $(PYTHON_WRAPPER_DIR) install;

apps: examples tests

examples: library_posix
	cd examples/ && make all

tests: library_posix
	cd test/ && make all

python_wrapper: 
	$(MAKE) -C $(PYTHON_WRAPPER_DIR) all;

library_posix: $(OUT_DIR)/$(POSIX_OUT)
$(OUT_DIR)/$(POSIX_OUT): $(OBJECTS)
	@$(MKDIR) -p $(OUT_DIR); pwd > /dev/null
	$(CC) -shared $(CFLAGS) -o $@ -fPIC $(OBJECTS) $(LDFLAGS)

$(OBJ_DIR)/%.o : %.c
	@$(MKDIR) -p $(OBJ_DIR); pwd > /dev/null
	$(CC) -MD $(CFLAGS) -c -o $@ $<

reset:
		$(RM) -rf \
		$(OBJ_DIR)/* \
		$(OBJ_DIR)   	

install: all
		@$(MKDIR) -p $(INSTALL_DIR); pwd > /dev/null
		@cp -rfp $(OUT_DIR) $(INC_POSIX) $(INSTALL_DIR)
		

clean_examples: 
	cd examples/ && make clean

clean_tests: 
	cd test/ && make clean

clean:
	$(RM) -rf \
		$(OBJ_DIR)/* \
		$(OBJ_DIR)   \
		$(OUT_DIR)   \
		$(CUR_DIR)/*.gcno   \
		$(CUR_DIR)/*.xml   \
		$(CUR_DIR)/*.info  \
		$(OUT_DIR)/*

	$(MAKE) -C $(PYTHON_WRAPPER_DIR) clean;

distclean: clean_examples clean_tests clean

re:
	@touch ./* $(INC_POSIX)/src/* 
	make clean
	make 

	$(MAKE) -C $(PYTHON_WRAPPER_DIR) re;

.PHONY: all clean 
#######################################################################################################
# Include header file dependencies generated by -MD option:
-include $(OBJ_DIR)/*.d


