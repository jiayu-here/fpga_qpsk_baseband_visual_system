module symbol_tick #(
    parameter CLK_HZ = 50000000,
    parameter SYMBOL_HZ = 100000
) (
    input  wire clk,
    input  wire rst_n,
    output reg  tick
);
    localparam integer DIVIDER = CLK_HZ / SYMBOL_HZ;
    localparam integer CNT_W = 32;

    reg [CNT_W-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            tick <= 1'b0;
        end else if (cnt == DIVIDER - 1) begin
            cnt <= 0;
            tick <= 1'b1;
        end else begin
            cnt <= cnt + 1'b1;
            tick <= 1'b0;
        end
    end
endmodule
