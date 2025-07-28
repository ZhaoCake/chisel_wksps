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

        jdk = pkgs.openjdk17;
        mill = pkgs.mill;
        scala = pkgs.scala_2_13;
        verilator = pkgs.verilator;
        gtkwave = pkgs.gtkwave;
        gcc = pkgs.gcc;
        gnumake = pkgs.gnumake;
        cmake = pkgs.cmake;
        pkg-config = pkgs.pkg-config;
        python3 = pkgs.python3;
        zlib = pkgs.zlib;
        ncurses = pkgs.ncurses;
        git = pkgs.git;
        vim = pkgs.vim;
        tree = pkgs.tree;
        htop = pkgs.htop;
        ripgrep = pkgs.ripgrep;
        fd = pkgs.fd;

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
          echo "  nix run .#verilog    - 生成Verilog代码"
          echo "  nix run .#vsim       - 编译并运行Verilator仿真"
          echo "  nix run .#test       - 运行Scala测试"
          echo "  nix run .#clean      - 清理生成文件"
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

        chiselPackage = "your_package_name";
        topModule = "YourMain";
        buildDir = "build";
        csrcDir = "verilator_csrc";
        objDir = "obj_dir";

        # 生成Verilog
        verilogCmd = ''
          mkdir -p ${buildDir}
          rm -rf ${buildDir}/*
          mill -i ${chiselPackage}.runMain ${chiselPackage}.Elaborate --target-dir ${buildDir}
        '';

        # Scala测试
        testCmd = ''
          mill -i __.test
        '';

        # verilator仿真
        vsimCmd = ''
          verilator --top-module ${topModule} --trace --exe --cc -j 0 --build \
            $(find ${buildDir} -name "*.v" -o -name "*.sv") \
            ${csrcDir}/sim_main.cc \
            --CFLAGS "-g -I $(pwd)/${csrcDir} -mcmodel=large -O2"
          ./obj_dir/V${topModule}
        '';

        # verilator仿真（带VCD跟踪）
        vsimTraceCmd = ''
          verilator --top-module ${topModule} --trace --exe --cc -j 0 --build \
            -DMTRACE=1 \
            $(find ${buildDir} -name "*.v" -o -name "*.sv") \
            ${csrcDir}/sim_main.cc \
            --CFLAGS "-g -I $(pwd)/${csrcDir} -mcmodel=large -O2 -DMTRACE=1"
          ./obj_dir/V${topModule}
        '';

        # 清理
        cleanCmd = ''
          rm -rf ${buildDir}
          rm -rf ${objDir}
          rm -f waveform.vcd
          rm -f *.log
        '';

        # 波形查看
        waveCmd = ''
          if [ -f waveform.vcd ]; then
            echo "Opening waveform.vcd with GTKWave..."
            gtkwave waveform.vcd
          else
            echo "No waveform.vcd found. Run 'nix run .#vsim-trace' first."
          fi
        '';

        # BSP/IDE
        bspCmd = "mill mill.bsp.BSP/install";
        ideaCmd = "mill mill.idea.GenIdea/idea";

        # 帮助
        helpCmd = ''
          echo "可用的nix命令:"
          echo "  nix run .#verilog     - 生成Verilog代码"
          echo "  nix run .#test        - 运行Scala测试"
          echo "  nix run .#vsim        - 编译并运行Verilator仿真"
          echo "  nix run .#vsim-trace  - 运行带VCD跟踪的仿真"
          echo "  nix run .#wave        - 使用GTKWave查看波形"
          echo "  nix run .#clean       - 清理所有生成文件"
          echo "  nix run .#bsp         - 生成BSP配置"
          echo "  nix run .#idea        - 生成IntelliJ IDEA项目"
          echo "  nix run .#help        - 显示此帮助信息"
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          name = "chisel-template-dev";
          buildInputs = [
            jdk scala mill pkgs.sbt verilator gtkwave gcc gnumake cmake pkg-config
            python3 zlib ncurses git vim tree htop ripgrep fd setupScript
          ];
          shellHook = ''
            export JAVA_HOME="${jdk}"
            export SCALA_HOME="${scala}"
            export PATH="$JAVA_HOME/bin:$SCALA_HOME/bin:$PATH"
            export PROJECT_ROOT="$(pwd)"
            export BUILD_DIR="$PROJECT_ROOT/build"
            mkdir -p build
            mkdir -p obj_dir
            setup-chisel-env
          '';
          NIX_SHELL_PRESERVE_PROMPT = 1;
        };

        apps = {
          verilog = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "verilog" verilogCmd; };
          test = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "test" testCmd; };
          vsim = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "vsim" vsimCmd; };
          "vsim-trace" = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "vsim-trace" vsimTraceCmd; };
          wave = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "wave" waveCmd; };
          clean = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "clean" cleanCmd; };
          bsp = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "bsp" bspCmd; };
          idea = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "idea" ideaCmd; };
          help = flake-utils.lib.mkApp { drv = pkgs.writeShellScriptBin "help" helpCmd; };
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "chisel-template";
          version = "0.1.0";
          src = ./.;
          buildInputs = [ jdk mill verilator gcc ];
          buildPhase = ''
            export JAVA_HOME="${jdk}"
            nix run .#verilog
          '';
          installPhase = ''
            mkdir -p $out
            cp -r build/* $out/ || true
          '';
        };
      });
}
