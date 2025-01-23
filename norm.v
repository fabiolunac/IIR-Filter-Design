// ****************************************************************************
// Circuitos Auxiliares *******************************************************
// ****************************************************************************

// Multiplexador do modulo de normalizacao ------------------------------------

module mymux
#(
	parameter NCOMP = 2,
	parameter NBITS = 8
)
(
	input  [NCOMP-1:0] A, B,
	input  [NBITS-1:0] in1, in2,
	output [NBITS-1:0] out
);

assign out = (A==B) ? in1 : in2;

endmodule

// Circuito de normalizacao ---------------------------------------------------

module norm
#(
	parameter MAN = 23,
	parameter EXP = 8
	
)
(
	input                     sig,
	input  signed [EXP-1  :0] exp,
	input         [MAN-1  :0] man,
	output        [MAN+EXP:0] out
);

wire [EXP-1:0] w [MAN-1:0];

wire        [EXP-1:0] sh    =  w[MAN-2];
wire                  out_s =  sig;
wire signed [EXP-1:0] out_e = (man == {MAN{1'b0}}) ? {1'b1, {EXP-1{1'b0}}} : exp - sh;
wire        [MAN-1:0] out_m =  man << sh;

mymux #(1, EXP)mm1(man[MAN-1], 1'b0, {{EXP-1{1'b0}}, {1'b1}}, {EXP{1'b0}}, w[0]);

genvar i;

generate
	for (i = 1; i < MAN-1; i = i+1) begin : norm
		mymux #(i+1, EXP)mm(man[MAN-1:MAN-1-i], {i+1{1'b0}}, i[EXP-1:0] + {{EXP-1{1'b0}}, {1'b1}}, w[i-1], w[i]);
	end
endgenerate

assign out = {out_s, out_e, out_m};

endmodule