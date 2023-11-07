`timescale 1ps/1ps

module hdmi_pll_xilinx 

 (// Clock in ports
  // Clock out ports
  output logic       clk_out1,
  output logic       clk_out2,
  input logic        clk_in1
 );
  // Input buffering
  //------------------------------------
//wire clk_in1_clk_wiz_0;
logic clk_in2_clk_wiz_0;
//  IBUF clkin1_ibufg
//   (.O (clk_in1_clk_wiz_0),
//    .I (clk_in1));




  // Clocking PRIMITIVE
  //------------------------------------

  // Instantiation of the MMCM PRIMITIVE
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused

  logic        clk_out1_clk_wiz_0;
  logic        clk_out2_clk_wiz_0;
  logic        clk_out3_clk_wiz_0;
  logic        clk_out4_clk_wiz_0;
  logic        clk_out5_clk_wiz_0;
  logic        clk_out6_clk_wiz_0;
  logic        clk_out7_clk_wiz_0;

  logic [15:0] do_unused;
  logic        drdy_unused;
  logic        psdone_unused;
  logic        locked_int;
 logic        clkfbout_clk_wiz_0;
 logic       clkfbout_buf_clk_wiz_0;
  logic        clkfboutb_unused;
    logic clkout0b_unused;
  logic clkout1b_unused;
   logic clkout2_unused;
  logic clkout2b_unused;
   logic clkout3_unused;
   logic clkout3b_unused;
   logic clkout4_unused;
 logic        clkout5_unused;
 logic       clkout6_unused;
  logic        clkfbstopped_unused;
  logic        clkinstopped_unused;

  MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
`ifdef USE_125MHZ
    .DIVCLK_DIVIDE        (7),
    .CLKFBOUT_MULT_F      (62.375),
    .CLKOUT0_DIVIDE_F     (15.000),
    .CLKOUT1_DIVIDE       (3),
    .CLKIN1_PERIOD        (8.000),
`else // USE_100MHZ
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT_F      (37.125),
    .CLKOUT0_DIVIDE_F     (10.000),
    .CLKOUT1_DIVIDE       (2),
    .CLKIN1_PERIOD        (10.000),
`endif
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"))
  mmcm_adv_inst
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_clk_wiz_0),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (clk_out1_clk_wiz_0),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clk_out2_clk_wiz_0),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (clk_in1),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (1'b0));

// Clock Monitor clock assigning
//--------------------------------------
 // Output buffering
  //-----------------------------------

  BUFG clkf_buf
   (.O (clkfbout_buf_clk_wiz_0),
    .I (clkfbout_clk_wiz_0));






  BUFG clkout1_buf
   (.O   (clk_out1),
    .I   (clk_out1_clk_wiz_0));


  BUFG clkout2_buf
   (.O   (clk_out2),
    .I   (clk_out2_clk_wiz_0));



endmodule