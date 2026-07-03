module ber_counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sym_en,
    input  wire [1:0] tx_bits,
    input  wire [1:0] rx_bits,
    output reg  [31:0] total_bits,
    output reg  [31:0] error_bits
);
    wire [1:0] diff = tx_bits ^ rx_bits;
    wire [1:0] err_count = diff[0] + diff[1];

    always @(posedge clk) begin
        if (!rst_n) begin
            total_bits <= 32'd0;
            error_bits <= 32'd0;
        end else if (sym_en) begin
            total_bits <= total_bits + 32'd2;
            error_bits <= error_bits + err_count;
        end else begin
            total_bits <= total_bits;
            error_bits <= error_bits;
        end
    end
endmodule
