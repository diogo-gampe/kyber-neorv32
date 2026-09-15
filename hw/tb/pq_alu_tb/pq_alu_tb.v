`timescale 1ns/1ps

module pq_alu_tb;

  localparam [6:0] FUNCT7_FQMUL       = 7'd0;
  localparam [6:0] FUNCT7_REDUCE      = 7'd1;
  localparam [6:0] FUNCT7_SET_TWIDDLE = 7'd2;
  localparam [6:0] FUNCT7_NTT         = 7'd3;
  localparam [6:0] FUNCT7_INTT        = 7'd4;

  reg         clk_i;
  reg         rstn_i;
  reg         start_i;
  reg  [31:0] inst_i;
  reg  [31:0] rs1_i;
  reg  [31:0] rs2_i;
  wire [31:0] result_o;
  wire        valid_o;

  integer errors;
  integer tests;

  pq_alu dut (
    .clk_i    (clk_i),
    .rstn_i   (rstn_i),
    .start_i  (start_i),
    .inst_i   (inst_i),
    .rs1_i    (rs1_i),
    .rs2_i    (rs2_i),
    .result_o (result_o),
    .valid_o  (valid_o)
  );

  always #5 clk_i = ~clk_i;

  function [31:0] kyber_inst;
    input [6:0] funct7;
    begin
      // funct7 | rs2=x2 | rs1=x1 | funct3=0 | rd=x3 | CUSTOM-0
      kyber_inst = {funct7, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0001011};
    end
  endfunction

  task check_operation;
    input [6:0]  funct7;
    input [31:0] operand_a;
    input [31:0] operand_b;
    input [31:0] expected;
    reg [8*16-1:0] operation_name;
    begin
      case (funct7)
        FUNCT7_FQMUL:  operation_name = "FQMUL";
        FUNCT7_REDUCE: operation_name = "BARRETT_REDUCE";
        FUNCT7_NTT:    operation_name = "NTT";
        FUNCT7_INTT:   operation_name = "INTT";
        default:       operation_name = "DESCONHECIDA";
      endcase

      @(negedge clk_i);
      inst_i  = kyber_inst(funct7);
      rs1_i   = operand_a;
      rs2_i   = operand_b;
      start_i = 1'b1;
      #1;

      tests = tests + 1;
      if (funct7 == FUNCT7_REDUCE) begin
        $display("\n[%0s] Teste %0d | A=0x%04x (%0d) | saida esperada=0x%08x",
                 operation_name, tests, operand_a[15:0],
                 $signed(operand_a[15:0]), expected);
      end else if (funct7 == FUNCT7_NTT || funct7 == FUNCT7_INTT) begin
        $display("\n[%0s] Teste %0d | A=0x%04x (%0d) | B=0x%04x (%0d) | zeta=0x%04x (%0d) | saida esperada=0x%08x",
                 operation_name, tests,
                 operand_a[15:0], $signed(operand_a[15:0]),
                 operand_b[15:0], $signed(operand_b[15:0]),
                 dut.twiddle_q[15:0], $signed(dut.twiddle_q), expected);
      end else begin
        $display("\n[%0s] Teste %0d | A=0x%04x (%0d) | B=0x%04x (%0d) | saida esperada=0x%08x",
                 operation_name, tests,
                 operand_a[15:0], $signed(operand_a[15:0]),
                 operand_b[15:0], $signed(operand_b[15:0]), expected);
      end

      if (valid_o !== 1'b1 || result_o !== expected) begin
        errors = errors + 1;
        $display("FAIL | esperado=0x%08x | recebido=0x%08x | valid esperado=1 recebido=%b",
                 expected, result_o, valid_o);
      end else begin
        $display("PASS | esperado=0x%08x | recebido=0x%08x | valid esperado=1 recebido=%b",
                 expected, result_o, valid_o);
      end

      @(negedge clk_i);
      start_i = 1'b0;
    end
  endtask

  task set_twiddle;
    input [6:0] index;
    input signed [15:0] expected_zeta;
    begin
      @(negedge clk_i);
      inst_i  = kyber_inst(FUNCT7_SET_TWIDDLE);
      rs1_i   = {25'b0, index};
      rs2_i   = 32'b0;
      start_i = 1'b1;
      #1;

      // The selected ROM word is captured by twiddle_q on this rising edge.
      @(posedge clk_i);
      #1;

      tests = tests + 1;
      $display("\n[SET_TWIDDLE] Teste %0d | indice=%0d | zeta esperada=0x%04x (%0d) | saida esperada=0x00000000",
               tests, index, expected_zeta[15:0], expected_zeta);

      if (valid_o !== 1'b1 || result_o !== 32'b0 ||
          dut.twiddle_q !== expected_zeta) begin
        errors = errors + 1;
        $display("FAIL | zeta esperada=0x%04x recebida=0x%04x | saida esperada=0x00000000 recebida=0x%08x | valid esperado=1 recebido=%b",
                 expected_zeta[15:0], dut.twiddle_q[15:0], result_o, valid_o);
      end else begin
        $display("PASS | zeta esperada=0x%04x recebida=0x%04x | saida esperada=0x00000000 recebida=0x%08x | valid esperado=1 recebido=%b",
                 expected_zeta[15:0], dut.twiddle_q[15:0], result_o, valid_o);
      end

      @(negedge clk_i);
      start_i = 1'b0;
    end
  endtask

  task check_invalid_instruction;
    begin
      @(negedge clk_i);
      inst_i  = 32'b0;
      rs1_i   = 32'b0;
      rs2_i   = 32'b0;
      start_i = 1'b1;
      #1;

      tests = tests + 1;
      $display("\n[INSTRUCAO_INVALIDA] Teste %0d | instrucao=0x%08x | saida esperada=0x00000000",
               tests, inst_i);

      if (valid_o !== 1'b0 || result_o !== 32'b0) begin
        errors = errors + 1;
        $display("FAIL | esperado=0x00000000 | recebido=0x%08x | valid esperado=0 recebido=%b",
                 result_o, valid_o);
      end else begin
        $display("PASS | esperado=0x00000000 | recebido=0x%08x | valid esperado=0 recebido=%b",
                 result_o, valid_o);
      end

      @(negedge clk_i);
      start_i = 1'b0;
    end
  endtask

  initial begin
    clk_i   = 1'b0;
    rstn_i  = 1'b0;
    start_i = 1'b0;
    inst_i  = 32'b0;
    rs1_i   = 32'b0;
    rs2_i   = 32'b0;
    errors  = 0;
    tests   = 0;

    repeat (2) @(posedge clk_i);
    rstn_i = 1'b1;

    //Verifica reação a instrução inválida
    check_invalid_instruction();

    // Dez vetores FQMUL retirados das linhas indicadas de ntt_trace.csv.
    // Resultados negativos de 16 bits sao estendidos com sinal para result_o.
    check_operation(FUNCT7_FQMUL, 32'h0000_0a0b, 32'h0000_00be, 32'hffff_fbdb); // Linha 386
    check_operation(FUNCT7_FQMUL, 32'h0000_0a0b, 32'h0000_0080, 32'h0000_063e); // Linha 262
    check_operation(FUNCT7_FQMUL, 32'h0000_0b9a, 32'hffff_fd04, 32'hffff_fea0); // Linha 572
    check_operation(FUNCT7_FQMUL, 32'h0000_0a0b, 32'h0000_0081, 32'hffff_fffe); // Linha 264
    check_operation(FUNCT7_FQMUL, 32'h0000_0626, 32'hffff_fbf2, 32'hffff_feca); // Linha 2352
    check_operation(FUNCT7_FQMUL, 32'h0000_09f8, 32'h0000_11b2, 32'h0000_046d); // Linha 1880
    check_operation(FUNCT7_FQMUL, 32'h0000_00ca, 32'hffff_f7fe, 32'hffff_fd6a); // Linha 1002
    check_operation(FUNCT7_FQMUL, 32'h0000_017f, 32'h0000_0252, 32'h0000_04c1); // Linha 1336
    check_operation(FUNCT7_FQMUL, 32'h0000_0bcd, 32'hffff_f87c, 32'hffff_f9cc); // Linha 2028
    check_operation(FUNCT7_FQMUL, 32'h0000_02dc, 32'h0000_05f0, 32'h0000_039c); // Linha 1458

    // Dez vetores BARRET_REDUCE retirados de ntt_trace.csv.
    // O campo b do trace e um valor intermediario; reduce_k usa apenas rs1.
    check_operation(FUNCT7_REDUCE, 32'h0000_2528, 32'h0000_0000, 32'h0000_0b26); // Linha 2054
    check_operation(FUNCT7_REDUCE, 32'hffff_f436, 32'h0000_0000, 32'h0000_0137); // Linha 2057
    check_operation(FUNCT7_REDUCE, 32'h0000_30bc, 32'h0000_0000, 32'h0000_09b9); // Linha 2060
    check_operation(FUNCT7_REDUCE, 32'hffff_f86a, 32'h0000_0000, 32'h0000_056b); // Linha 2063
    check_operation(FUNCT7_REDUCE, 32'h0000_1458, 32'h0000_0000, 32'h0000_0757); // Linha 2066
    check_operation(FUNCT7_REDUCE, 32'h0000_0600, 32'h0000_0000, 32'h0000_0600); // Linha 2069
    check_operation(FUNCT7_REDUCE, 32'h0000_1d64, 32'h0000_0000, 32'h0000_0362); // Linha 2072
    check_operation(FUNCT7_REDUCE, 32'h0000_1798, 32'h0000_0000, 32'h0000_0a97); // Linha 2075
    check_operation(FUNCT7_REDUCE, 32'h0000_184e, 32'h0000_0000, 32'h0000_0b4d); // Linha 2078
    check_operation(FUNCT7_REDUCE, 32'hffff_fee0, 32'h0000_0000, 32'h0000_0be1); // Linha 2375

    // Nove borboletas da primeira camada usam zeta[1] = 2571.
    set_twiddle(7'd1, 16'sd2571);
    check_operation(FUNCT7_NTT, 32'h0000_0000, 32'h0000_0080, 32'hf9c2_063e); // Linha 263
    check_operation(FUNCT7_NTT, 32'h0000_0001, 32'h0000_0081, 32'h0003_ffff); // Linha 265
    check_operation(FUNCT7_NTT, 32'h0000_0002, 32'h0000_0082, 32'h0644_f9c0); // Linha 267
    check_operation(FUNCT7_NTT, 32'h0000_0003, 32'h0000_0083, 32'hff84_0082); // Linha 269
    check_operation(FUNCT7_NTT, 32'h0000_0004, 32'h0000_0084, 32'h05c5_fa43); // Linha 271
    check_operation(FUNCT7_NTT, 32'h0000_0005, 32'h0000_0085, 32'hff05_0105); // Linha 273
    check_operation(FUNCT7_NTT, 32'h0000_0006, 32'h0000_0086, 32'h0546_fac6); // Linha 275
    check_operation(FUNCT7_NTT, 32'h0000_0007, 32'h0000_0087, 32'hfe86_0188); // Linha 277
    check_operation(FUNCT7_NTT, 32'h0000_0008, 32'h0000_0088, 32'h04c7_fb49); // Linha 279

    // Decima borboleta: primeira operacao da segunda camada, zeta[2].
    set_twiddle(7'd2, 16'sd2970);
    check_operation(FUNCT7_NTT, 32'h0000_063e, 32'hffff_fc9c, 32'h026d_0a0f); // Linha 519

    // Dez borboletas INTT. Cada expectativa concatena
    // {INV_BUTTERFLY.result, INV_BUTTERFLY.reduce} do ntt_trace.csv.
    set_twiddle(7'd127, 16'sd1628);
    check_operation(FUNCT7_INTT, 32'h0000_167e, 32'h0000_0eaa, 32'h0449_0b26); // Linha 2056
    check_operation(FUNCT7_INTT, 32'hffff_fe1c, 32'hffff_f61a, 32'hfa5a_0137); // Linha 2059

    set_twiddle(7'd126, 16'sd1522);
    check_operation(FUNCT7_INTT, 32'h0000_144a, 32'h0000_1c72, 32'h011d_09b9); // Linha 2062
    check_operation(FUNCT7_INTT, 32'hffff_f84b, 32'h0000_001f, 32'hfccf_056b); // Linha 2065

    set_twiddle(7'd125, 16'sd1869);
    check_operation(FUNCT7_INTT, 32'h0000_09b3, 32'h0000_0aa5, 32'h04a9_0757); // Linha 2068
    check_operation(FUNCT7_INTT, 32'h0000_0895, 32'hffff_fd6b, 32'h0352_0600); // Linha 2071

    set_twiddle(7'd124, 16'sd958);
    check_operation(FUNCT7_INTT, 32'h0000_0a93, 32'h0000_12d1, 32'h04cb_0362); // Linha 2074
    check_operation(FUNCT7_INTT, 32'h0000_0f06, 32'h0000_0892, 32'hfeff_0a97); // Linha 2077

    set_twiddle(7'd123, 16'sd991);
    check_operation(FUNCT7_INTT, 32'h0000_07b3, 32'h0000_109b, 32'hfcc7_0b4d); // Linha 2080
    check_operation(FUNCT7_INTT, 32'h0000_1024, 32'h0000_0de8, 32'h0285_040a); // Linha 2083

    if (errors == 0) begin
      $display("\n============================================================");
      $display("PQ_ALU_TB PASS | testes=%0d | aprovados=%0d | falhas=0",
               tests, tests);
      $display("============================================================");
    end else begin
      $display("\n============================================================");
      $display("PQ_ALU_TB FAIL | testes=%0d | aprovados=%0d | falhas=%0d",
               tests, tests - errors, errors);
      $display("============================================================");
    end

    $finish;
  end

endmodule
