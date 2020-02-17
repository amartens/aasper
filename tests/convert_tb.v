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
  input[4:0] expected_mode, 
  input[N_BITS_OUT-1:0] expected_dout,
  output[N_BITS_OUT-1:0] dout
); 
  wire[4:0] mode;
  convert #(
    .N_BITS_IN(N_BITS_IN), .BIN_PT_IN(BIN_PT_IN),
    .N_BITS_OUT(N_BITS_OUT), .BIN_PT_OUT(BIN_PT_OUT)
  ) uut (.din(din), .mode(mode), .dout(dout));

  always @* begin
    if (expected_mode !== mode) begin
      $display("%g: ERROR: N_BITS_IN: %d BIN_PT_IN: %d N_BITS_OUT: %d BIN_PT_OUT: %d, expected mode = %d, got %d", $time, N_BITS_IN, BIN_PT_IN, N_BITS_OUT, BIN_PT_OUT, mode, expected_mode); 
    end
  end

  always @* begin
    if (dout !== expected_dout) begin
      $display("%g: ERROR: N_BITS_IN: %d BIN_PT_IN: %d N_BITS_OUT: %d BIN_PT_OUT: %d, din = %1bb, dout = %1bb, expected = %1bb", $time, N_BITS_IN, BIN_PT_IN, N_BITS_OUT, BIN_PT_OUT, din, dout, expected_dout);
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
reg[4:0] expected_mode_a0 = 1;
reg[4-1:0] din_a0 = 0;
wire[4-1:0] dout_a0;
reg[4-1:0] expected_dout_a0 = 0;
 
test #(
  .N_BITS_IN(4), .BIN_PT_IN(4), .N_BITS_OUT(4), .BIN_PT_OUT(-1)
) uut_a0 (.din(din_a0), .expected_mode(expected_mode_a0), .dout(dout_a0), .expected_dout(expected_dout_a0));

initial
begin
#0;  
     $display("%g: Start of test case a0", $time);
#5;
     din_a0           = 4'b1100; //0.75 
     expected_dout_a0 = 4'b0000; //0
#5; 
     $display("%g: Test case a0 complete", $time);
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
reg[4:0] expected_mode_b0 = 2;
reg[4-1:0] din_b0 = 0;
wire[4-1:0] dout_b0;
reg[4-1:0] expected_dout_b0 = 0;

test #(
  .N_BITS_IN(4), .BIN_PT_IN(4), .N_BITS_OUT(4), .BIN_PT_OUT(0)
) uut_b (.din(din_b0), .expected_mode(expected_mode_b0), .dout(dout_b0), .expected_dout(expected_dout_b0));

initial
begin
#0;  
     $display("%g: Start of test case b0", $time);
#5;     
     din_b0           = 4'b0100;      //0.25 
     expected_dout_b0 = 4'b0000;
#5; 
     $display("%g: Test case b0 complete", $time);
/*TODO rounding */ 
/*TODO sign extension */
end /*initial*/

/* c */
/*
  c. Part of the output value space is above, but the rest is within
     Output value: padding, partial input value, rounding, sign extension
     input value:  MSB            |abcd|      LSB
     output value: MSB         |pppabr|       LSB
*/
/*
 2^  4 3 2 1 0,-1 -2 -3 -4
 IN        a b  c  d
 OUT   e f g h
*/
reg[4:0] expected_mode_c0 = 3;
reg[4-1:0] din_c0 = 0;
wire[4-1:0] dout_c0;
reg[4-1:0] expected_dout_c0 = 0;

test #(
  .N_BITS_IN(4), .BIN_PT_IN(2), .N_BITS_OUT(4), .BIN_PT_OUT(0)
) uut_c (.din(din_c0), .expected_mode(expected_mode_c0), .dout(dout_c0), .expected_dout(expected_dout_c0));

initial
begin
#0;  
     $display("%g: Start of test case c0", $time);
#5;     
     din_c0           = 4'b0100;      //1.0 
     expected_dout_c0 = 4'b0001;
#5; 
     $display("%g: Test case c0 complete", $time);
/*TODO rounding */ 
/*TODO sign extension */
end /*initial*/

endmodule /*convert_tb*/
