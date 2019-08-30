/*
copyright:    Andrew Martens 2019
license:      GPL3
description:  convert between bit widths
*/
module convert #(
  parameter N_BITS_IN = 8,
  parameter BIN_PT_IN = 7,
  parameter N_BITS_OUT = 4,
  parameter BIN_PT_OUT = 3
)(
  input [N_BITS_IN-1:0] din, 
  output [N_BITS_OUT-1:0] dout
);
  
  /*Bits are labelled with their power of two index
    e.g N_BITS_x = 8, BIN_PT_x = 7 then
    MSB_x = 1 and LSB_x = -7
    
    MSB_x can be negative if MSBit is a fractional bit
    e.g N_BITS_IN = 3, BIN_PT_IN = 4 then
    MSB_x = -1 and LSB_x = -3
  */
  
  localparam MSB_IN  = N_BITS_IN-BIN_PT_IN-1;
  localparam LSB_IN  = -BIN_PT_IN;
  localparam MSB_OUT = N_BITS_OUT-BIN_PT_OUT-1;
  localparam LSB_OUT = -BIN_PT_OUT;

  /*
    There are many possible scenarios when converting between bit widths
    a. The output value space lies totally above the input value space
       Output value: padding
       input value:  MSB            |abcd|      LSB
       output value: MSB      |pppp|            LSB
         
    b. The output value space lies above, but adjacent to the input value space
       Output value: padding, rounding, sign extension
       input value:  MSB            |abcd|      LSB
       output value: MSB       |ppppr|          LSB

    c. Part of the output value space is above, but the rest is within
       Output value: padding, partial input value, rounding, sign extension
       input value:  MSB            |abcd|      LSB
       output value: MSB         |pppabr|       LSB

    d. The output value space is above and includes the input space
       Output value: padding, input value, sign extension
       input value:  MSB            |abcd|      LSB
       output value: MSB         |pppabcd|      LSB
    
    e. The output value space is the same as the input value space
       Output value: input value
       input value:  MSB            |abcd|      LSB
       output value: MSB            |abcd|      LSB
    
    f. The output value space lies within the input word space
       Output value: partial input value, rounding, saturation 
       input value:  MSB            |abcd|      LSB
       output value: MSB            |abr|       LSB
    
    g. The output value space lies within the input word space
       Output value: partial input value, possible saturation
       input value:  MSB            |abcd|      LSB
       output value: MSB            | bcd|      LSB
   
    h. The MSB is within, and LSB below
       Output value: partial input value, padding, saturation
       input value:  MSB            |abcd|      LSB
       output value: MSB             |bcdppp|   LSB

    i. The output word is wholly below the input word
       Output value: padding, possible saturation
       input value:  MSB            |abcd|      LSB
       output value: MSB                  |ppp| LSB
    
    j. The input word is wholly contained within the output word 
       Output value: input value, padding, sign extension
       input value:  MSB            |abcd|      LSB
       output value: MSB          |ppabcdppp|   LSB
  */
  localparam MSBS    = MSB_OUT-MSB_IN;
  localparam LSBS    = LSB_IN-LSB_OUT;

  generate
    /*
    a. The output value space lies totally above the input value space
       Output value: padding
       input value:  MSB            |abcd|      LSB
       output value: MSB      |pppp|            LSB
    */
    if ((MSB_OUT > MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT > MSB_IN) && (LSB_OUT > LSB_IN) && ((LSB_OUT - MSB_IN) > 1)) begin:a
      /*TODO sign extension*/  
      wire[N_BITS_OUT-1:0] padding = {N_BITS_OUT{1'b0}};
      assign dout = {padding};
    end /*a*/
    /*
    b. The output value space lies above, but adjacent to the input value space
       Output value: padding, rounding, sign extension
       input value:  MSB            |abcd|      LSB
       output value: MSB       |ppppr|          LSB
    */
    else if ((MSB_OUT > MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT > MSB_IN) && (LSB_OUT > LSB_IN) && ((LSB_OUT - MSB_IN) == 1)) begin:b
      /*TODO sign extension*/
      /*TODO rounding*/
      wire[N_BITS_OUT-1:0] padding = {N_BITS_OUT{1'b0}};
      assign dout = {padding};
    end /*b*/
    /*
    c. Part of the output value space is above, but the rest is within
       Output value: padding, partial input value, rounding, sign extension
       input value:  MSB            |abcd|      LSB
       output value: MSB         |pppabr|       LSB
    */
    else if ((MSB_OUT > MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT < MSB_IN) && (LSB_OUT > LSB_IN)) begin:c
      /*TODO sign extension*/
      wire [MSB_OUT-MSB_IN-1:0] padding = {(MSB_OUT-MSB_IN){1'b0}};
      wire [MSB_IN-LSB_OUT-1:0] overlap = din[N_BITS_IN-1:LSB_OUT-LSB_IN];
      /*TODO rounding */
      assign dout = {padding,overlap};
    end /*c*/ 
    /* 
    d. The output value space is above and includes the input space
       Output value: padding, input value, sign extension
       input value:  MSB            |abcd|      LSB
       output value: MSB         |pppabcd|      LSB
    */

    else if ((MSB_OUT > MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT < MSB_IN) && (LSB_OUT == LSB_IN)) begin:d
      /*TODO sign extension*/
      wire [MSB_OUT-MSB_IN-1:0] padding = {(MSB_OUT-MSB_IN){1'b0}};
      assign dout = {padding,din};
    end /*d*/
    /* 
    e. The output value space is the same as the input value space
       Output value: input value
       input value:  MSB            |abcd|      LSB
       output value: MSB            |abcd|      LSB
    */
    else if ((MSB_OUT == MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT < MSB_IN) && (LSB_OUT == LSB_IN)) begin:e
      assign dout = din;
    end /*e*/

    /*
    f. The output value space lies within the input word space
       Output value: partial input value, rounding, saturation 
       input value:  MSB            |abcd|      LSB
       output value: MSB            |abr|       LSB
    */
    else if ((MSB_OUT == MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT < MSB_IN) && (LSB_OUT > LSB_IN)) begin:f
      wire[N_BITS_OUT-1:0] overlap = din[N_BITS_IN-1:N_BITS_IN-N_BITS_OUT];
      /*TODO rounding*/
      /*TODO saturation*/
      assign dout = {overlap};
    end /*f*/
    /*
    g. The output value space lies within the input word space
       Output value: partial input value, possible saturation
       input value:  MSB            |abcd|      LSB
       output value: MSB            | bcd|      LSB
    */
    else if ((MSB_OUT < MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT <= MSB_IN) && (LSB_OUT > LSB_IN)) begin:g
      wire[N_BITS_OUT-1:0] overlap = din[N_BITS_IN-(MSB_OUT-MSB_IN):N_BITS_IN-N_BITS_OUT];
      /*TODO rounding*/
      /*TODO saturation*/
      assign dout = {overlap};
    end /*g*/

    /*
    h. The MSB is within, and LSB below
       Output value: partial input value, padding, saturation
       The value may be saturated
       input value:  MSB            |abcd|      LSB
       output value: MSB             |bcdppp|   LSB
    */
    else if ((MSB_OUT < MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT < MSB_IN) && (LSB_OUT < LSB_IN)) begin:h
      wire[LSB_IN-LSB_OUT-1:0] padding = {{LSB_IN-LSB_OUT}{1'b0}};
      wire[N_BITS_IN-(MSB_IN-MSB_OUT)-1:0] overlap = din[N_BITS_IN-(MSB_IN-MSB_OUT)-1:0];
      /*TODO saturate*/
      assign dout = {overlap,padding};
    end /*h*/
    /*
    i. The output word is wholly below the input word
       Output value: padding, possible saturation
       input value:  MSB            |abcd|      LSB
       output value: MSB                  |ppp| LSB
    */
    else if ((MSB_OUT < MSB_IN) && (MSB_OUT < LSB_IN) && (LSB_OUT < MSB_IN) && (LSB_OUT < LSB_IN)) begin:i
    end /*i*/
    /*
    j. The input word is wholly contained within the output word 
       Output value: input value, padding, sign extension
       input value:  MSB            |abcd|      LSB
       output value: MSB          |ppabcdppp|   LSB
    */
    else if ((MSB_OUT > MSB_IN) && (MSB_OUT > LSB_IN) && (LSB_OUT < MSB_IN) && (LSB_OUT < LSB_IN)) begin:j
    end /*j*/
  endgenerate

endmodule /*convert*/
