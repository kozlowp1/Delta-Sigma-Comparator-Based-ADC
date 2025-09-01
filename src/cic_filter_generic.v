module cic_filter_generic #(
    parameter STAGES = 64,
    parameter WIDTH = 32,
    parameter DECIMATION = 256
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             pdm_in,         // 1-bit PDM input
    output reg  [WIDTH-1:0] filtered_out    // Filtered output
);

    // Integrator stages
    reg [WIDTH-1:0] integrator [0:STAGES-1];

    // Comb stages
    reg [WIDTH-1:0] comb [0:STAGES-1];
    reg [WIDTH-1:0] delay [0:STAGES-1];

    // Temporary variables for comb chain
    reg [WIDTH-1:0] temp_comb [0:STAGES-1];
    reg [WIDTH-1:0] temp_delay [0:STAGES-1];

    // Decimation counter
    reg [7:0] decim_cnt; // Supports up to DECIMATION = 256

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < STAGES; i = i + 1) begin
                integrator[i] <= 0;
                comb[i] <= 0;
                delay[i] <= 0;
                temp_comb[i] <= 0;
                temp_delay[i] <= 0;
            end
            decim_cnt <= 0;
            filtered_out <= 0;
        end else begin
            // Integrator chain
            integrator[0] <= integrator[0] + pdm_in;
            for (i = 1; i < STAGES; i = i + 1) begin
                integrator[i] <= integrator[i] + integrator[i-1];
            end

            // Decimation logic
            if (decim_cnt == DECIMATION - 1) begin
                decim_cnt <= 0;

                // Compute comb chain using temporary variables
                temp_comb[0] = integrator[STAGES-1] - delay[0];
                temp_delay[0] = integrator[STAGES-1];

                for (i = 1; i < STAGES; i = i + 1) begin
                    temp_comb[i] = temp_comb[i-1] - delay[i];
                    temp_delay[i] = temp_comb[i-1];
                end

                // Update comb and delay registers
                for (i = 0; i < STAGES; i = i + 1) begin
                    comb[i] <= temp_comb[i];
                    delay[i] <= temp_delay[i];
                end

                // Output the final comb stage
                filtered_out <= temp_comb[STAGES-1];
            end else begin
                decim_cnt <= decim_cnt + 1;
            end
        end
    end

endmodule