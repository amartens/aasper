#run various testbenches
SYN := iverilog
SIM := vvp

tests : convert_tb

convert_tb : convert_tb.o
	$(SIM) convert_tb.o  

convert_tb.o : convert_tb.v ../src/convert.v
	iverilog -o convert_tb.o ../src/convert.v convert_tb.v

clean:
	rm *.o
