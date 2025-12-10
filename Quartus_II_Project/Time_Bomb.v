module Time_Bomb (
    input CLOCK_50,
    input [3:0] KEY,     // KEY[0]=Start, KEY[1]=Reset, KEY[3]=Enter
    input [17:0] SW,     // Configuração e Tentativas
    
    output [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
    output [8:0] LEDG,   // LEDs Verdes (Vitória)
    output [17:0] LEDR   // LEDs Vermelhos (Barra de Progresso)
);

    // --- ESTADOS ---
    parameter ESTADO_SETUP     = 3'd0;
    parameter ESTADO_JOGO_A    = 3'd1;
    parameter ESTADO_JOGO_B    = 3'd2;
    parameter ESTADO_VITORIA   = 3'd3;
    parameter ESTADO_GAMEOVER  = 3'd4;

    reg [2:0] estado_atual;

    // --- SINAIS INTERNOS ---
    wire tick_ms;
    wire time_over;

    // Registradores de Senha e Tentativa
    reg [3:0] senha_a_secreta;
    reg [2:0] senha_b_secreta;
    reg [3:0] tentativa_a_registrada;
    reg [2:0] tentativa_b_registrada;

    // Fios de conexão com o módulo de Dicas
    wire [6:0] w_hex7_paridade;
    wire [6:0] w_hex6_dica;
    wire [3:0] w_leds_a;
    wire [2:0] w_leds_b;

    // --- TRATAMENTO DOS BOTÕES (CORREÇÃO CRÍTICA) ---
    // Inverte a lógica (Botão pressionado na DE2 gera 0)
    wire bt_start_raw = ~KEY[0];
    wire bt_reset     = ~KEY[1];
    wire bt_enter_raw = ~KEY[3];

    // Registradores para armazenar o estado anterior do botão
    reg bt_start_ant;
    reg bt_enter_ant;

    // Lógica de detecção de borda de subida (0 -> 1)
    // O sinal só fica alto por 1 ciclo de clock, evitando leituras múltiplas
    wire start_posedge = bt_start_raw && !bt_start_ant;
    wire enter_posedge = bt_enter_raw && !bt_enter_ant;

    always @(posedge CLOCK_50) begin
        bt_start_ant <= bt_start_raw;
        bt_enter_ant <= bt_enter_raw;
    end

    // --- EFEITO PISCA-PISCA (Para Explosão) ---
    reg [24:0] contador_pisca;
    always @(posedge CLOCK_50) contador_pisca <= contador_pisca + 1;
    wire pisca_lento = contador_pisca[24]; // Pisca a cada ~0.6 segundos

    // --- MÁQUINA DE ESTADOS ---
    always @(posedge CLOCK_50 or posedge bt_reset) begin
        if (bt_reset) begin
            estado_atual <= ESTADO_SETUP;
            senha_a_secreta <= 0;
            senha_b_secreta <= 0;
            tentativa_a_registrada <= 0;
            tentativa_b_registrada <= 0;
        end else begin
            case (estado_atual)
                ESTADO_SETUP: begin
                    // Usa o pulso (posedge) ao invés do nível
                    if (start_posedge) begin
                        senha_a_secreta <= SW[17:14];
                        senha_b_secreta <= SW[13:11];
                        estado_atual <= ESTADO_JOGO_A;
                    end
                end

                ESTADO_JOGO_A: begin
                    if (time_over) estado_atual <= ESTADO_GAMEOVER;
                    
                    if (enter_posedge) begin
                        tentativa_a_registrada <= SW[3:0]; // Grava tentativa A
                        
                        // Verifica se acertou a senha A
                        if (SW[3:0] == senha_a_secreta) begin
                            estado_atual <= ESTADO_JOGO_B;
                        end
                    end
                end

                ESTADO_JOGO_B: begin
                    if (time_over) estado_atual <= ESTADO_GAMEOVER;
                    
                    if (enter_posedge) begin
                        tentativa_b_registrada <= SW[2:0]; // Grava tentativa B
                        
                        // Verifica se acertou a senha B
                        if (SW[2:0] == senha_b_secreta) begin
                            estado_atual <= ESTADO_VITORIA;
                        end
                    end
                end
                
                ESTADO_VITORIA: begin
                    // Trava aqui até resetar
                end

                ESTADO_GAMEOVER: begin
                    // Trava aqui até resetar
                end
            endcase
        end
    end

    // --- INSTÂNCIAS ---

    // 1. Gerador de Pulso de 1ms
    // IMPORTANTE: Certifique-se que seu módulo gerador_pulso_ms gera um pulso de 1 ciclo (strobe),
    // e não uma onda quadrada (50% duty cycle), para o cronômetro funcionar perfeitamente.
    gerador_pulso_ms DIVISOR (
        .clk(CLOCK_50),
        .tick_1ms(tick_ms)
    );

    wire [3:0] wm, wd, wu, wdec;

    // 2. Cronômetro Regressivo
    Cronometer RELOGIO (
        .clk(CLOCK_50),
        .reset(bt_reset),
        // O cronômetro conta apenas durante as fases de jogo
        .start(estado_atual == ESTADO_JOGO_A || estado_atual == ESTADO_JOGO_B),
        .game_won(estado_atual == ESTADO_VITORIA),
        .tick_1ms(tick_ms),
        .min_unidade(wm), 
        .seg_dezena(wd), 
        .seg_unidade(wu), 
        .ms_decimos(wdec),
        .time_over(time_over)
    );

    // 3. Módulo de Dicas
    dicas DICAS (
        .senha_a(senha_a_secreta),
        .senha_b(senha_b_secreta),
        .tentativa_a(tentativa_a_registrada),
        .tentativa_b(tentativa_b_registrada),
        .fase_b_ativa(estado_atual == ESTADO_JOGO_B), 
        .hex_paridade(w_hex7_paridade),
        .hex_maior_menor(w_hex6_dica),
        .leds_barra_a(w_leds_a),
        .leds_barra_b(w_leds_b)
    );

    // --- SAÍDAS VISUAIS ---

    // DISPLAYS TEMPO (Se explodir/GameOver, eles piscam "00:00")
    wire mostrar_display = (estado_atual == ESTADO_GAMEOVER) ? pisca_lento : 1'b1;
    
    wire [6:0] h3, h2, h1, h0;
    Segment_Display_7 D3 (.valor(wm),   .hex(h3));
    Segment_Display_7 D2 (.valor(wd),   .hex(h2));
    Segment_Display_7 D1 (.valor(wu),   .hex(h1));
    Segment_Display_7 D0 (.valor(wdec), .hex(h0)); 

    assign HEX3 = mostrar_display ? h3 : 7'b1111111;
    assign HEX2 = mostrar_display ? h2 : 7'b1111111;
    assign HEX1 = mostrar_display ? h1 : 7'b1111111;
    assign HEX0 = mostrar_display ? h0 : 7'b1111111;

    // DISPLAY DICAS (HEX7 e HEX6)
    assign HEX7 = w_hex7_paridade;
    // HEX6 só acende durante o jogo
    assign HEX6 = (estado_atual == ESTADO_JOGO_A || estado_atual == ESTADO_JOGO_B) ? w_hex6_dica : 7'b1111111;
    assign HEX5 = 7'b1111111; // Apagado conforme especificação

    // DISPLAY CUSTOMIZADO HEX4 (Mostra as tentativas inseridas)
    // Se estiver no Game Over, pisca também!
    wire mostrar_hex4 = (estado_atual == ESTADO_GAMEOVER) ? pisca_lento : 1'b1;
    
    wire [6:0] hex4_signals;
    
    // Mapeamento conforme PDF Página 2 (Quadrado Superior para A, Inferior para B)
    // Lógica invertida para display 7 segmentos (0 = aceso, 1 = apagado)
    // Segmentos: 0(A), 1(B), 2(C), 3(D), 4(E), 5(F), 6(G)
    
    // Senha A (4 bits): Segmentos 0, 1, 5, 6 (Topo, Sup Dir, Sup Esq, Meio)
    assign hex4_signals[0] = ~tentativa_a_registrada[3]; // A
    assign hex4_signals[1] = ~tentativa_a_registrada[2]; // B
    assign hex4_signals[5] = ~tentativa_a_registrada[1]; // F
    assign hex4_signals[6] = ~tentativa_a_registrada[0]; // G
    
    // Senha B (3 bits): Segmentos 2, 3, 4 (Inf Dir, Base, Inf Esq)
    assign hex4_signals[2] = ~tentativa_b_registrada[2]; // C
    assign hex4_signals[3] = ~tentativa_b_registrada[1]; // D
    assign hex4_signals[4] = ~tentativa_b_registrada[0]; // E
    
    assign HEX4 = mostrar_hex4 ? hex4_signals : 7'b1111111;

    // LEDS VERDES (Vitória)
    // Acendem todos se ganhar
    assign LEDG = (estado_atual == ESTADO_VITORIA) ? 9'b111111111 : 9'b000000000;

    // LEDS VERMELHOS (Barra de Progresso + Explosão)
    // Lógica ajustada para o PDF:
    // - Game Over: Pisca todos
    // - Jogo A: Mostra progresso de A nos LEDs [3:0]
    // - Jogo B: Mostra progresso de B nos LEDs [2:0]
    
    assign LEDR = (estado_atual == ESTADO_GAMEOVER && pisca_lento) ? 18'b111111111111111111 : 
                  (estado_atual == ESTADO_JOGO_A) ? {14'b0, w_leds_a} :
                  (estado_atual == ESTADO_JOGO_B) ? {15'b0, w_leds_b} : 
                  18'b0; // Apagados em Setup ou Vitória (padrão)

endmodule