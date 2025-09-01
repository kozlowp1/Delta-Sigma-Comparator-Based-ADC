`timescale 1ns / 1ps

module project_tb;

  // Testbench signals
  reg clk;
  reg rst_n;
  reg [7:0] ui_in;
  wire [7:0] uo_out;
  reg [7:0] uio_in;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Declare cycle counter outside the initial block
  integer cycle_count;

  // Instantiate the DUT
  tt_um_ds_comp_adc tt_um_ds_comp_adc (
    .clk(clk),
    .rst_n(rst_n),
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(1'b1)
  );

  // Clock generation: 100 MHz (10 ns period)
  initial clk = 0;
  always #5 clk = ~clk;

  // Stimulus generation
  initial begin
    rst_n = 0;
    ui_in = 8'b0;
    uio_in = 8'b0;
    cycle_count = 0;

    #20 rst_n = 1;

    // Run for 200 clock cycles
    repeat (5000) begin
      @(posedge clk);
      cycle_count = cycle_count + 1;

      // ui_in[0] = 50% duty cycle (toggle every clock)
      ui_in[0] = ~ui_in[0];

      // ui_in[1] = 25% duty cycle (1 high, 3 low)
      if (cycle_count % 10 == 1)
        ui_in[1] = 1'b1;
      else
        ui_in[1] = 1'b0;


      // ui_in[3] = pulse every 16 cycles
      ui_in[7] = (cycle_count % 17 == 0) ? 1'b1 : 1'b0;
    end

    $finish;
  end

endmodule
