module uart_tx #(
    parameter CLK_HZ = 50000000,
    parameter BAUD = 115200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       send,
    input  wire [7:0] data,
    output reg        tx,
    output reg        busy
);
    localparam integer BAUD_DIV = CLK_HZ / BAUD;
    reg [15:0] baud_cnt;
    reg [3:0] bit_cnt;
    reg [9:0] shifter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 1'b1;
            busy <= 1'b0;
            baud_cnt <= 16'd0;
            bit_cnt <= 4'd0;
            shifter <= 10'h3ff;
        end else if (send && !busy) begin
            shifter <= {1'b1, data, 1'b0};
            busy <= 1'b1;
            baud_cnt <= 16'd0;
            bit_cnt <= 4'd0;
        end else if (busy) begin
            if (baud_cnt == BAUD_DIV - 1) begin
                baud_cnt <= 16'd0;
                tx <= shifter[0];
                shifter <= {1'b1, shifter[9:1]};
                if (bit_cnt == 4'd9) begin
                    busy <= 1'b0;
                    tx <= 1'b1;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end else begin
                baud_cnt <= baud_cnt + 1'b1;
            end
        end
    end
endmodule
