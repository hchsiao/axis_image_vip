module strm_proc_wrapper #(
)(
  input  [7:0] axis_m_data,
  input        axis_m_valid,
  output       axis_m_ready,
  input        axis_m_last,

  output [7:0] axis_s_data,
  output       axis_s_valid,
  input        axis_s_ready,
  output       axis_s_last,

  input        clk,
  input        rst_n
);

  assign axis_s_data  = axis_m_data;
  assign axis_s_valid = axis_m_valid;
  assign axis_m_ready = axis_s_ready;
  assign axis_s_last  = axis_m_last;

endmodule
