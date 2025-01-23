module main
#(
	parameter MAN = 23,
	parameter EXP = 8
)
(
	input  signed [MAN-1:0] in1, in2,
	output signed [MAN+EXP:0] out_m, out_s
);

wire [MAN + EXP:0] in1_float, in2_float, outm_float, outs_float;

int2float i2f1(in1, in1_float);
int2float i2f2(in2, in2_float);

mult mult(in1_float, in2_float, outm_float);

soma soma(in1_float, in2_float, outs_float);

float2int f2i1(outm_float, out_m);

float2int f2i2(outs_float, out_s);

endmodule
