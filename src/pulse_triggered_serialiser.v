module pulse_triggered_serialiser (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        trigger,       // External pulse to start serialization
    input  wire [12:0] data_in,       // 16-bit data to serialize
    output wire        serial_out,    // Serialized bit output
    output wire        valid          // High during first bit
);

    reg [12:0] shift_reg;
    reg [3:0]  bit_cnt;
    reg        sending;
    reg        valid_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 0;
            bit_cnt   <= 0;
            sending   <= 0;
            valid_reg <= 0;
        end else begin
            if (trigger && !sending) begin
                shift_reg <= data_in;
                bit_cnt   <= 0;
                sending   <= 1;
                valid_reg <= 1;
            end else if (sending) begin
                shift_reg <= {shift_reg[11:0], 1'b0};
                bit_cnt   <= bit_cnt + 1;
                valid_reg <= 0;
                if (bit_cnt == 12) begin
                    sending <= 0;
                end
            end else begin
                valid_reg <= 0;
            end
        end
    end

    assign serial_out = shift_reg[12];
    assign valid      = valid_reg;

endmodule

