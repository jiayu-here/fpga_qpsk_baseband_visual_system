module qpsk_mapper #(
    parameter AMP = 12'sd1024
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sym_en,
    input  wire [1:0] bits,
    output reg signed [11:0] i_out,
    output reg signed [11:0] q_out
);
    always @* begin
        case (bits)
            2'b00: begin i_out =  AMP; q_out =  AMP; end
            2'b01: begin i_out = -AMP; q_out =  AMP; end
            2'b11: begin i_out = -AMP; q_out = -AMP; end
            default: begin i_out =  AMP; q_out = -AMP; end
        endcase
    end
endmodule
