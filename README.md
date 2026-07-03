# 基于 FPGA 的 QPSK 数字基带通信链路与上位机可视化系统

本工程面向野火征途 Pro / Cyclone IV E `EP4CE10F17C8` 开发板，完成一个可综合、可仿真、可上位机显示的 QPSK 数字基带链路。

## 实现功能

- FPGA 端 PRBS7 伪随机比特源。
- QPSK Gray 映射：`00, 01, 11, 10` 四象限。
- 可调相位旋转信道模型：按键选择 `0/90/180/270` 度。
- 可调噪声模型接口：RTL 支持 `sw_noise`，当前板级顶层默认设为 0。
- QPSK 硬判决解调。
- BER 误码统计。
- UART 遥测输出：发送 `I/Q` 发射点、接收点、总比特数、误码数。
- Python 上位机：星座图、I/Q 波形、BER 显示。
- ModelSim 仿真：生成 `sim/qpsk_samples.csv`，可直接导入上位机。
- Quartus 工程：目标器件为 `EP4CE10F17C8`。

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

1. 仿真：
   运行 `sim/run_msim.bat`，生成 `sim/qpsk_samples.csv`。

2. 上位机查看仿真数据：
   运行 `host_app/run_visualizer.bat`，点击 `Load CSV`，选择 `sim/qpsk_samples.csv`。

3. Quartus 编译：
   运行 `quartus/run_compile_web.bat`。

4. 下载到 FPGA：
   运行 `quartus/program_sof.bat`。默认使用板载 CH340 USB 转串口，`uart_txd` 绑定到 `PIN_N5`。

## 当前硬件说明

已固定绑定：

- `sys_clk`: PIN_E1
- `reset_n`: PIN_M15
- `key1`: PIN_M2
- `key2`: PIN_M1
- `led[0]`: PIN_L7
- `led[1]`: PIN_M6
- `led[2]`: PIN_P3
- `led[3]`: PIN_N3

- `uart_txd`: PIN_N5，连接板载 CH340 USB 转串口。

如果上位机收不到数据，优先检查 CH340 跳帽；若仍无数据，把 `uart_txd` 改绑到 `PIN_N6` 后重新编译。规格书中 CH340 表格有一处疑似把 TX/RX 都写成 RX，因此这里保留这个备用处理。

## 软件要求

- Quartus II 13.0sp1 Web Edition
- ModelSim-Altera Starter Edition
- Python 3
- 串口实时显示需要额外安装 `pyserial`：

```bat
python -m pip install pyserial
```

仿真 CSV 显示不需要 `pyserial`，只用 Python 自带的 `tkinter`。

## 交付状态

本工程已完成 RTL、仿真脚本、Quartus 工程和上位机程序。实际下载板卡前，需要确认并填写 `uart_txd` 的扩展口管脚。
