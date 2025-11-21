module countones
  #(parameter width_p = 5)
  (input [width_p-1:0] a_i
  ,output [$clog2(width_p)-1:0] sum_o);

  logic [$clog2(width_p)-1:0] result_l;
  always_comb begin
     result_l = '0;
     for(int [31:0] i = 0; i < 31; i++) begin
        result_l += {4'b0, data_i[i]};
     end
  end
  assign sum_o = result_l;

endmodule
