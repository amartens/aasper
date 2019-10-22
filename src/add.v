/*
author:       Andrew Martens
license:      GPL3
description:  add two inputs
*/
module add #(
  parameter N_BITS = 8
)(
  input [N_BITS-1:0] a, 
  input [N_BITS-1:0] b, 
  output [N_BITS:0] c
); 
  wire [N_BITS:0] carry; 

  assign carry[0] = 1'b0;

  genvar n;
  generate
  for(n=0; n<N_BITS; n=n+1) begin:bits
    assign c[n] = a[n]^b[n]^carry[n];
    assign carry[n+1] = a[n]&b[n] | a[n]&carry[n] | b[n]&carry[n];
  end
  endgenerate
  
  assign c[N_BITS] = carry[N_BITS]; 
endmodule /*add*/
