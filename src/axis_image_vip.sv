module axis_image_vip (
  axis_s_data_i,
  axis_s_valid_i,
  axis_s_ready_o,
  axis_s_last_i,
  axis_s_user_i,
  axis_m_data_o,
  axis_m_valid_o,
  axis_m_ready_i,
  axis_m_last_o,
  axis_m_user_o,
  clk_i,
  rstn_i
);
  import axis_image_vip_config::*;
  parameter INPUT_BITS = SINK_BYTES*8;
  parameter OUTPUT_BITS = SOURCE_BYTES*8;

  input  [INPUT_BITS-1:0]  axis_s_data_i;
  input                    axis_s_valid_i;
  output                   axis_s_ready_o;
  input                    axis_s_last_i;
  input                    axis_s_user_i;

  output [OUTPUT_BITS-1:0] axis_m_data_o;
  output                   axis_m_valid_o;
  input                    axis_m_ready_i;
  output                   axis_m_last_o;
  output                   axis_m_user_o;

  input                    clk_i;
  input                    rstn_i;

  int in_file, out_file, scan_file, file_len, prog_percent;
  initial
  begin
    // count file length
    in_file = $fopen("test_pattern.txt", "r");
    while (!$feof(in_file))
      scan_file = $fgetc(in_file); 
    file_len = $ftell(in_file);
    $fclose(in_file);
    prog_percent = 0;

    // init file handles
    in_file = $fopen("test_pattern.txt", "r");
    out_file = $fopen("result_pattern.txt", "w");
    if (!in_file || !out_file) begin
      $display("Failed to create file handles");
      $finish();
    end
  end

  logic [63:0] data_buff, data_buff_sync;
  logic [63:0] last_buff, last_buff_sync;
  logic [63:0] user_buff, user_buff_sync;
  logic [63:0] stuck_cycle;
  logic        data_valid, pattern_ends;
  logic        tb_ready;

  always @(posedge clk_i or negedge rstn_i)
  begin
    if (~rstn_i)
    begin
      data_valid <= 1'b0;
      pattern_ends <= 1'b0;
      tb_ready <= 1'b1;
      stuck_cycle <= 0;
    end
    else
    begin
      if (axis_s_valid_i)
      begin
        $fwrite(out_file, "data: %d, last: %d, user: %d\n", axis_s_data_i, axis_s_last_i, axis_s_user_i); 
        if (pattern_ends && axis_s_last_i)
        begin
          $fclose(out_file);
          $finish();
        end
      end

      if (tb_ready && axis_m_ready_i)
        if (in_file && !$feof(in_file))
        begin
          scan_file <= $fscanf(in_file, "%d,%d,%d\n", data_buff, last_buff, user_buff); 
          data_buff_sync <= data_buff; 
          last_buff_sync <= last_buff; 
          user_buff_sync <= user_buff; 
          data_valid <= 1'b1;
          if ($ftell(in_file)*100/file_len > prog_percent)
          begin
            $display("Done %d percent", prog_percent);
            prog_percent = $ftell(in_file)*100/file_len;
          end
          if($feof(in_file))
          begin
            pattern_ends <= 1'b1;
            $display("Test pattern ends");
          end
        end
        else
        begin
          if (data_valid)
          begin
            data_valid <= 1'b0;
            $fclose(in_file);
            in_file <= 0;
          end
        end

      if (stuck_cycle >= TIMEOUT_CYCLE)
      begin
        $display("Warning: Timeout of %d cycles reached.", TIMEOUT_CYCLE);
        if(in_file)
          $fclose(in_file);
        $fclose(out_file);
        $finish();
      end
      else if (!axis_m_valid_o || !axis_m_ready_i)
        stuck_cycle <= stuck_cycle + 1;
      else
        stuck_cycle <= 0;
    end
  end

  assign axis_m_valid_o = !pattern_ends && data_valid;
  assign axis_m_data_o  = data_buff_sync[INPUT_BITS-1:0];
  assign axis_m_last_o  = (last_buff_sync > 0);
  assign axis_m_user_o  = (user_buff_sync > 0);
  assign axis_s_ready_o = rstn_i && tb_ready;

endmodule
