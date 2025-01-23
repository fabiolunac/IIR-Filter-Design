// ****************************************************************************
// Circuitos Aritmeticos ******************************************************
// ****************************************************************************

// Multiplicacao em ponto-flutuante -------------------------------------------

module mymult
#(
	parameter EXP = 8,
	parameter MAN = 23
)
(
	input                   s1, s2,
	input  signed [EXP-1:0] e1, e2,
	input         [MAN-1:0] m1, m2,
	output                  s_out,
	output signed [EXP-1:0] e_out,
	output        [MAN-1:0] m_out
);

wire        [2*MAN-1:0] mult = m1 * m2;
wire signed [  EXP  :0] e    = e1 + e2 + MAN; // colocar limite para +inf

assign s_out = (s1 != s2);
wire     unf = (e[EXP:EXP-1] == 2'b10);       // underflow
assign e_out =  e[EXP-1:0];
assign m_out = (unf) ? {{MAN{1'b0}}} : mult[2*MAN-1:MAN];

endmodule

// ****************************************************************************
// Circuito Principal *********************************************************
// ****************************************************************************

module mult
#(
	parameter           EXP = 8,
	parameter [EXP-1:0] MAN = 23
)
(
	input         [MAN+EXP:0] in1, in2,
	output        [MAN+EXP:0] out
);

// desempacota ----------------------------------------------------------------

wire                  s1 = in1[MAN+EXP];
wire                  s2 = in2[MAN+EXP];
wire signed [EXP-1:0] e1 = in1[MAN+EXP-1:MAN];
wire signed [EXP-1:0] e2 = in2[MAN+EXP-1:MAN];
wire signed [MAN-1:0] m1 = in1[MAN-1:0];
wire signed [MAN-1:0] m2 = in2[MAN-1:0];

// multiplica -----------------------------------------------------------------

wire                  mul_s;
wire signed [EXP-1:0] mul_e;
wire        [MAN-1:0] mul_m;

mymult #(EXP,MAN) mymult(s1,s2,e1,e2,m1,m2,mul_s,mul_e,mul_m);

// normaliza ------------------------------------------------------------------

wire [MAN+EXP:0] ari_out;

norm #(MAN, EXP) norm(mul_s,mul_e,mul_m, ari_out);

// Saida ----------------------------------------------------------------------

assign out = ari_out;

endmodule 
