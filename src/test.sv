`include "pydpi_gen_params.sv"
`include "pydpi_gen_mod_source.sv"
`include "pydpi_gen_mod_sink.sv"

module test;
  parameter CLK_PERIOD = `CLK_PERIOD;

  reg clk;
  reg rst_n;
  always #(CLK_PERIOD/2.0) begin
    clk = ~clk;
  end

initial begin
`ifdef SYN
    $sdf_annotate(`SDF_PATH, AOS_AXIS);
`endif

`ifdef DUMP_VCD_PATH
    $dumpfile(`DUMP_VCD_PATH);
    $dumpvars();
`endif
`ifdef DUMP_SHM_PATH
    $shm_open(`DUMP_SHM_PATH);
    $shm_probe(test, "ASCM");
`endif
`ifdef DUMP_FSDB_PATH
    $fsdbDumpfile(`DUMP_FSDB_PATH);
    $fsdbDumpvars();
`endif

    clk = 1'b0;
    #(CLK_PERIOD*`RESET_DELAY) rst_n = 1'b0;
    #(CLK_PERIOD*`RESET_DURATION) rst_n = 1'b1;

end

  wire [7:0] axis_m_data;
  wire axis_m_valid;
  wire axis_m_ready;
  wire axis_m_last;

  wire [7:0] axis_s_data;
  wire axis_s_valid;
  wire axis_s_ready;
  wire axis_s_last;

  source #(
  )SRC(
    .data(axis_m_data),
    .valid(axis_m_valid),
    .ready(axis_m_ready),
    .last(axis_m_last),
    .clk(clk),
    .reset(~rst_n)
  );

  assign axis_m_ready = axis_s_ready;
  assign axis_s_data = axis_m_data;
  assign axis_s_valid = axis_m_valid;
  assign axis_s_last = axis_m_last;

  sink #(
  )SINK(
    .data(axis_s_data),
    .valid(axis_s_valid),
    .ready(axis_s_ready),
    .last(axis_s_last),
    .clk(clk),
    .reset(~rst_n)
  );
endmodule
