`timescale 1ns / 100ps 
 
module add_tb; 
 
parameter N_BITS = 2; 
reg[N_BITS-1:0] x;
reg[N_BITS-1:0] y;
 
wire[N_BITS:0] z;
 
add #(.N_BITS(N_BITS)) uut ( .a(x), .b(y), .c(z));
 
initial
begin
#0;  x = 0; y = 0; 
#20; x = 1; y = 2; 
#20; x = 2; y = 3; 
#20; x = 0; y = 3; 
#20; x = 1; y = 2; 
#40;
end
 
initial
begin
$monitor("time = %3d, x=%1b, y=%1b, z=%1b", $time, x, y, z);
end
 
endmodule
