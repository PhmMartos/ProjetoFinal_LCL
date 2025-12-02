module Attempt_B(
    input Clk,
    input Start,
    input Enter,
    input Attempt_State, // 0 = Incorrect | 1 = Correct.
    input [2:0] Switches_Attempt,

    output reg [2:0] Attempt,
    output reg [7:0] Display,
    output reg Game_Won
);

    localparam S_WAIT_START = 3'd0;
    localparam S_WAIT_ENTER = 3'd1;
    localparam S_CAPTURE = 3'd2;
    localparam S_DISPLAY = 3'd3;
    localparam S_CHECK = 3'd4;
    localparam S_WIN = 3'd5;

    reg [2:0] State;

    initial begin
        State = S_WAIT_START;
        Game_Won = 0;
    end

    reg Enter_Old;
    wire Enter_Rising = Enter && !Enter_Old;

    always @(posedge Clk) begin
        Enter_Old <= Enter;
        case (State)
            S_WAIT_START: begin
                if (Start) State <= S_WAIT_ENTER;
            end

            S_WAIT_ENTER: begin
                if (Enter_Rising) State <= S_CAPTURE;
            end

            S_CAPTURE: begin
                Attempt <= Switches_Attempt;
                State <= S_DISPLAY;
            end

            S_DISPLAY: begin
                Display[7] <= 1;
                Display[6] <= 1;
                Display[5] <= 1;
                Display[4] <= ~Attempt[0];
                Display[3] <= ~Attempt[1];
                Display[2] <= ~Attempt[2];
                Display[1] <= 1;
                Display[0] <= 1;

                State <= S_CHECK;
            end

            S_CHECK: begin
                if (Attempt_State) begin
                    Game_Won <= 1;
                    State <= S_WIN;
                end
                else State <= S_WAIT_ENTER;
            end

            S_WIN: begin
                // Stop in This State.
            end

            default: State <= S_WAIT_START;
        endcase
    end
endmodule