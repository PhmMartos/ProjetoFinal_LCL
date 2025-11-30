module Segment_Display_7(
    input [3:0] valor , // Número 0 -> 9
    output reg [7:0]hex // (dot,a,b,c,d,e,f,g)
);

    always @(*) begin
        case (valor)

            4'd0: hex = 8'b10000001; // 0
            4'd1: hex = 8'b11110011; // 1
            4'd2: hex = 8'b01001001; // 2
            4'd3: hex = 8'b01100001; // 3
            4'd4: hex = 8'b00110011; // 4
            4'd5: hex = 8'b00100101; // 5
            4'd6: hex = 8'b00000101; // 6
            4'd7: hex = 8'b11110001; // 7
            4'd8: hex = 8'b00000001; // 8
            4'd9: hex = 8'b00100001; // 9

            default: hex = 8'b11111111;
        endcase
    end
endmodule
