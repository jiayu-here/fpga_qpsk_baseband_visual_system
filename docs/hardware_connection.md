# 硬件接线说明

## FPGA 开发板

目标板卡：野火征途 Pro，Cyclone IV E `EP4CE10F17C8`。

## USB-TTL 串口连接

优先使用板载 CH340 USB 转串口，不需要外接 USB-TTL 模块。

连接方式：

```text
FPGA uart_txd -> 板载 CH340 RXD
PC            -> Type-C/USB 串口
```

本工程暂不使用 PC 到 FPGA 的串口下行控制，因此只需要 FPGA 向 PC 发数据。

注意：

- 按规格书要求接好 CH340 跳帽。
- 默认 `uart_txd` 绑定到 `PIN_N5`。
- 如果 PC 端没有数据，把 `uart_txd` 改到 `PIN_N6` 后重新编译。

## 板载按键

- `key1/key2` 控制信道相位旋转。
- 默认按键为低有效，因此顶层中使用 `~key1` 和 `~key2`。

## 板载 LED

- `led[0]`: 符号时钟活动指示。
- `led[1]`: 检测到误码后点亮。
- `led[2]`: 运行计数指示。
- `led[3]`: UART TX 活动指示。
