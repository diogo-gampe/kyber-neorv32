`timescale 1ns/1ps

// Kyber PQ-ALU derivado da proposta de Nannipieri et al.
//
// Formato das instruçoes (R-type, CUSTOM-0):
//   opcode = 7'b0001011
//   funct3 = 3'b000 (Kyber)
//   funct7 = 0: fqmul_k
//            1: reduce_k
//            2: set_twiddle_k
//            3: ntt_k   (Cooley-Tukey butterfly)
//            4: intt_k  (Gentleman-Sande butterfly)
//
// Operando/resuladot ABI:
//   fqmul_k:       rs1[15:0] = a, rs2[15:0] = b
//                   rd = sign_extend_16(fqmul(a, b))
//   reduce_k:      rs1[15:0] = a
//                   rd = sign_extend_16(barrett_reduce(a))
//   set_twiddle_k: rs1[15:0] = endereço do twiddle factor inicial na LUT , rd = 0
//   ntt_k/intt_k:  rs1[15:0] = a, rs2[15:0] = b
//                   rd[15:0]  = saida da primeira butterfly
//                   rd[31:16] = saida da segunda butterfly 

module pq_alu (
  input  wire        clk_i,
  input  wire        rstn_i,

  input  wire        start_i,
  input  wire [31:0] inst_i,
  input  wire [31:0] rs1_i,
  input  wire [31:0] rs2_i,

  output wire [31:0] result_o,
  output wire        valid_o
);

  localparam signed [15:0] KYBER_Q    = 16'sd3329;
  localparam        [15:0] KYBER_QINV = 16'd62209;
  localparam signed [15:0] BARRETT_V   = 16'sd20159;

  localparam [6:0] OPCODE_CUSTOM0 = 7'b0001011;
  localparam [2:0] FUNCT3_KYBER   = 3'b000;

  localparam [6:0] FUNCT7_FQMUL       = 7'd0;
  localparam [6:0] FUNCT7_REDUCE      = 7'd1;
  localparam [6:0] FUNCT7_SET_TWIDDLE = 7'd2;
  localparam [6:0] FUNCT7_NTT         = 7'd3;
  localparam [6:0] FUNCT7_INTT        = 7'd4;

  wire [6:0] funct7;
  wire       is_kyber_inst;
  wire       op_fqmul;
  wire       op_reduce;
  wire       op_set_twiddle;
  wire       op_ntt;
  wire       op_intt;
  wire       op_supported;

  assign funct7 = inst_i[31:25];

  assign is_kyber_inst = (inst_i[6:0]   == OPCODE_CUSTOM0) &&
                         (inst_i[14:12] == FUNCT3_KYBER);

  assign op_fqmul       = is_kyber_inst && (funct7 == FUNCT7_FQMUL);
  assign op_reduce      = is_kyber_inst && (funct7 == FUNCT7_REDUCE);
  assign op_set_twiddle = is_kyber_inst && (funct7 == FUNCT7_SET_TWIDDLE);
  assign op_ntt         = is_kyber_inst && (funct7 == FUNCT7_NTT);
  assign op_intt        = is_kyber_inst && (funct7 == FUNCT7_INTT);

  assign op_supported = op_fqmul       ||
                        op_reduce      ||
                        op_set_twiddle ||
                        op_ntt         ||
                        op_intt;

  assign valid_o = start_i && op_supported;

  // Coeficentes sao inteiros signed 16 bits
  wire signed [15:0] operand_a;
  wire signed [15:0] operand_b;
  reg  signed [15:0] twiddle_q;

  // Twiddle factors de Kyber no dominio de Montgomery.
  // set_twiddle_k usa rs1_i[6:0] como endereco desta ROM 128 x 16.
  (* ramstyle = "M10K" *) reg signed [15:0] zeta_lut [0:127];

  initial begin
    zeta_lut[  0] = 16'sd2285; zeta_lut[  1] = 16'sd2571;
    zeta_lut[  2] = 16'sd2970; zeta_lut[  3] = 16'sd1812;
    zeta_lut[  4] = 16'sd1493; zeta_lut[  5] = 16'sd1422;
    zeta_lut[  6] = 16'sd287;  zeta_lut[  7] = 16'sd202;
    zeta_lut[  8] = 16'sd3158; zeta_lut[  9] = 16'sd622;
    zeta_lut[ 10] = 16'sd1577; zeta_lut[ 11] = 16'sd182;
    zeta_lut[ 12] = 16'sd962;  zeta_lut[ 13] = 16'sd2127;
    zeta_lut[ 14] = 16'sd1855; zeta_lut[ 15] = 16'sd1468;
    zeta_lut[ 16] = 16'sd573;  zeta_lut[ 17] = 16'sd2004;
    zeta_lut[ 18] = 16'sd264;  zeta_lut[ 19] = 16'sd383;
    zeta_lut[ 20] = 16'sd2500; zeta_lut[ 21] = 16'sd1458;
    zeta_lut[ 22] = 16'sd1727; zeta_lut[ 23] = 16'sd3199;
    zeta_lut[ 24] = 16'sd2648; zeta_lut[ 25] = 16'sd1017;
    zeta_lut[ 26] = 16'sd732;  zeta_lut[ 27] = 16'sd608;
    zeta_lut[ 28] = 16'sd1787; zeta_lut[ 29] = 16'sd411;
    zeta_lut[ 30] = 16'sd3124; zeta_lut[ 31] = 16'sd1758;
    zeta_lut[ 32] = 16'sd1223; zeta_lut[ 33] = 16'sd652;
    zeta_lut[ 34] = 16'sd2777; zeta_lut[ 35] = 16'sd1015;
    zeta_lut[ 36] = 16'sd2036; zeta_lut[ 37] = 16'sd1491;
    zeta_lut[ 38] = 16'sd3047; zeta_lut[ 39] = 16'sd1785;
    zeta_lut[ 40] = 16'sd516;  zeta_lut[ 41] = 16'sd3321;
    zeta_lut[ 42] = 16'sd3009; zeta_lut[ 43] = 16'sd2663;
    zeta_lut[ 44] = 16'sd1711; zeta_lut[ 45] = 16'sd2167;
    zeta_lut[ 46] = 16'sd126;  zeta_lut[ 47] = 16'sd1469;
    zeta_lut[ 48] = 16'sd2476; zeta_lut[ 49] = 16'sd3239;
    zeta_lut[ 50] = 16'sd3058; zeta_lut[ 51] = 16'sd830;
    zeta_lut[ 52] = 16'sd107;  zeta_lut[ 53] = 16'sd1908;
    zeta_lut[ 54] = 16'sd3082; zeta_lut[ 55] = 16'sd2378;
    zeta_lut[ 56] = 16'sd2931; zeta_lut[ 57] = 16'sd961;
    zeta_lut[ 58] = 16'sd1821; zeta_lut[ 59] = 16'sd2604;
    zeta_lut[ 60] = 16'sd448;  zeta_lut[ 61] = 16'sd2264;
    zeta_lut[ 62] = 16'sd677;  zeta_lut[ 63] = 16'sd2054;
    zeta_lut[ 64] = 16'sd2226; zeta_lut[ 65] = 16'sd430;
    zeta_lut[ 66] = 16'sd555;  zeta_lut[ 67] = 16'sd843;
    zeta_lut[ 68] = 16'sd2078; zeta_lut[ 69] = 16'sd871;
    zeta_lut[ 70] = 16'sd1550; zeta_lut[ 71] = 16'sd105;
    zeta_lut[ 72] = 16'sd422;  zeta_lut[ 73] = 16'sd587;
    zeta_lut[ 74] = 16'sd177;  zeta_lut[ 75] = 16'sd3094;
    zeta_lut[ 76] = 16'sd3038; zeta_lut[ 77] = 16'sd2869;
    zeta_lut[ 78] = 16'sd1574; zeta_lut[ 79] = 16'sd1653;
    zeta_lut[ 80] = 16'sd3083; zeta_lut[ 81] = 16'sd778;
    zeta_lut[ 82] = 16'sd1159; zeta_lut[ 83] = 16'sd3182;
    zeta_lut[ 84] = 16'sd2552; zeta_lut[ 85] = 16'sd1483;
    zeta_lut[ 86] = 16'sd2727; zeta_lut[ 87] = 16'sd1119;
    zeta_lut[ 88] = 16'sd1739; zeta_lut[ 89] = 16'sd644;
    zeta_lut[ 90] = 16'sd2457; zeta_lut[ 91] = 16'sd349;
    zeta_lut[ 92] = 16'sd418;  zeta_lut[ 93] = 16'sd329;
    zeta_lut[ 94] = 16'sd3173; zeta_lut[ 95] = 16'sd3254;
    zeta_lut[ 96] = 16'sd817;  zeta_lut[ 97] = 16'sd1097;
    zeta_lut[ 98] = 16'sd603;  zeta_lut[ 99] = 16'sd610;
    zeta_lut[100] = 16'sd1322; zeta_lut[101] = 16'sd2044;
    zeta_lut[102] = 16'sd1864; zeta_lut[103] = 16'sd384;
    zeta_lut[104] = 16'sd2114; zeta_lut[105] = 16'sd3193;
    zeta_lut[106] = 16'sd1218; zeta_lut[107] = 16'sd1994;
    zeta_lut[108] = 16'sd2455; zeta_lut[109] = 16'sd220;
    zeta_lut[110] = 16'sd2142; zeta_lut[111] = 16'sd1670;
    zeta_lut[112] = 16'sd2144; zeta_lut[113] = 16'sd1799;
    zeta_lut[114] = 16'sd2051; zeta_lut[115] = 16'sd794;
    zeta_lut[116] = 16'sd1819; zeta_lut[117] = 16'sd2475;
    zeta_lut[118] = 16'sd2459; zeta_lut[119] = 16'sd478;
    zeta_lut[120] = 16'sd3221; zeta_lut[121] = 16'sd3021;
    zeta_lut[122] = 16'sd996;  zeta_lut[123] = 16'sd991;
    zeta_lut[124] = 16'sd958;  zeta_lut[125] = 16'sd1869;
    zeta_lut[126] = 16'sd1522; zeta_lut[127] = 16'sd1628;
  end

  assign operand_a = $signed(rs1_i[15:0]);
  assign operand_b = $signed(rs2_i[15:0]);

  wire reset;
  assign reset = ~rstn_i;

  // Leitura sincrona: twiddle_q fica disponivel para a instrucao seguinte.
  always @(posedge clk_i) begin
    if (reset) begin
      twiddle_q <= 16'sd0;
    end else if (start_i && op_set_twiddle) begin
      twiddle_q <= zeta_lut[rs1_i[6:0]];
    end
  end

  // --------------------------------------------------------------------------
  // Multiplexadores da entrada
  // --------------------------------------------------------------------------

  // Diferença pre multiplicacao usada na borboleta GS
  wire signed [15:0] diff_ba;
  assign diff_ba = operand_b - operand_a;

  // Entradas para fqmul:
  //   fqmul_k -> fqmul(a, b)
  //   ntt_k   -> fqmul(b, twiddle)
  //   intt_k  -> fqmul(b-a, twiddle)
  wire signed [15:0] fq_a;
  wire signed [15:0] fq_b;

  assign fq_a = op_intt ? diff_ba   :
                op_ntt  ? operand_b : operand_a;
  assign fq_b = (op_ntt || op_intt) ? twiddle_q : operand_b;

  // --------------------------------------------------------------------------
  // Multiplicaçao com red. montgomery: fqmul(a,b) = a*b*R^-1 mod q, R = 2^16
  // --------------------------------------------------------------------------

  wire signed [31:0] fq_product;
  wire        [31:0] qinv_product;
  wire signed [15:0] mont_u;
  wire signed [31:0] mont_uq;
  wire signed [31:0] mont_difference;
  wire signed [31:0] mont_shifted;
  wire signed [15:0] fq_result;

  assign fq_product      = fq_a * fq_b;
  assign qinv_product    = fq_product[15:0] * KYBER_QINV;
  assign mont_u          = $signed(qinv_product[15:0]);
  assign mont_uq         = mont_u * KYBER_Q;
  assign mont_difference = fq_product - mont_uq;
  assign mont_shifted    = mont_difference >>> 16;
  assign fq_result       = mont_shifted[15:0];

  // --------------------------------------------------------------------------
  // Somador/Subtrator do Butterfly 
  // --------------------------------------------------------------------------

  //   ntt_k  -> add_result = a + fq_result
  //   intt_k -> add_result = a + b
  wire signed [15:0] add_operand;
  wire signed [15:0] add_result;
  wire signed [15:0] diff_af;

  assign add_operand = op_intt ? operand_b : fq_result;
  assign add_result  = operand_a + add_operand;
  assign diff_af     = operand_a - fq_result;
	
  // --------------------------------------------------------------------------
  // Multiplexador da reduçao Barret 
  // --------------------------------------------------------------------------
  //   reduce_k -> barrett_input = a
  //   intt_k   -> barrett_input = a + b
  wire signed [15:0] barrett_input;
  assign barrett_input = op_intt ? add_result : operand_a;

  // --------------------------------------------------------------------------
  // Barrett reduction from the paper:
  //   t = (V*a) >> 26
  //   r = a - t*q
  // --------------------------------------------------------------------------

  wire signed [31:0] barrett_product;
  wire signed [31:0] barrett_shifted;
  wire signed [15:0] barrett_quotient;
  wire signed [31:0] barrett_multiple_wide;
  wire signed [15:0] barrett_multiple;
  wire signed [15:0] barrett_result;

  assign barrett_product       = BARRETT_V * barrett_input;
  assign barrett_shifted       = barrett_product >>> 26;
  assign barrett_quotient      = barrett_shifted[15:0];
  assign barrett_multiple_wide = barrett_quotient * KYBER_Q;
  assign barrett_multiple      = barrett_multiple_wide[15:0];
  assign barrett_result        = barrett_input - barrett_multiple;

  // --------------------------------------------------------------------------
  // Multiplexadores da saida
  // --------------------------------------------------------------------------

  //   ntt_k  -> primeiro = a + fq,        Segundo = a - fq
  //   intt_k -> primeiro = Barrett(a+b),  segundo = fqmul(b-a, twiddle)
  wire signed [15:0] butterfly_first;
  wire signed [15:0] butterfly_second;
  wire        [31:0] butterfly_result;
  wire        [31:0] fqmul_scalar_result;
  wire        [31:0] reduce_scalar_result;

  assign butterfly_first  = op_intt ? barrett_result : add_result;
  assign butterfly_second = op_intt ? fq_result      : diff_af;
  assign butterfly_result = {butterfly_second[15:0],
                             butterfly_first[15:0]};

  assign fqmul_scalar_result = {{16{fq_result[15]}}, fq_result};
  assign reduce_scalar_result = {{16{barrett_result[15]}},
                                 barrett_result};

  assign result_o = op_fqmul            ? fqmul_scalar_result  :
                    op_reduce           ? reduce_scalar_result :
                    (op_ntt || op_intt) ? butterfly_result     :
                                           32'b0;

endmodule
