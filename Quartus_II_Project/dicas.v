module dicas (
    input [3:0] senha_a,        // Senha Correta A (4 bits)
    input [2:0] senha_b,        // Senha Correta B (3 bits)
    input [3:0] tentativa_a,    // Tentativa do Jogador A
    input [2:0] tentativa_b,    // Tentativa do Jogador B
    input fase_b_ativa,         // 0 = Jogando A, 1 = Jogando B
    
    output reg [6:0] hex_paridade,    // Para o HEX7
    output reg [6:0] hex_maior_menor, // Para o HEX6
    output reg [3:0] leds_barra_a,    // Barra de progresso A (LEDR 3-0)
    output reg [2:0] leds_barra_b     // Barra de progresso B (LEDR 2-0)
);

    // --- 1. Lógica da Paridade (HEX7) ---
    // Soma todos os bits das senhas corretas (XOR reduzido)
    // Se resultado 1 (Impar) mostra 1. Se 0 (Par) mostra 0.
    wire paridade_bit = ^ {senha_a, senha_b};
    
    always @(*) begin
        case (paridade_bit)
            1'b0: hex_paridade = 7'b1000000; // Mostra '0'
            1'b1: hex_paridade = 7'b1111001; // Mostra '1'
        endcase
    end

    // --- 2. Lógica Maior/Menor (HEX6) ---
    always @(*) begin
        hex_maior_menor = 7'b1111111; // Padrão: Apagado

        if (fase_b_ativa == 0) begin
            // Analisando Senha A
            if (tentativa_a > senha_a) 
                hex_maior_menor = 7'b1111001; // Acende segmento 'a' (Topo/Teto) -> MAIOR
            else if (tentativa_a < senha_a)
                hex_maior_menor = 7'1001111; // Acende segmento 'd' (Base/Chão) -> MENOR
        end else begin
            // Analisando Senha B
            if (tentativa_b > senha_b) 
                hex_maior_menor = 7'b1111001; // MAIOR
            else if (tentativa_b < senha_b)
                hex_maior_menor = 7'b1001111; // MENOR
        end
    end

    // --- 3. Lógica da Barra de Progresso (LEDR) ---
    
    // Função auxiliar para contar bits iguais (XNOR)
    integer i;
    reg [2:0] contagem_a;
    reg [2:0] contagem_b;

    always @(*) begin
        // Conta acertos em A
        contagem_a = 0;
        for (i = 0; i < 4; i = i + 1) begin
            if (senha_a[i] == tentativa_a[i]) contagem_a = contagem_a + 1;
        end

        // Conta acertos em B
        contagem_b = 0;
        for (i = 0; i < 3; i = i + 1) begin
            if (senha_b[i] == tentativa_b[i]) contagem_b = contagem_b + 1;
        end

        // Converte contagem em Barra (Thermometer Code) para A
        case (contagem_a)
            3'd0: leds_barra_a = 4'b0000;
            3'd1: leds_barra_a = 4'b0001;
            3'd2: leds_barra_a = 4'b0011;
            3'd3: leds_barra_a = 4'b0111;
            3'd4: leds_barra_a = 4'b1111;
            default: leds_barra_a = 4'b0000;
        endcase

        // Converte contagem em Barra para B
        case (contagem_b)
            3'd0: leds_barra_b = 3'b000;
            3'd1: leds_barra_b = 3'b001;
            3'd2: leds_barra_b = 3'b011;
            3'd3: leds_barra_b = 3'b111;
            default: leds_barra_b = 3'b000;
        endcase
    end
endmodule