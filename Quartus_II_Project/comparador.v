module comparador(
    input tentativaA,
    input A_Pin,
    input tentativaB,
    input B_Pin,
    input modoB,              // 0=A, 1=B
    output reg [1:0] resultado
);
    always @(*) begin
        if (modoB == 1'b0) begin
            // Comparação A
            if (tentativaA == A_Pin)
                resultado = 2'b00; // acerto
            else
                resultado = 2'b01; // erro
        end else begin
            // Comparação B
            if (tentativaB == B_Pin)
                resultado = 2'b00; // acerto
            else
                resultado = 2'b01; // erro
        end
    end
endmodule
