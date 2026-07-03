module zhengtu_pro_qpsk_top (
    input  wire       sys_clk,
    input  wire       reset_n,
    input  wire       key1,
    input  wire       key2,
    output wire       uart_txd,
    output wire [3:0] led
);
    wire [1:0] phase_sel = {~key2, ~key1};

    qpsk_baseband_top #(
        .CLK_HZ(50000000),
        .SYMBOL_HZ(100000)
    ) u_top (
        .clk(sys_clk),
        .rst_n(reset_n),
        .key_phase(phase_sel),
        .sw_noise(8'd0),
        .uart_txd(uart_txd),
        .led(led),
        .dbg_i_tx(),
        .dbg_q_tx(),
        .dbg_i_rx(),
        .dbg_q_rx()
    );
endmodule
