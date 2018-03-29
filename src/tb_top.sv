`include "cfg.svh"

module tb_top;
  parameter CLOCK_PERIOD = `CLOCK_PERIOD;
  parameter RESET_DELAY =  `RESET_DELAY;
  parameter RESET_DURATION =  `RESET_DURATION;
  parameter INPUT_BITS   = `INPUT_BITS;
  parameter OUTPUT_BITS  = `OUTPUT_BITS;

  reg clk;
  reg rstn;
  always #(CLOCK_PERIOD/2.0) begin
    clk = ~clk;
  end

  int in_file, out_file, scan_file;
  initial
  begin
    in_file = $fopen("test_pattern.txt", "r");
    out_file = $fopen("result_pattern.txt", "w");
    if (!in_file || !out_file) begin
      $display("Failed to create file handles");
      $finish();
    end

`ifdef SYN
    $sdf_annotate(`SDF_PATH, AOS_AXIS);
`endif

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

  logic [INPUT_BITS-1:0]  axis_m_data;
  logic                   axis_m_valid;
  logic                   axis_m_ready;
  logic                   axis_m_last;

  logic [OUTPUT_BITS-1:0] axis_s_data;
  logic                   axis_s_valid;
  logic                   axis_s_ready;
  logic                   axis_s_last;

  logic [63:0] data_buff, data_buff_sync;
  logic [63:0] last_buff, last_buff_sync;
  logic        data_valid;
  logic        tb_ready;

  always @(posedge clk or negedge rstn)
  begin
    if (~rstn)
    begin
      data_valid <= 1'b0;
      tb_ready <= 1'b1;
    end
    else
    begin
      if (axis_s_valid)
      begin
        $fwrite(out_file, "out: %d\n", axis_s_data); 
        if (axis_s_last)
        begin
          $fclose(out_file);
          $finish();
        end
      end

      if (tb_ready && axis_m_ready)
        if (in_file && !$feof(in_file))
        begin
          scan_file <= $fscanf(in_file, "%d,%d\n", data_buff, last_buff); 
          data_buff_sync <= data_buff; 
          last_buff_sync <= last_buff; 
          data_valid <= 1'b1;
        end
        else
        begin
          data_valid <= 1'b0;
          $fclose(in_file);
          in_file <= 0;
        end
    end
  end

  axis_fixture TFX
  (
    .axis_m_data_i(axis_m_data),
    .axis_m_valid_i(axis_m_valid),
    .axis_m_ready_o(axis_m_ready),
    .axis_m_last_i(axis_m_last),
    .axis_s_data_o(axis_s_data),
    .axis_s_valid_o(axis_s_valid),
    .axis_s_ready_i(axis_s_ready),
    .axis_s_last_o(axis_s_last),
    .clk_i(clk),
    .rstn_i(rstn)
  );

  assign axis_m_valid = data_valid;
  assign axis_m_data  = data_buff_sync[INPUT_BITS-1:0];
  assign axis_m_last  = (last_buff_sync > 0);
  assign axis_s_ready = rstn && tb_ready;

endmodule
