transcript on
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vlog ../rtl/prbs7.v
vlog ../rtl/symbol_tick.v
vlog ../rtl/qpsk_mapper.v
vlog ../rtl/qpsk_channel_model.v
vlog ../rtl/qpsk_demapper.v
vlog ../rtl/ber_counter.v
vlog ../rtl/uart_tx.v
vlog ../rtl/telemetry_uart.v
vlog ../rtl/qpsk_baseband_top.v
vlog ../tb/tb_qpsk_baseband_top.v
vsim -c work.tb_qpsk_baseband_top
run -all
quit -f
