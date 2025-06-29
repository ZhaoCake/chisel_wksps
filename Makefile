BUILD_DIR = ./build
MAIN_HOME = $(shell pwd)
CHISEL_PACKAGE = your_package_name
# Replace with your actual package name

# ********** verilator settings **********
TOPNAME = YourMain
VERILATOR_FLAGS = --trace --exe --cc -j 0 --build 
VERILATOR_CFLAGS = -g -I $(MAIN_HOME)/verilator_csrc -mcmodel=large -O2

# 添加MTRACE控制选项
VERILATOR_CFLAGS += -DMTRACE=$(MTRACE)

# 明确指定需要的源文件
VSRC_DIR = $(BUILD_DIR)
VERILOG_SRCS = $(shell find $(VSRC_DIR) -name "*.v" -o -name "*.sv")
CSRC_DIR = $(MAIN_HOME)/verilator_csrc
CSRCS = $(CSRC_DIR)/sim_main.cc

# ********** verilator settings **********

default: verilog

verilog:
	mkdir -p $(BUILD_DIR);
	- rm $(BUILD_DIR)/* -r;
	mill -i $(CHISEL_PACKAGE).runMain $(CHISEL_PACKAGE).Elaborate --target-dir $(BUILD_DIR)

test:
	mill -i __.test

vsim: 
	@echo "Compiling for verilator..."
	verilator --top-module $(TOPNAME) $(VERILATOR_FLAGS) \
		$(VERILOG_SRCS) $(CSRCS) \
		--CFLAGS "$(VERILATOR_CFLAGS)"
	@echo "Running simulation..."
	./obj_dir/V$(TOPNAME)

vsimclean:
	@echo "Cleaning up verilator build..."
	-rm -rf obj_dir

# 查看波形文件
wave:
	@if [ -f waveform.vcd ]; then \
		echo "Opening waveform.vcd with GTKWave..."; \
		gtkwave waveform.vcd; \
	else \
		echo "No waveform.vcd found. Run 'make vsim-trace' first."; \
	fi

# 生成IDE配置
bsp:
	mill mill.bsp.BSP/install

idea:
	mill mill.idea.GenIdea/idea

clean:
	-rm -rf $(BUILD_DIR)
	-rm -rf obj_dir
	-rm -f waveform.vcd
	-rm -f *.log

.PHONY: clean test verilog vsim vsimclean vsim-trace wave bsp idea help

help:
	@echo "可用的Make目标:"
	@echo "  verilog     - 生成Verilog代码"
	@echo "  test        - 运行Scala测试"
	@echo "  vsim        - 编译并运行Verilator仿真"
	@echo "  vsim-trace  - 运行带VCD跟踪的仿真"
	@echo "  wave        - 使用GTKWave查看波形"
	@echo "  clean       - 清理所有生成文件"
	@echo "  bsp         - 生成BSP配置"
	@echo "  idea        - 生成IntelliJ IDEA项目"
	@echo "  help        - 显示此帮助信息"