module pipelined_reg (
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
  parameter PIPELINE_STAGES = 2;
  parameter INPUT_BITS = SOURCE_BYTES*8;
  parameter OUTPUT_BITS = SINK_BYTES*8;

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

  logic [INPUT_BITS-1:0] pipeline_data[PIPELINE_STAGES];
  logic                  pipeline_valid[PIPELINE_STAGES];
  logic                  pipeline_last[PIPELINE_STAGES];
  logic                  pipeline_user[PIPELINE_STAGES];

  int i;

  always_ff @(posedge clk_i)
  begin
    if (axis_m_ready_i)
    begin
      pipeline_data[0] <= axis_s_data_i;
      pipeline_valid[0] <= axis_s_valid_i;
      pipeline_last[0] <= axis_s_last_i;
      pipeline_user[0] <= axis_s_user_i;
      for (i = 1; i < PIPELINE_STAGES; i = i+1)
      begin
        pipeline_data[i] <= pipeline_data[i-1];
        pipeline_valid[i] <= pipeline_valid[i-1];
        pipeline_last[i] <= pipeline_last[i-1];
        pipeline_user[i] <= pipeline_user[i-1];
      end
    end
  end

  assign axis_m_data_o  = pipeline_data[PIPELINE_STAGES-1];
  assign axis_m_valid_o = pipeline_valid[PIPELINE_STAGES-1];
  assign axis_m_last_o  = pipeline_last[PIPELINE_STAGES-1];
  assign axis_m_user_o  = pipeline_user[PIPELINE_STAGES-1];
  assign axis_s_ready_o = 1'b1;

endmodule
