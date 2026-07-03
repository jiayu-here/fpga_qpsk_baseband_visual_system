module prbs7 #(
    parameter INIT = 7'h5a
) (
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    output reg  bit_out
);
    reg [6:0] lfsr;
    wire feedback = lfsr[6] ^ lfsr[5];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= INIT;
            bit_out <= 1'b0;
        end else if (en) begin
            bit_out <= lfsr[0];
            lfsr <= {lfsr[5:0], feedback};
        end
    end
endmodule
