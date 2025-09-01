/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ds_comp_adc (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  //uio_in[0] - cap a in
  //uio_in[1] - cap b in
  //uio_in[2] - 
  //uio_in[3] - 
  //uio_in[4] - 
  //uio_in[5] -
  //uio_in[6] - 
  //uio_in[7] - data trig
  // *slowing down means clock dividing on the DSM side

  //uo_out[0] - pdm_a
  //uo_out[1] - pdm_b
  //uo_out[2] - filtered_a
  //uo_out[3] - filtered_b
  //uo_out[4] - filtered_ab_subtr
  //uo_out[5] - valid 1 (filtered_a) 
  //uo_out[6] - valid 2 (filtered_b)
  //uo_out[7] - valid 3 (filtered_ab_subtr)

  // All output pins must be assigned. If not used, assign to 0.
  //assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe = 0;


  // List all unused inputs to prevent warnings
  wire _unused = &{ena,uio_oe,uio_in,uio_out,ui_in[6:2],uo_out[7:6], 1'b0};

    // -- DS comparator based ADC
    // Internal signals
    reg       ff_a;
    reg       ff_b;
    // Assign output enable for channels A and B
    assign uio_oe  = 8'b00000000;

    always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
	        ff_a <= 1;  // Start with high to charge capacitor
	        ff_b <= 1;
	   end else begin
	        // Flip-flop stage
	        ff_a <= ui_in[0];
	        ff_b <= ui_in[1];
	    end
    end

    // Inverter after flip-flop
    wire pdm_a = ~ff_a;
    wire pdm_b = ~ff_b;

    // Assign PDM outputs
    assign uo_out[0] = pdm_a;
    assign uo_out[1] = pdm_b;


    // Declare wires for filtered outputs
    wire [12:0] filtered_a;
    wire [12:0] filtered_b;
    // To choose polarity, connect the reference and probing cap to proper inputs
    wire [12:0] filtered_b_substr = filtered_a - filtered_b;

    // Instantiate CIC filter for channel A for 11bit (out of 12 bit because it is bipolar)
    cic_filter_generic #(
        .STAGES(4),
        .WIDTH(13),
	.DECIMATION(4)
    ) cic_a (
        .clk(clk),
        .rst_n(rst_n),
        .pdm_in(ff_a),
        .filtered_out(filtered_a)
    );

    // Instantiate CIC filter for channel A
    cic_filter_generic #(
        .STAGES(4),
        .WIDTH(13),
	.DECIMATION(4)
    ) cic_b (
        .clk(clk),
        .rst_n(rst_n),
        .pdm_in(ff_b),
        .filtered_out(filtered_b)
    );



pulse_triggered_serialiser serializer_a (
    .clk(clk),
    .rst_n(rst_n),
    .trigger(ui_in[7]),       // External pulse to start serialization
    .data_in(filtered_a),     // 16-bit filtered data
    .serial_out(uo_out[2]),   // Serialized bit output
    .valid(uo_out[5])         // Valid signal during first bit
);


pulse_triggered_serialiser serializer_b (
    .clk(clk),
    .rst_n(rst_n),
    .trigger(ui_in[7]),       // External pulse to start serialization
    .data_in(filtered_b),     // 16-bit filtered data
    .serial_out(uo_out[3]),   // Serialized bit output
    .valid(uo_out[6])         // Valid signal during first bit
);


pulse_triggered_serialiser serializer_ab_subtr (
    .clk(clk),
    .rst_n(rst_n),
    .trigger(ui_in[7]),       // External pulse to start serialization
    .data_in(filtered_b_substr),     // 16-bit filtered data
    .serial_out(uo_out[4]),   // Serialized bit output
    .valid(uo_out[7])         // Valid signal during first bit
);



endmodule
