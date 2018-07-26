module LedDataSelector
(
	input wire clock,
	input wire reset,
	
	input wire [7:0] UART_Rx,
	input wire UART_RxReady,
	
	output reg [31:0] LED0_Data,
	output reg [31:0] LED0_Addr,
	output reg LED0_Write,
	
	output reg [31:0] LED1_Data,
	output reg [31:0] LED1_Addr,
	output reg LED1_Write
);

localparam STATE_RX_0_BYTE   = 3'd0;
localparam STATE_RX_OTHER	= 3'd1;

reg [2:0] current_state = STATE_RX_0_BYTE;
reg [4:0] current_byte = 0;

reg [31:0] LED_Data;
reg [31:0] LED_Addr;

always @(posedge UART_RxReady or posedge reset) 
begin
	if(reset) 
	begin
		LED0_Data <= 32'd0;
		LED0_Addr <= 32'd0;
		
		LED1_Data <= 32'd0;
		LED1_Addr <= 32'd0;
		
		current_state <= STATE_RX_0_BYTE;
	end
	else
	begin
		case (current_state)	
		STATE_RX_0_BYTE:
		begin
			current_byte <= 1;
			LED0_Write <= 1'b0;
			LED1_Write <= 1'b0;
			LED_Addr <= {24'd0, UART_Rx[7:0]};
			current_state <= STATE_RX_OTHER;	
		end
		
		STATE_RX_OTHER:
		begin
			if(UART_RxReady)
			begin
				case (current_byte)
				1:
					LED_Addr <= {16'd0, UART_Rx[7:0], LED_Addr[7:0]};
				2:
					LED_Addr <= {8'd0, UART_Rx[7:0], LED_Addr[15:0]};
				3:
					LED_Addr <= {UART_Rx[7:0], LED_Addr[23:0]};
				4:
					LED_Data <= {24'd0, UART_Rx[7:0]};
				5:
					LED_Data <= {16'd0, UART_Rx[7:0], LED_Data[7:0]};
				6:
					LED_Data <= {8'd0, UART_Rx[7:0], LED_Data[15:0]};
				7:
				begin
					LED_Data = {UART_Rx[7:0], LED_Data[23:0]};
					
					if(LED_Addr[31] == 1'b1)
					begin
						LED_Addr[31] = 1'b0;
						LED1_Data <= LED_Data;
						LED1_Addr <= LED_Addr;
						LED1_Write <= 1'b1;
					end
					else
					begin
						LED0_Data <= LED_Data;
						LED0_Addr <= LED_Addr;
						LED0_Write <= 1'b1;
					end
					
					current_state <= STATE_RX_0_BYTE;					
				end
				endcase // current_byte
				
				current_byte <= current_byte + 1;
			end
		end
		
		endcase // current_state
	end
end

endmodule
