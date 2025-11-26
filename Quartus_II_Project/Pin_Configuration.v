module Pin_Configuration(
    input Clk,
    input Reset,
    input Start,
    input [3:0] Switches_A_Pin,
    input [2:0] Switches_B_Pin,

    output reg [3:0] A_Pin,
    output reg [2:0] B_Pin,
    output reg Done_Register
);

    reg Start_Old;
    wire Start_Rising = Start && !Start_Old;

    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            A_Pin <= 0;
            B_Pin <= 0;
            Start_Old <= 0;
            Done_Register <= 0;
        end else begin
            Start_Old <= Start;
            if (Start_Rising && !Done_Register) begin
                A_Pin <= Switches_A_Pin;
                B_Pin <= Switches_B_Pin;
                Done_Register <= 1;
            end
        end
    end

endmodule