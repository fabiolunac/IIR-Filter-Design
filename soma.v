// ****************************************************************************
// Circuitos Auxiliares *******************************************************
// ****************************************************************************

// Desnormaliza igualando o expoente de dois numeros --------------------------

module denorm
#(
	parameter EXP = 8,
	parameter MAN = 23
)
(
	input                     s1_in,  s2_in,
	input  signed [EXP-1:0]   e1_in,  e2_in,
	input         [MAN-1:0]   m1_in,  m2_in,
	output signed [EXP-1:0]   e_out,
	output signed [MAN  :0] sm1_out, sm2_out
);

wire signed [EXP:0] eme    = e1_in-e2_in;
wire                ege    = eme[EXP];
wire        [EXP:0] shift2 = (ege) ?  {EXP+1{1'b0}} : eme;
wire        [EXP:0] shift1 = (ege) ? -eme : {EXP+1{1'b0}};

assign e_out = (ege) ? e2_in : e1_in;

wire [MAN-1:0] m1_out = m1_in >> shift1;
wire [MAN-1:0] m2_out = m2_in >> shift2;

assign sm1_out = (s1_in) ? -m1_out : m1_out;
assign sm2_out = (s2_in) ? -m2_out : m2_out;

endmodule

// ****************************************************************************
// Circuitos Aritmeticos ******************************************************
// ****************************************************************************

// Soma em ponto-flutuante ----------------------------------------------------

module mysoma
#(
	parameter EXP = 8,
	parameter MAN = 23
)
(
	input  signed [EXP-1:0] e_in,
	input  signed [MAN  :0] sm1_in, sm2_in,
	output                  s_out,
	output signed [EXP-1:0] e_out,
	output        [MAN-1:0] m_out
);

wire signed [MAN+1:0] soma = sm1_in + sm2_in;
wire signed [MAN+1:0] m    = (soma[MAN+1]) ? -soma : soma;

assign s_out = soma[MAN+1];
assign e_out = e_in + {{EXP-1{1'b0}}, {1'b1}}; // colocar limite para +inf
assign m_out = m[MAN:1];

endmodule

// ****************************************************************************
// Circuito Principal *********************************************************
// ****************************************************************************

module soma
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

// desnormaliza ---------------------------------------------------------------

wire signed [EXP-1:0] de;
wire signed [MAN  :0] dm1, dm2;

denorm #(EXP, MAN) denorm(s1, s2, e1, e2, m1, m2, de, dm1, dm2);

// soma -----------------------------------------------------------------------

wire                  sum_s;
wire signed [EXP-1:0] sum_e;
wire        [MAN-1:0] sum_m;

mysoma #(EXP,MAN) mysoma(de,dm1,dm2,sum_s,sum_e, sum_m);

// normaliza ------------------------------------------------------------------

wire [MAN+EXP:0] ari_out;

norm #(MAN, EXP) norm(sum_s,sum_e, sum_m, ari_out);

// Saida ----------------------------------------------------------------------

assign out = ari_out;

endmodule 
