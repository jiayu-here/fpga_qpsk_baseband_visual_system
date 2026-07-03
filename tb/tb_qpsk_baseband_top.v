`timescale 1ns/1ps

module tb_qpsk_baseband_top;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg [1:0] key_phase = 2'd0;
    reg [7:0] sw_noise = 8'd0;
    wire uart_txd;
    wire [3:0] led;
    wire signed [11:0] i_tx;
    wire signed [11:0] q_tx;
    wire signed [11:0] i_rx;
    wire signed [11:0] q_rx;

    integer csv;
    integer n;

    always #10 clk = ~clk;

    qpsk_baseband_top #(
        .CLK_HZ(50000000),
        .SYMBOL_HZ(1000000)
    ) dut (
        .clk(clk), .rst_n(rst_n), .key_phase(key_phase), .sw_noise(sw_noise),
        .uart_txd(uart_txd), .led(led),
        .dbg_i_tx(i_tx), .dbg_q_tx(q_tx), .dbg_i_rx(i_rx), .dbg_q_rx(q_rx)
    );

    initial begin
        csv = $fopen("qpsk_samples.csv", "w");
        $fwrite(csv, "n,i_tx,q_tx,i_rx,q_rx\n");
        #200 rst_n = 1'b1;
        for (n = 0; n < 256; n = n + 1) begin
            @(posedge dut.sym_en);
            $fwrite(csv, "%0d,%0d,%0d,%0d,%0d\n", n, i_tx, q_tx, i_rx, q_rx);
        end
        key_phase = 2'd1;
        sw_noise = 8'd8;
        for (n = 256; n < 512; n = n + 1) begin
            @(posedge dut.sym_en);
            $fwrite(csv, "%0d,%0d,%0d,%0d,%0d\n", n, i_tx, q_tx, i_rx, q_rx);
        end
        $fclose(csv);
        $display("QPSK baseband simulation finished.");
        $finish;
    end
endmodule
