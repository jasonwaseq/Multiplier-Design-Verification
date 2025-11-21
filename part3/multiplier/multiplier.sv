module multiplier
  #(
   // This is here to help, but we won't change it.
   parameter width_p = 16
   )
  (input [width_p - 1:0] a_i
  ,input [width_p - 1:0] b_i
  ,output [(2 * width_p) - 1:0] c_o 
  );

  wire [(2*width_p)-1:0] partial [0:width_p-1];

  genvar i;
  generate
    for (i = 0; i < width_p; i = i + 1) begin : gen_partial
      assign partial[i] = b_i[i] ? (a_i << i) : 0;
    end
  endgenerate

  wire [(2*width_p)-1:0] sum [0:width_p-1];

  assign sum[0] = partial[0];
  generate
    for (i = 1; i < width_p; i = i + 1) begin : gen_sum
      assign sum[i] = sum[i-1] + partial[i];
    end
  endgenerate

  assign c_o = sum[width_p-1];

endmodule