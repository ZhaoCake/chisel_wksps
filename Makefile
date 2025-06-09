BUILD_DIR = ./build
MAIN_HOME = $(shell pwd)
CHISEL_PACKAGE = your_package_name  # Replace with your actual package name

# ********** verilator settings **********
TOPNAME = shuangMain
VERILATOR_FLAGS = --trace --exe --cc -j 0 --build 
VERILATOR_CFLAGS = -g -I $(MAIN_HOME)/verilator_csrc -mcmodel=large -O2

# 添加MTRACE控制选项
VERILATOR_CFLAGS += -DMTRACE=$(MTRACE)

# 明确指定需要的源文件
VSRC_DIR = $(BUILD_DIR)
VERILOG_SRCS = $(shell find $(VSRC_DIR) -name "*.v" -o -name "*.sv")
CSRC_DIR = $(MAIN_HOME)/verilator_csrc
CSRCS = $(CSRC_DIR)/memory.cpp \
        $(CSRC_DIR)/sim_main.cpp \
		$(CSRC_DIR)/difftest.cpp \

# ********** verilator settings **********

default: verilog

verilog:
	mkdir -p $(BUILD_DIR);
	- rm $(BUILD_DIR)/* -r;
	mill -i $(CHISEL_PACKAGE).runMain $(CHISEL_PACKAGE).Elaborate --target-dir $(BUILD_DIR)

test:
	mill -i __.test

vsim: vsimclean
	@echo "Compiling for verilator..."
	verilator --top-module $(TOPNAME) $(VERILATOR_FLAGS) \
		$(VERILOG_SRCS) $(CSRCS) \
		--CFLAGS "$(VERILATOR_CFLAGS)"

vsimclean:
	-rm -rf obj_dir

emu: verilog
	cd $(SHUANG_HOME)/difftest && $(MAKE)  EMU_TRACE=1  emu -j8  

bsp:
	mill -i mill.bsp.BSP/install

idea:
	mill -i mill.scalalib.GenIdea/idea

help:
	mill -i tlt.runMain tlt.Elaborate --help

clean:
	-rm -rf $(BUILD_DIR)
	-rm -rf obj_dir

.PHONY: clean init bump bsp idea help verilog emu vsim vsimclean