module qpsk_demapper (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              sym_en,
    input  wire signed [11:0] i_rx,
    input  wire signed [11:0] q_rx,
    output reg  [1:0]        bits
);
    always @* begin
        case ({i_rx[11], q_rx[11]})
            2'b00: bits = 2'b00;
            2'b10: bits = 2'b01;
            2'b11: bits = 2'b11;
            default: bits = 2'b10;
        endcase
    end
endmodule
