`include "axis_image_vip_config.svh"

module bench;
  parameter CLOCK_PERIOD = `CLOCK_PERIOD;
  parameter RESET_DELAY =  `RESET_DELAY;
  parameter RESET_DURATION =  `RESET_DURATION;

  reg clk;
  reg rstn;
  always #(CLOCK_PERIOD/2.0) begin
    clk = ~clk;
  end

  initial
  begin
`ifdef DUMP_VCD_PATH
    $dumpfile(`DUMP_VCD_PATH);
    $dumpvars(0, TFX);
`endif
`ifdef DUMP_SHM_PATH
    $shm_open(`DUMP_SHM_PATH);
    $shm_probe(tb_top.TFX, "ASCM");
`endif
`ifdef DUMP_FSDB_PATH
    $fsdbDumpfile(`DUMP_FSDB_PATH);
    $fsdbDumpvars();
`endif

    clk = 1'b0;
    rstn = 1'b1;
    #(CLOCK_PERIOD * RESET_DELAY) rstn = 1'b0;
    #(CLOCK_PERIOD * RESET_DURATION) rstn = 1'b1;

  end

  logic [`SOURCE_BYTES*8-1:0]  axis_m_source_data;
  logic                        axis_m_source_valid;
  logic                        axis_m_source_ready;
  logic                        axis_m_source_last;

  logic [`SINK_BYTES*8-1:0]    axis_s_sink_data;
  logic                        axis_s_sink_valid;
  logic                        axis_s_sink_ready;
  logic                        axis_s_sink_last;

  axis_image_vip #(
    .INPUT_BYTES(`SOURCE_BYTES),
    .OUTPUT_BYTES(`SINK_BYTES)
  )DUT(
    .axis_s_data_i (axis_s_sink_data),
    .axis_s_valid_i(axis_s_sink_valid),
    .axis_s_ready_o(axis_s_sink_ready),
    .axis_s_last_i (axis_s_sink_last),
    .axis_m_data_o (axis_m_source_data),
    .axis_m_valid_o(axis_m_source_valid),
    .axis_m_ready_i(axis_m_source_ready),
    .axis_m_last_o (axis_m_source_last),
    .clk_i(clk),
    .rstn_i(rstn)
  );

  pipelined_reg #(
    .INPUT_BYTES(`SOURCE_BYTES),
    .OUTPUT_BYTES(`SINK_BYTES)
  )PIPE_REG(
    .axis_s_data_i (axis_m_source_data),
    .axis_s_valid_i(axis_m_source_valid),
    .axis_s_ready_o(axis_m_source_ready),
    .axis_s_last_i (axis_m_source_last),
    .axis_m_data_o (axis_s_sink_data),
    .axis_m_valid_o(axis_s_sink_valid),
    .axis_m_ready_i(axis_s_sink_ready),
    .axis_m_last_o (axis_s_sink_last),
    .clk_i(clk),
    .rstn_i(rstn)
  );

endmodule
