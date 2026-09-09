
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

  // Coeficentes sao inteiros signed 16 bits
  wire signed [15:0] operand_a;
  wire signed [15:0] operand_b;
  reg  signed [15:0] twiddle_q;

  assign operand_a = $signed(rs1_i[15:0]);
  assign operand_b = $signed(rs2_i[15:0]);

  // --------------------------------------------------------------------------
  // Multiplexadores da entrada
  // --------------------------------------------------------------------------

  // Diferença pre multiplcacao usada na borboleta GS
  wire signed [15:0] diff_ab;
  assign diff_ab = operand_a - operand_b;

  // Entradas para fqmul:
  //   fqmul_k -> fqmul(a, b)
  //   ntt_k   -> fqmul(a, twiddle)
  //   intt_k  -> fqmul(a-b, twiddle)
  wire signed [15:0] fq_a;
  wire signed [15:0] fq_b;

  assign fq_a = op_intt ? diff_ab : operand_a;
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
  //   intt_k -> first = Barrett(a+b), second = fqmul(a-b, twiddle)
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
