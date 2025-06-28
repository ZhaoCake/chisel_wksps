#include <iostream>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VYourMain.h"

// 仿真时钟周期数
#define MAX_SIM_TIME 1000

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
    std::cout << "VCD跟踪已启用，波形将保存到 waveform.vcd" << std::endl;
    #endif
    
    std::cout << "开始仿真..." << std::endl;
    std::cout << "最大仿真时间: " << MAX_SIM_TIME << " 时钟周期" << std::endl;
    
    // 重置信号
    dut->reset = 1;
    dut->clock = 0;
    
    // 运行几个周期的重置
    for (int i = 0; i < 10; i++) {
        dut->clock = 0;
        dut->eval();
        #ifdef MTRACE
        if (m_trace) m_trace->dump(sim_time);
        #endif
        sim_time++;
        
        dut->clock = 1;
        dut->eval();
        #ifdef MTRACE
        if (m_trace) m_trace->dump(sim_time);
        #endif
        sim_time++;
    }
    
    // 释放重置
    dut->reset = 0;
    std::cout << "重置完成，开始正常仿真..." << std::endl;
    
    // 主仿真循环
    uint32_t test_value = 0x12345678;
    for (vluint64_t cycle = 0; cycle < MAX_SIM_TIME && !Verilated::gotFinish(); cycle++) {
        // 设置输入信号
        dut->io_in = test_value + cycle;
        
        // 上升沿
        dut->clock = 0;
        dut->eval();
        #ifdef MTRACE
        if (m_trace) m_trace->dump(sim_time);
        #endif
        
        // 下降沿
        dut->clock = 1;
        dut->eval();
        #ifdef MTRACE
        if (m_trace) m_trace->dump(sim_time);
        #endif
        
        // 检查输出
        uint32_t expected = dut->io_in + 1;
        if (dut->io_out != expected) {
            std::cout << "错误: 在周期 " << cycle 
                      << ", 输入=" << std::hex << dut->io_in 
                      << ", 期望输出=" << expected 
                      << ", 实际输出=" << dut->io_out << std::endl;
        } else if (cycle % 100 == 0) {
            std::cout << "周期 " << std::dec << cycle 
                      << ": 输入=" << std::hex << dut->io_in 
                      << ", 输出=" << dut->io_out << " ✓" << std::endl;
        }
        
        sim_time++;
    }
    
    std::cout << "仿真完成!" << std::endl;
    std::cout << "总仿真时间: " << sim_time << " 时间单位" << std::endl;
    
    // 清理
    #ifdef MTRACE
    if (m_trace) {
        m_trace->close();
        delete m_trace;
        std::cout << "VCD文件已保存" << std::endl;
    }
    #endif
    
    dut->final();
    
    std::cout << "仿真结束。" << std::endl;
    return 0;
}
