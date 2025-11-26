module Cronometer(
    input clk,
    input reset,        
    input start,        
    input game_won,     
    input tick_1s,      
    
    // 2:50
    output reg [3:0] min_unidade, // 0 a 2
    output reg [3:0] seg_dezena,  // 0 a 5
    output reg [3:0] seg_unidade, // 0 a 9
    output reg time_over          // 1 = Explodiu
);

    // Estados internos
    reg contando;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            
            min_unidade <= 2;
            seg_dezena  <= 5;
            seg_unidade <= 9;
            time_over   <= 0;
            contando    <= 0;

        end else begin
            // Lógica de Início
            if (start) contando <= 1;
            
            // Lógica de Vitória 
            if (game_won) contando <= 0;

            // Lógica de Decremento 
            if (contando && tick_1s && !time_over) begin
                if (seg_unidade > 0) begin
                    seg_unidade <= seg_unidade - 1;
                end else begin
                    

                    seg_unidade <= 9;
                    if (seg_dezena > 0) begin
                        seg_dezena <= seg_dezena - 1;
                    end else begin
                        

                        seg_dezena <= 5;
                        if (min_unidade > 0) begin
                            min_unidade <= min_unidade - 1;


                        end else begin

                            // ACABOU O TEMPO
                            min_unidade <= 0;
                            seg_dezena <= 0;
                            seg_unidade <= 0;
                            time_over <= 1;
                        end
                    end
                end
            end
        end
    end
endmodule
