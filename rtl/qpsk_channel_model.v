module qpsk_channel_model (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              sym_en,
    input  wire signed [11:0] i_tx,
    input  wire signed [11:0] q_tx,
    input  wire [1:0]        phase_sel,
    input  wire [7:0]        noise_level,
    output reg  signed [11:0] i_rx,
    output reg  signed [11:0] q_rx
);
    reg [7:0] noise_lfsr;
    wire signed [8:0] noise_i = {1'b0, noise_lfsr} - 9'sd128;
    wire signed [8:0] noise_q = {1'b0, {noise_lfsr[3:0], noise_lfsr[7:4]}} - 9'sd128;
    wire signed [19:0] scaled_i = noise_i * $signed({1'b0, noise_level});
    wire signed [19:0] scaled_q = noise_q * $signed({1'b0, noise_level});

    reg signed [11:0] rot_i;
    reg signed [11:0] rot_q;

    always @* begin
        case (phase_sel)
            2'd1: begin rot_i = -q_tx; rot_q =  i_tx; end
            2'd2: begin rot_i = -i_tx; rot_q = -q_tx; end
            2'd3: begin rot_i =  q_tx; rot_q = -i_tx; end
            default: begin rot_i = i_tx; rot_q = q_tx; end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            noise_lfsr <= 8'hac;
        end else if (sym_en) begin
            noise_lfsr <= {noise_lfsr[6:0], noise_lfsr[7] ^ noise_lfsr[5] ^ noise_lfsr[4] ^ noise_lfsr[3]};
        end
    end

    always @* begin
        i_rx = rot_i + scaled_i[15:4];
        q_rx = rot_q + scaled_q[15:4];
    end
endmodule
