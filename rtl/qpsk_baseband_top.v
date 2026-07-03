module qpsk_baseband_top #(
    parameter CLK_HZ = 50000000,
    parameter SYMBOL_HZ = 100000
) (
    input  wire clk,
    input  wire rst_n,
    input  wire [1:0] key_phase,
    input  wire [7:0] sw_noise,
    output wire uart_txd,
    output wire [3:0] led,
    output wire signed [11:0] dbg_i_tx,
    output wire signed [11:0] dbg_q_tx,
    output wire signed [11:0] dbg_i_rx,
    output wire signed [11:0] dbg_q_rx
);
    wire sym_en;
    wire prbs_a;
    wire prbs_b;
    wire [1:0] tx_bits = {prbs_a, prbs_b};
    wire [1:0] rx_bits;
    wire [31:0] total_bits;
    wire [31:0] error_bits;

    symbol_tick #(.CLK_HZ(CLK_HZ), .SYMBOL_HZ(SYMBOL_HZ)) u_tick (
        .clk(clk), .rst_n(rst_n), .tick(sym_en)
    );

    prbs7 #(.INIT(7'h5a)) u_prbs_a (.clk(clk), .rst_n(rst_n), .en(sym_en), .bit_out(prbs_a));
    prbs7 #(.INIT(7'h3d)) u_prbs_b (.clk(clk), .rst_n(rst_n), .en(sym_en), .bit_out(prbs_b));

    qpsk_mapper u_mapper (
        .clk(clk), .rst_n(rst_n), .sym_en(sym_en), .bits(tx_bits),
        .i_out(dbg_i_tx), .q_out(dbg_q_tx)
    );

    qpsk_channel_model u_channel (
        .clk(clk), .rst_n(rst_n), .sym_en(sym_en),
        .i_tx(dbg_i_tx), .q_tx(dbg_q_tx),
        .phase_sel(key_phase), .noise_level(sw_noise),
        .i_rx(dbg_i_rx), .q_rx(dbg_q_rx)
    );

    qpsk_demapper u_demapper (
        .clk(clk), .rst_n(rst_n), .sym_en(sym_en),
        .i_rx(dbg_i_rx), .q_rx(dbg_q_rx), .bits(rx_bits)
    );

    ber_counter u_ber (
        .clk(clk), .rst_n(rst_n), .sym_en(sym_en),
        .tx_bits(tx_bits), .rx_bits(rx_bits),
        .total_bits(total_bits), .error_bits(error_bits)
    );

    telemetry_uart #(.CLK_HZ(CLK_HZ), .BAUD(115200)) u_telemetry (
        .clk(clk), .rst_n(rst_n), .sym_en(sym_en),
        .i_tx(dbg_i_tx), .q_tx(dbg_q_tx), .i_rx(dbg_i_rx), .q_rx(dbg_q_rx),
        .total_bits(total_bits), .error_bits(error_bits), .uart_txd(uart_txd)
    );

    assign led[0] = sym_en;
    assign led[1] = |error_bits;
    assign led[2] = total_bits[20];
    assign led[3] = uart_txd;
endmodule
