module Time_Bomb (
    input CLOCK_50,
    input [3:0] KEY,
	 input [17:11] SW,
    output [6:0] HEX3,
    output [6:0] HEX2,
    output [6:0] HEX1,
    output [6:0] HEX0
);
    wire [3:0] Wire_A_Pin;
    wire [2:0] Wire_B_Pin;
    wire Wire_Done_Register;

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

    // Instância do Cronômetro
    Cronometer INST_CRONOMETRO (
        .clk(CLOCK_50),
        .reset(~KEY[1]),
        .start(Wire_Done_Register),
        .game_won(1'b0),
        .tick_1s(fio_tick_1s),
        .min_unidade(fio_min_u),
        .seg_dezena(fio_seg_d),
        .seg_unidade(fio_seg_u),
        .time_over() 
    );

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

    assign HEX0 = 7'b1111111;

endmodule
