更新的模板维护在我的nixconfigs仓库的devShell/chiselhdl下。

---

# Chisel项目模板

这是一个完整的Chisel项目开发模板，配置了Nix开发环境、Verilator仿真和完整的构建流程。

## 特性

- 🚀 **完整的Nix开发环境** - 使用flake.nix提供一致的开发环境
- 🔧 **Mill构建系统** - 现代化的Scala构建工具
- ⚡ **Verilator仿真** - 高性能的Verilog仿真器
- 📊 **波形查看** - GTKWave集成，支持VCD波形文件
- 🧪 **测试框架** - ChiselTest集成
- 🛠️ **IDE支持** - BSP和IntelliJ IDEA项目生成

## 快速开始

### 使用Nix（推荐）

1. 确保你安装了Nix并启用了flakes功能
2. 进入开发环境：
   ```bash
   nix develop
   ```
3. 你也可以直接用 `.envrc` 自动激活环境（见下文）

### 手动安装依赖

如果不使用Nix，你需要安装：
- JDK 17
- Scala 2.13
- Mill
- Verilator
- GTKWave（可选，用于波形查看）

## 使用方法

### 基本命令

```bash
# 生成Verilog代码
nix run .#verilog

# 运行仿真
nix run .#vsim

# 运行带波形跟踪的仿真
nix run .#vsim-trace

# 查看波形文件
nix run .#wave

# 运行测试
nix run .#test

# 清理生成文件
nix run .#clean

# 显示帮助
nix run .#help
```

### 项目结构

```
.
├── flake.nix                    # Nix开发环境配置
├── build.mill                  # Mill构建配置
├── your_package_name/
│   └── src/
│       ├── YourMain.scala       # 主模块
│       └── Elaborate.scala      # Verilog生成脚本
├── verilator_csrc/
│   └── sim_main.cc             # C++仿真驱动
├── build/                      # 生成的Verilog文件
└── obj_dir/                    # Verilator编译输出
```

## 自定义你的项目

1. **重命名包**：
   - 将 `your_package_name` 目录重命名为你的项目名
   - 更新 `build.mill` 中的对象名
   - 更新 `flake.nix` 中的 `chiselPackage` 变量

2. **修改主模块**：
   - 编辑 `YourMain.scala` 实现你的硬件逻辑
   - 更新 `Elaborate.scala` 中的模块名引用

3. **自定义仿真**：
   - 修改 `verilator_csrc/sim_main.cc` 来适配你的模块接口
   - 调整仿真参数和测试数据

## 开发环境配置

### IDE支持

生成BSP配置（推荐用于VS Code + Metals）：
```bash
nix run .#bsp
```

生成IntelliJ IDEA项目：
```bash
nix run .#idea
```

### 调试

运行带跟踪的仿真来生成VCD波形文件：
```bash
nix run .#vsim-trace
```

然后使用GTKWave查看波形：
```bash
nix run .#wave
```

## 故障排除

### 常见问题

1. **Mill找不到模块**：确保包名和目录结构匹配
2. **Verilator编译失败**：检查生成的Verilog语法
3. **仿真运行失败**：确保C++代码中的信号名与Chisel模块匹配

### 清理和重建

如果遇到奇怪的问题，尝试完全清理并重建：
```bash
nix run .#clean
nix run .#verilog
nix run .#vsim
```

## 贡献

欢迎提交Issue和Pull Request来改进这个模板！

## 许可证

MIT License
