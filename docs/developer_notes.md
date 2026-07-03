# 开发说明

## 主要模块

- `prbs7.v`: PRBS7 伪随机序列。
- `symbol_tick.v`: 符号速率使能脉冲。
- `qpsk_mapper.v`: Gray 编码 QPSK 映射。
- `qpsk_channel_model.v`: 数字信道模型，支持相位旋转和伪噪声。
- `qpsk_demapper.v`: 基于 I/Q 符号位的硬判决。
- `ber_counter.v`: 总比特数和误码数统计。
- `telemetry_uart.v`: 按固定帧格式输出遥测数据。
- `qpsk_baseband_top.v`: 通用链路顶层。
- `zhengtu_pro_qpsk_top.v`: 征途 Pro 板级顶层。

## 设计取舍

本版本优先保证可综合、可仿真、可展示。没有引入复杂的 RRC 滤波、载波同步、定时同步和真实 ADC/DAC 接口，因为这些会显著增加调试复杂度，也需要更多外设确认。

后续可扩展方向：

- 加 RRC 成形滤波和匹配滤波。
- 加 Costas 环或四次方环做相位恢复。
- 加 UART 下行命令，动态调节噪声、符号速率和相位。
- 接外部 DAC/ADC，形成真实模拟链路。
