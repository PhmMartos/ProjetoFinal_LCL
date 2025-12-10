module Cronometer (
    input clk,
    input reset,
    input start,
    input game_won,
    input tick_1ms,      // Pulso de milissegundo
    
    output reg [3:0] min_unidade, // Minutos
    output reg [3:0] seg_dezena,  // Segundos (Dezena)
    output reg [3:0] seg_unidade, // Segundos (Unidade)
    output reg [3:0] ms_decimos,  // Décimos (para HEX0)
    output reg time_over          // Explodiu
);

    reg contando;
    // Contadores internos de precisão
    reg [3:0] ms_unidade; 
    reg [3:0] ms_dezena;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // COMEÇA EM 2:59 (Regressivo)
            min_unidade <= 2;
            seg_dezena  <= 5;
            seg_unidade <= 9;
            ms_decimos  <= 9;
            ms_dezena   <= 9;
            ms_unidade  <= 9;
            time_over   <= 0;
            contando    <= 0;
        end else begin
            if (start) contando <= 1;
            if (game_won) contando <= 0;

            // Se o tempo acabar (0:00:000)
            if (min_unidade == 0 && seg_dezena == 0 && seg_unidade == 0 && ms_decimos == 0 && ms_dezena == 0 && ms_unidade == 0) begin
                 time_over <= 1;
                 contando <= 0;
            end
            else if (contando && tick_1ms && !time_over) begin
                // Lógica de SUBTRAÇÃO (Decremento)
                if (ms_unidade > 0) begin
                    ms_unidade <= ms_unidade - 1;
                end else begin
                    ms_unidade <= 9;
                    if (ms_dezena > 0) begin
                        ms_dezena <= ms_dezena - 1;
                    end else begin
                        ms_dezena <= 9;
                        if (ms_decimos > 0) begin
                            ms_decimos <= ms_decimos - 1;
                        end else begin
                            ms_decimos <= 9;
                            if (seg_unidade > 0) begin
                                seg_unidade <= seg_unidade - 1;
                            end else begin
                                seg_unidade <= 9;
                                if (seg_dezena > 0) begin
                                    seg_dezena <= seg_dezena - 1;
                                end else begin
                                    seg_dezena <= 5; // Volta para 59s
                                    if (min_unidade > 0) begin
                                        min_unidade <= min_unidade - 1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
endmodule