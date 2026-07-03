# 使用说明

## 上位机界面

`host_app/qpsk_visualizer.py` 提供三个主要入口：

- `Demo`: 生成一组带轻微相位偏差和噪声的 QPSK 示例点。
- `Load CSV`: 读取 ModelSim 输出的 `qpsk_samples.csv`。
- `Start/Stop`: 从串口实时接收 FPGA 遥测帧。

## 串口参数

```text
波特率: 115200
数据位: 8
停止位: 1
校验: 无
```

## 遥测帧格式

每帧 18 字节：

```text
55 AA
i_tx q_tx i_rx q_rx
total_bits[31:24] ... total_bits[7:0]
error_bits[31:24] ... error_bits[7:0]
0D 0A 00 FF
```

其中 `i_tx/q_tx/i_rx/q_rx` 为有符号 8 位数，上位机显示时放大 16 倍。

## FPGA 链路流程

```text
PRBS7 -> QPSK Mapper -> Channel Model -> Demapper -> BER Counter -> UART Telemetry
```

当前工程是数字基带链路，不包含射频 DAC/ADC。如果后续要接真实 DAC/ADC，可以在 `qpsk_baseband_top.v` 的 I/Q 端口处扩展。
