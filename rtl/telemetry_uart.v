module telemetry_uart #(
    parameter CLK_HZ = 50000000,
    parameter BAUD = 115200
) (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              sym_en,
    input  wire signed [11:0] i_tx,
    input  wire signed [11:0] q_tx,
    input  wire signed [11:0] i_rx,
    input  wire signed [11:0] q_rx,
    input  wire [31:0]       total_bits,
    input  wire [31:0]       error_bits,
    output wire              uart_txd
);
    localparam FRAME_BYTES = 18;

    reg [7:0] frame [0:FRAME_BYTES-1];
    reg [7:0] byte_idx;
    reg [9:0] sample_div;
    reg send_req;
    wire busy;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_uart (
        .clk(clk), .rst_n(rst_n), .send(send_req), .data(frame[byte_idx]),
        .tx(uart_txd), .busy(busy)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_div <= 10'd0;
        end else if (sym_en) begin
            sample_div <= sample_div + 1'b1;
        end
    end

    reg active;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active <= 1'b0;
            byte_idx <= 8'd0;
            send_req <= 1'b0;
        end else begin
            send_req <= 1'b0;
            if (sym_en && sample_div == 10'd0 && !active) begin
                frame[0]  <= 8'h55;
                frame[1]  <= 8'haa;
                frame[2]  <= i_tx[11:4];
                frame[3]  <= q_tx[11:4];
                frame[4]  <= i_rx[11:4];
                frame[5]  <= q_rx[11:4];
                frame[6]  <= total_bits[31:24];
                frame[7]  <= total_bits[23:16];
                frame[8]  <= total_bits[15:8];
                frame[9]  <= total_bits[7:0];
                frame[10] <= error_bits[31:24];
                frame[11] <= error_bits[23:16];
                frame[12] <= error_bits[15:8];
                frame[13] <= error_bits[7:0];
                frame[14] <= 8'h0d;
                frame[15] <= 8'h0a;
                frame[16] <= 8'h00;
                frame[17] <= 8'hff;
                byte_idx <= 8'd0;
                active <= 1'b1;
            end else if (active && !busy) begin
                send_req <= 1'b1;
                if (byte_idx == FRAME_BYTES - 1) begin
                    active <= 1'b0;
                end else begin
                    byte_idx <= byte_idx + 1'b1;
                end
            end
        end
    end
endmodule
