module gerador_pulso_ms (
    input clk,
    output reg tick_1ms
);
    // 50 MHz = 50.000.000 ciclos/segundo
    // 1 ms = 1.000 Hz
    // Contagem = 50.000.000 / 1.000 = 50.000 ciclos
    
    reg [15:0] contador; // 16 bits cabem até 65535

    always @(posedge clk) begin
        if (contador == 50000 - 1) begin
            contador <= 0;
            tick_1ms <= 1; // Pulso de 1 ciclo!
        end else begin
            contador <= contador + 1;
            tick_1ms <= 0;
        end
    end
endmodule