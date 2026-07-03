# 快速开始

## 1. 运行仿真

进入 `sim` 目录，双击或运行：

```bat
run_msim.bat
```

成功后会生成：

```text
sim/qpsk_samples.csv
```

## 2. 打开上位机

进入 `host_app` 目录，运行：

```bat
run_visualizer.bat
```

点击 `Load CSV`，选择 `sim/qpsk_samples.csv`，即可看到星座图和 I/Q 波形。

## 3. 编译 FPGA 工程

进入 `quartus` 目录，运行：

```bat
run_compile_web.bat
```

编译成功后生成：

```text
quartus/output_files/fpga_qpsk_baseband_visual_system.sof
```

## 4. 下载到 FPGA

打开：

```text
quartus/fpga_qpsk_baseband_visual_system.qsf
```

默认使用板载 CH340 USB 转串口：

```text
uart_txd = PIN_N5
```

接好规格书要求的 USB 转串口跳帽后，运行：

```bat
program_sof.bat
```

如果上位机收不到串口数据，把 QSF 里的 `uart_txd` 改为 `PIN_N6` 后重新编译。
