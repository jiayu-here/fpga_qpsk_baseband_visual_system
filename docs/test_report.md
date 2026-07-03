# 测试报告

## 已设计的验证项目

- ModelSim 行为仿真。
- CSV 样本生成。
- Python 上位机 CSV 可视化。
- Quartus Analysis & Synthesis。
- Quartus Fitter 和 TimeQuest 编译流程。

## 验收标准

- `sim/run_msim.bat` 能正常结束。
- `sim/qpsk_samples.csv` 生成，且包含 I/Q 样本。
- 上位机能打开 CSV 并显示星座点。
- `quartus/run_compile_web.bat` 返回 `compile_exit=0`。
- `quartus/output_files/fpga_qpsk_baseband_visual_system.sof` 生成。

## 当前注意事项

已默认绑定 `uart_txd = PIN_N5`。规格书中 CH340 TX/RX 表格存在一处疑似文字错误；如果 PC 端无串口数据，改为 `PIN_N6` 后重新编译。

## 本机验证结果

验证时间：2026-07-03。

- ModelSim 仿真：通过。
- 仿真输出：`sim/qpsk_samples.csv` 已生成。
- Quartus 全流程编译：通过，`compile_exit=0`。
- 目标器件：`EP4CE10F17C8`。
- 编程文件：`quartus/output_files/fpga_qpsk_baseband_visual_system.sof` 已生成。
- 最差 setup slack：11.216 ns。
- 最差 hold slack：0.452 ns。
- 最差 minimum pulse width slack：9.262 ns。

剩余警告主要来自 Web Edition 并行编译许可、LogicLock 许可、3.3 V IO 提醒和 TimeQuest 未完全约束提示；不影响当前 50 MHz 单时钟演示工程编译生成。
