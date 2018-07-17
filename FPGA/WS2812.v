module WS2812
#(
	parameter LEDS_NUM = 7, // Сколько светодиодов
	parameter PREPARE_LATCH_DELAY = 10, // сколько тактов ожидать новые данные
	parameter CLOCK_FRQ = 50_000_000  // Частота тактового сигнала
)
(
	input wire clock,
	input wire reset,
	input wire [31:0] color_rgb, // Используется только 0...23 биты, по байтам на каждый цвет (младший - R, старший - B)
	output reg new_data_req,
	output reg [LED_ADDR_WIDTH-1:0] current_ledN,
	output reg ws_data
);

localparam integer CLOCK_CYCLE_COUNT 	= CLOCK_FRQ / 800_000;
localparam integer T0H_CYCLE_COUNT     = 0.35 * CLOCK_CYCLE_COUNT;
localparam integer T1H_CYCLE_COUNT     = 0.9 * CLOCK_CYCLE_COUNT;
localparam integer RESET_CYCLE_COUNT   = 600 * CLOCK_CYCLE_COUNT; // с запасом
localparam integer LED_ADDR_WIDTH 		= $clog2(LEDS_NUM);
localparam integer CLK_COUNTER_WIDTH 	= $clog2(RESET_CYCLE_COUNT);

localparam STATE_RESET    = 3'd0;
localparam STATE_PREPARE_LATCH = 3'd1;
localparam STATE_LATCH    = 3'd2;
localparam STATE_PREPARE_TRANSMIT = 3'd3;
localparam STATE_TRANSMIT = 3'd4;
localparam STATE_FINISH   = 3'd5;

reg [CLK_COUNTER_WIDTH-1:0] clk_counter;
reg [2:0] current_state = STATE_RESET;
reg [1:0] current_color;
reg [2:0] current_bit;

reg [7:0] led_red;
reg [7:0] led_green;
reg [7:0] led_blue;
reg [7:0] led_current_color;

always @ (posedge clock)
begin
	if (reset) 
	begin
		ws_data <= 0;
		current_state <= STATE_RESET;
	end
	else 
	begin
		case (current_state)	
		STATE_RESET:
		begin
			ws_data <= 0;
			clk_counter <= 0;
			current_ledN <= 0;
			current_state <= STATE_PREPARE_LATCH;
		end
		
		STATE_PREPARE_LATCH:
		begin
			new_data_req <= 1;
			if(clk_counter >= PREPARE_LATCH_DELAY)
				current_state <= STATE_LATCH;
			else
				clk_counter <= clk_counter + 1'b1;
		end
		
		STATE_LATCH:
		begin
			new_data_req <= 0;
			led_red <= color_rgb[7:0];
			led_green <= color_rgb[15:8];
			led_blue <= color_rgb[23:16];
			
			current_color <= 0; // зеленый
			current_state <= STATE_PREPARE_TRANSMIT;
		end
		
		STATE_PREPARE_TRANSMIT:
		begin
			clk_counter <= 0;
			current_bit <= 3'd7;
			
			case (current_color)
			2'd0: // зеленый
				led_current_color <= led_green;
			2'd1: // красный
				led_current_color <= led_red;
			2'd2: // синий
				led_current_color <= led_blue;
			endcase // current_color
			
			current_state <= STATE_TRANSMIT;
		end
		
		STATE_TRANSMIT:		
		begin		
			if(led_current_color[current_bit] == 1'b1 && clk_counter >= T1H_CYCLE_COUNT)
				ws_data <= 0;
			else if(led_current_color[current_bit] == 1'b0 && clk_counter >= T0H_CYCLE_COUNT)
				ws_data <= 0;	
			else
				ws_data <= 1;
				
			if(clk_counter >= CLOCK_CYCLE_COUNT)
			begin
				clk_counter <= 0;

				if(current_bit == 3'd0)
				begin
					if(current_color == 2)
					begin
						if(current_ledN == LEDS_NUM)
							current_state <= STATE_FINISH;
						else
						begin // следующий светодиод
							current_ledN <= current_ledN + 1'd1;
							current_color <= 0; // зеленый
							clk_counter <= 0;
							current_state <= STATE_PREPARE_LATCH;
						end
					end
					else
					begin
						current_color <= current_color + 1'b1;
						current_state <= STATE_PREPARE_TRANSMIT;
					end
				end
				else
					current_bit <= current_bit - 1'b1;
			end
			else
				clk_counter <= clk_counter + 1'b1;
		end

		STATE_FINISH:
		begin
			clk_counter <= clk_counter + 1'b1;
		
			if(clk_counter < RESET_CYCLE_COUNT)
				ws_data <= 0;
			else
				current_state <= STATE_RESET;
		end
		endcase // current_state
	end
end

endmodule
