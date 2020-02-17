/*  
testbench for convert.v
Copyright (C) 2019  Andrew Martens

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

`timescale 1ns / 100ps 

module test #(
  parameter N_BITS_IN = 4,
  parameter BIN_PT_IN = 4,
  parameter N_BITS_OUT = 4,
  parameter BIN_PT_OUT = 4
)(
  input[N_BITS_IN-1:0] din,
  input[N_BITS_OUT-1:0] expected,
  output[N_BITS_OUT-1:0] dout
); 
  convert #(
    .N_BITS_IN(N_BITS_IN), .BIN_PT_IN(BIN_PT_IN),
    .N_BITS_OUT(N_BITS_OUT), .BIN_PT_OUT(BIN_PT_OUT)
  ) uut (.din(din), .dout(dout));

  always @* begin
    if (dout !== expected) begin
      $display("ERROR: N_BITS_IN: %d BIN_PT_IN: %d N_BITS_OUT: %d BIN_PT_OUT: %d", N_BITS_IN, BIN_PT_IN, N_BITS_OUT, BIN_PT_OUT);
      $display("%g: din = %1bb, dout = %1bb, expected = %1bb", $time, din, dout, expected); 
    end
  end
endmodule /*test*/

module convert_tb;

/* a */
/*
  a. The output value space lies totally above the input value space
  Output value: padding
  input value:  MSB            |abcd|      LSB
  output value: MSB      |pppp|            LSB
*/
/* 
  2^  4 3 2 1 0,-1 -2 -3 -4
  IN             a  b  c  d
  OUT e f g h
*/
reg[4-1:0] din_a0 = 0;
wire[4-1:0] dout_a0;
reg[4-1:0] expected_a0 = 0;
 
test #(
  .N_BITS_IN(4), .BIN_PT_IN(4), .N_BITS_OUT(4), .BIN_PT_OUT(-1)
) uut_a0 (.din(din_a0), .dout(dout_a0), .expected(expected_a0));

initial
begin
#0;  din_a0      = 4'b1100; //0.75 
     expected_a0 = 4'b0000; //0
end /*initial*/

/* b */
/*
  b. The output value space lies above, but adjacent to the input value space
  Output value: padding, rounding, sign extension
  input value:  MSB            |abcd|      LSB
  output value: MSB       |ppppr|          LSB
*/
/*
 2^  4 3 2 1 0,-1 -2 -3 -4
 IN             a  b  c  d
 OUT   e f g h
*/
reg[4-1:0] din_b0 = 0;
wire[4-1:0] dout_b0;
reg[4-1:0] expected_b0 = 0;

test #(
  .N_BITS_IN(4), .BIN_PT_IN(4), .N_BITS_OUT(4), .BIN_PT_OUT(0)
) uut_b (.din(din_b0), .dout(dout_b0), .expected(expected_b0));

initial
begin
#0;  din_b0 =       4'b0100;      //0.25 
     expected_b0 =  4'b0000;
/*TODO rounding */ 
/*TODO sign extension */
end /*initial*/

endmodule /*convert_tb*/
