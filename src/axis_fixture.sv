`include "cfg.svh"

module axis_fixture #(
  parameter INPUT_BITS = `INPUT_BITS,
  parameter OUTPUT_BITS = `OUTPUT_BITS,
  parameter PIPELINE_STAGES = 2
)
(
  input  [INPUT_BITS-1:0]  axis_m_data_i,
  input                    axis_m_valid_i,
  output                   axis_m_ready_o,
  input                    axis_m_last_i,

  output [OUTPUT_BITS-1:0] axis_s_data_o,
  output                   axis_s_valid_o,
  input                    axis_s_ready_i,
  output                   axis_s_last_o,

  input                    clk_i,
  input                    rstn_i
);

  logic [INPUT_BITS-1:0] pipeline_data[PIPELINE_STAGES];
  logic                  pipeline_valid[PIPELINE_STAGES];
  logic                  pipeline_last[PIPELINE_STAGES];

  int i;

  always_ff @(posedge clk_i)
  begin
    if (axis_s_ready_i)
    begin
      pipeline_data[0] <= axis_m_data_i;
      pipeline_valid[0] <= axis_m_valid_i;
      pipeline_last[0] <= axis_m_last_i;
      for (i = 1; i < PIPELINE_STAGES; i = i+1)
      begin
        pipeline_data[i] <= pipeline_data[i-1];
        pipeline_valid[i] <= pipeline_valid[i-1];
        pipeline_last[i] <= pipeline_last[i-1];
      end
    end
  end

  assign axis_s_data_o  = pipeline_data[PIPELINE_STAGES-1];
  assign axis_s_valid_o = pipeline_valid[PIPELINE_STAGES-1];
  assign axis_s_last_o  = pipeline_last[PIPELINE_STAGES-1];
  assign axis_m_ready_o = 1'b1;

endmodule
