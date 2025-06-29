#include <iostream>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VYourMain.h"

// 仿真时钟周期数
#define MAX_SIM_TIME 50

// 全局仿真时间
vluint64_t sim_time = 0;

int main(int argc, char** argv) {
    // 初始化Verilator
    Verilated::commandArgs(argc, argv);
    
    // 创建顶层模块实例
    std::unique_ptr<VYourMain> dut = std::make_unique<VYourMain>();
    
    // 初始化VCD跟踪（如果启用了MTRACE）
    VerilatedVcdC* m_trace = nullptr;
    #ifdef MTRACE
    Verilated::traceEverOn(true);
    m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");
    std::cout << "VCD跟踪已启用" << std::endl;
    #endif
    
    std::cout << "开始仿真加1器..." << std::endl;
    
    // 简化重置
    dut->reset = 1;
    dut->clock = 0;
    dut->eval();
    dut->clock = 1;
    dut->eval();
    dut->reset = 0;
    
    // 简化的测试循环
    for (int i = 0; i < MAX_SIM_TIME; i++) {
        dut->io_in = i;
        
        dut->clock = 0;
        dut->eval();
        #ifdef MTRACE
        if (m_trace) m_trace->dump(sim_time++);
        #endif
        
        dut->clock = 1;
        dut->eval();
        #ifdef MTRACE
        if (m_trace) m_trace->dump(sim_time++);
        #endif
        
        // 简单验证
        uint32_t expected = i + 1;
        if (dut->io_out == expected) {
            std::cout << "测试 " << i << ": " << i << " + 1 = " << dut->io_out << " ✓" << std::endl;
        } else {
            std::cout << "错误 " << i << ": 期望 " << expected << ", 得到 " << dut->io_out << std::endl;
        }
    }
    
    // 清理
    #ifdef MTRACE
    if (m_trace) {
        m_trace->close();
        delete m_trace;
        std::cout << "VCD文件已保存" << std::endl;
    }
    #endif
    
    dut->final();
    std::cout << "仿真完成!" << std::endl;
    return 0;
}
