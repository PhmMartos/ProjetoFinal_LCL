module Time_Bomb (
    input CLOCK_50,
    input [3:0] KEY,
	input [17:0] SW,
    output [7:0] LEDG,
    output [7:0] HEX4,
    output [7:0] HEX3,
    output [7:0] HEX2,
    output [7:0] HEX1,
    output [7:0] HEX0
);
    wire [3:0] Wire_A_Pin;
    wire [2:0] Wire_B_Pin;
    wire [2:0] Wire_Attempt_B;
    wire Wire_Done_Register;
    wire Wire_Game_Won;

    wire fio_tick_1s;
    wire [3:0] fio_min_u;
    wire [3:0] fio_seg_d;
    wire [3:0] fio_seg_u;

    // Instância do Divisor
    Freq_Div_1Hz INST_DIVISOR (
        .clk(CLOCK_50),
        .tick_1s(fio_tick_1s)
    );

    Pin_Configuration INST_PIN_CONFIG (
        .Clk(CLOCK_50),
        .Reset(~KEY[2]),
        .Start(~KEY[0]),
        .Switches_A_Pin(SW[17:14]),
        .Switches_B_Pin(SW[13:11]),
        .A_Pin(Wire_A_Pin),
        .B_Pin(Wire_B_Pin),
        .Done_Register(Wire_Done_Register)
    );

    Attempt_B INST_ATTEMPT_B (
        .Clk(CLOCK_50),
        .Start(), // Precisa de Sinal de Confirmação da Saída de Tentativa A.
        .Enter(~KEY[3]),
        .Attempt_State(), // Precisa de Sinal de Confirmação do Comparador.
        .Switches_Attempt(SW[2:0]),
        .Attempt(Wire_Attempt_B),
        .Display(HEX4),
        .Game_Won(Wire_Game_Won)
    );

    // Instância do Cronômetro
    Cronometer INST_CRONOMETRO (
        .clk(CLOCK_50),
        .reset(~KEY[1]),
        .start(Wire_Done_Register),
        .game_won(Game_Won),
        .tick_1s(fio_tick_1s),
        .min_unidade(fio_min_u),
        .seg_dezena(fio_seg_d),
        .seg_unidade(fio_seg_u),
        .time_over() 
    );

    // Caso de Vitória
    assign LEDG = Game_Won;

    // Displays
    Segment_Display_7 DISP_MIN (
        .valor(fio_min_u),
        .hex(HEX3)
    );

    Segment_Display_7 DISP_SEG10 (
        .valor(fio_seg_d),
        .hex(HEX2)
    );

    Segment_Display_7 DISP_SEG1 (
        .valor(fio_seg_u),
        .hex(HEX1)
    );

    assign HEX0 = 8'b11111111;

endmodule
