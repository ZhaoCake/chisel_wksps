{
  description = "Chisel项目模板开发环境";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # 定义JDK版本（Chisel推荐使用JDK 11或17）
        jdk = pkgs.openjdk17;

        # Mill构建工具
        mill = pkgs.mill;

        # Scala相关工具
        scala = pkgs.scala_2_13;

        # 仿真和调试工具
        verilator = pkgs.verilator;
        gtkwave = pkgs.gtkwave;

        # C++开发工具（Verilator需要）
        gcc = pkgs.gcc;
        gnumake = pkgs.gnumake;

        # 开发工具
        git = pkgs.git;
        vim = pkgs.vim;

        # 创建开发环境shell脚本
        setupScript = pkgs.writeShellScriptBin "setup-chisel-env" ''
          echo "🚀 Chisel项目模板开发环境已启动！"
          echo ""
          echo "📋 可用工具："
          echo "  - Java: $(java -version 2>&1 | head -1)"
          echo "  - Scala: $(scala -version 2>&1)"
          echo "  - Mill: $(mill --version 2>&1)"
          echo "  - Verilator: $(verilator --version | head -1)"
          echo "  - GCC: $(gcc --version | head -1)"
          echo ""
          echo "🛠️  常用命令："
          echo "  make verilog    - 生成Verilog代码"
          echo "  make vsim       - 编译并运行Verilator仿真"
          echo "  make test       - 运行Scala测试"
          echo "  make clean      - 清理生成文件"
          echo ""
          echo "📁 项目结构："
          echo "  your_package_name/src/  - Chisel源代码"
          echo "  build/                  - 生成的Verilog文件"
          echo "  obj_dir/               - Verilator编译输出"
          echo "  verilator_csrc/        - C++仿真代码"
          echo ""
          echo "环境变量已设置：JAVA_HOME, SCALA_HOME"
          echo "开发环境准备就绪！Happy coding! 🎉"
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          name = "chisel-template-dev";

          buildInputs = with pkgs; [
            # Java开发环境
            jdk

            # Scala和构建工具
            scala
            mill
            sbt  # 备用构建工具

            # 硬件仿真工具
            verilator
            gtkwave

            # C++开发工具链
            gcc
            gnumake
            cmake
            pkg-config

            # 系统库（Verilator可能需要）
            zlib
            ncurses

            # 开发工具
            git
            vim
            tree
            htop
            ripgrep
            fd

            # 自定义脚本
            setupScript
          ];

          shellHook = ''
            # 设置环境变量
            export JAVA_HOME="${jdk}"
            export SCALA_HOME="${scala}"
            export PATH="$JAVA_HOME/bin:$SCALA_HOME/bin:$PATH"

            # Verilator相关环境变量
            export VERILATOR_ROOT="${verilator}"

            # 项目相关环境变量
            export PROJECT_ROOT="$(pwd)"
            export BUILD_DIR="$PROJECT_ROOT/build"

            # 创建必要的目录
            mkdir -p build
            mkdir -p obj_dir

            # 运行setup脚本显示欢迎信息
            setup-chisel-env
          '';

          # 为IDE提供的环境变量
          NIX_SHELL_PRESERVE_PROMPT = 1;
        };

        # 提供一些有用的开发命令
        apps = {
          # 快速构建命令
          build = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "chisel-build" ''
              echo "🔨 构建Chisel项目..."
              make verilog
            '';
          };

          # 快速仿真命令
          sim = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "chisel-sim" ''
              echo "🏃 运行Verilator仿真..."
              make vsim
            '';
          };

          # 清理命令
          clean = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "chisel-clean" ''
              echo "🧹 清理构建文件..."
              make clean
            '';
          };

          # 测试命令
          test = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "chisel-test" ''
              echo "🧪 运行测试..."
              make test
            '';
          };
        };

        # 包输出（如果需要）
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "chisel-template";
          version = "0.1.0";

          src = ./.;

          buildInputs = [ jdk mill verilator gcc ];

          buildPhase = ''
            export JAVA_HOME="${jdk}"
            make verilog
          '';

          installPhase = ''
            mkdir -p $out
            cp -r build/* $out/
          '';
        };
      });
}
