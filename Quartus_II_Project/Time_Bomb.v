module Time_Bomb (
    input CLOCK_50,
    input [3:0] KEY,
    output [6:0] HEX3,
    output [6:0] HEX2,
    output [6:0] HEX1,
    output [6:0] HEX0
);

    wire fio_tick_1s;
    wire [3:0] fio_min_u;
    wire [3:0] fio_seg_d;
    wire [3:0] fio_seg_u;

    // Instância do Divisor
    Freq_Div_1Hz INST_DIVISOR (
        .clk(CLOCK_50),
        .tick_1s(fio_tick_1s)
    );

    // Instância do Cronômetro
    Cronometer INST_CRONOMETRO (
        .clk(CLOCK_50),
        .reset(~KEY[1]),
        .start(~KEY[0]),
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
