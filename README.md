# 基于 FPGA 的 QPSK 数字基带通信链路与上位机可视化系统

本工程面向野火征途 Pro / Cyclone IV E `EP4CE10F17C8` 开发板，实现一个可综合、可仿真、可上位机显示的 QPSK 数字基带通信链路。项目覆盖 FPGA RTL、ModelSim 仿真、Quartus 工程和 Python 可视化上位机，适合作为数字通信、FPGA 实现和软硬件联调的综合实践项目。

## 项目亮点

- 完整 QPSK 基带链路：比特源、映射、信道模型、判决解调和 BER 统计。
- 支持相位旋转信道模型，可通过按键选择 `0/90/180/270` 度。
- 支持 UART 遥测输出，将发射点、接收点、总比特数和误码数发送到上位机。
- Python 上位机支持星座图、I/Q 波形和 BER 显示。
- ModelSim 仿真可生成 `sim/qpsk_samples.csv`，便于脱离硬件验证算法链路。
- 已包含 Quartus 工程与板级约束，面向实际 FPGA 下载运行。

## 实现功能

- FPGA 端 PRBS7 伪随机比特源。
- QPSK Gray 映射：`00, 01, 11, 10` 四象限。
- 可调相位旋转信道模型。
- 可调噪声模型接口：RTL 支持 `sw_noise`，当前板级顶层默认设为 0。
- QPSK 硬判决解调。
- BER 误码统计。
- UART 遥测输出。
- Python 上位机可视化。
- ModelSim 仿真与 CSV 数据导出。
- Quartus 工程，目标器件为 `EP4CE10F17C8`。

## 目录结构

```text
rtl/        FPGA Verilog 源码
tb/         ModelSim 测试平台
sim/        ModelSim 一键仿真脚本
quartus/    Quartus 工程、约束和编译脚本
host_app/   Python 上位机可视化程序
docs/       使用说明、硬件接线、测试说明
tools/      工程打包脚本
```

## 快速使用

### 1. 运行仿真

```bat
sim/run_msim.bat
```

仿真结束后会生成：

```text
sim/qpsk_samples.csv
```

### 2. 查看仿真数据

```bat
host_app/run_visualizer.bat
```

打开上位机后点击 `Load CSV`，选择 `sim/qpsk_samples.csv`。

### 3. Quartus 编译

```bat
quartus/run_compile_web.bat
```

### 4. 下载到 FPGA

```bat
quartus/program_sof.bat
```

默认使用板载 CH340 USB 转串口，`uart_txd` 绑定到 `PIN_N5`。

## 当前硬件说明

```text
sys_clk    PIN_E1
reset_n    PIN_M15
key1       PIN_M2
key2       PIN_M1
led[0]     PIN_L7
led[1]     PIN_M6
led[2]     PIN_P3
led[3]     PIN_N3
uart_txd   PIN_N5，连接板载 CH340 USB 转串口
```

如果上位机收不到数据，优先检查 CH340 跳帽；若仍无数据，可尝试把 `uart_txd` 改绑到 `PIN_N6` 后重新编译。规格书中 CH340 表格有一处疑似把 TX/RX 都写成 RX，因此这里保留这个备用处理。

## 软件要求

- Quartus II 13.0sp1 Web Edition
- ModelSim-Altera Starter Edition
- Python 3
- 串口实时显示需要额外安装 `pyserial`

```bat
python -m pip install pyserial
```

仿真 CSV 显示不需要 `pyserial`，只用 Python 自带的 `tkinter`。

## 适用场景

- FPGA 数字通信课程设计。
- QPSK 调制解调链路学习。
- RTL 仿真、板级验证和上位机可视化联调。
- 误码率统计和星座图显示实验。

## 交付状态

本工程已完成 RTL、仿真脚本、Quartus 工程和上位机程序。实际下载板卡前，需要根据实物连接确认 UART 管脚和 CH340 跳帽状态。
