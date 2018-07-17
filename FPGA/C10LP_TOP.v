module C10LP_TOP
(
	// Тактирование
	input SYS_CLK50M,
	input SYS_CLK125M_ETH,
	input SYS_CLK50M_HBUS,
	input SYS_CLK_USER,

	output GPIO0,
	input GPIO1,
	
	output ARDUINO_IO12,
	output ARDUINO_IO13,
	
	// Пользовательское управление
	input [3:0] USER_PB,
	output [3:0] USER_LED
);



wire reset, new_data;

wire [31:0] ws_led_color;
wire [2:0] ws_led_addr; // т.к. светодиодов всего лишь 3шт... 
wire [31:0] sk_led_color;
wire [2:0] sk_led_addr;

wire [31:0] ws_led_color_new;
wire [2:0] ws_led_addr_new;
wire ws_led_write_new;
wire [31:0] sk_led_color_new;
wire [2:0] sk_led_addr_new;
wire sk_led_write_new;

wire [7:0] uart_rx;
wire uart_rx_ready;

assign USER_LED = USER_PB;

debouncer db
(
	.noisy(USER_PB[0]),
	.clock(SYS_CLK50M),
	.debounced(reset)
);

WS2812
#(
	.LEDS_NUM(3),
	.CLOCK_FRQ(50_000_000)
) ws
(
	.clock(SYS_CLK50M),
	.reset(reset),
	.color_rgb(ws_led_color),//32'h01010101
	.current_ledN(ws_led_addr),
	//.new_data_req(new_data),
	.ws_data(ARDUINO_IO12)
);

SK6812RGBW
#(
	.LEDS_NUM(3),
	.CLOCK_FRQ(50_000_000)
) sk
(
	.clock(SYS_CLK50M),
	.reset(reset),
	.color_rgbw(sk_led_color),// .color_rgbw({8'd0, b, g, r}),//32'h01010101
	.current_ledN(sk_led_addr),
	//.new_data_req(new_data),
	.ws_data(ARDUINO_IO13)
);

RAM_2P ram_ws
(
	.clock(SYS_CLK50M),
	.rd_b(ws_led_color),
	.addr_b(ws_led_addr),
	.data_a(ws_led_color_new),
	.addr_a(ws_led_addr_new),
	.we_a(ws_led_write_new),
	.we_b(1'b0)
);

RAM_2P ram_sk
(
	.clock(SYS_CLK50M),
	.rd_b(sk_led_color),
	.addr_b(sk_led_addr),
	.data_a(sk_led_color_new),
	.addr_a(sk_led_addr_new),
	.we_a(sk_led_write_new),
	.we_b(1'b0)
);

UART
#(
	.BAUD_RATE(921600), // 921600
	.CLOCK_FREQUENCY(50_000_000)
) uart
(
	.clockIN(SYS_CLK50M),
	.ResetIN(reset),
	.rxDataOUT(uart_rx),
	.rxReadyOUT(uart_rx_ready),
	.rxIN(GPIO1), 
	.txOUT(GPIO0)
);

LedDataSelector lds
(
	.clock(SYS_CLK50M),
	.reset(reset),
	
	.UART_Rx(uart_rx),
	.UART_RxReady(uart_rx_ready),
	
	.LED0_Data(ws_led_color_new),
	.LED0_Addr(ws_led_addr_new),
	.LED0_Write(ws_led_write_new),
	
	.LED1_Data(sk_led_color_new),
	.LED1_Addr(sk_led_addr_new),
	.LED1_Write(sk_led_write_new)
);

endmodule
