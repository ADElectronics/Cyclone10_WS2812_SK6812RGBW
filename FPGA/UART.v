// https://habr.com/post/278005/

module UART
#(
	parameter CLOCK_FREQUENCY = 50_000_000,
	parameter BAUD_RATE       = 9600
)
(
	input  clockIN,
	input  ResetIN,
	
	input  [7:0] txDataIN,
	input  txLoadIN,
	output wire txIdleOUT,
	output wire txReadyOUT,
	output wire txOUT,
	
	input  rxIN, 
	output wire rxIdleOUT,
	output wire rxReadyOUT,
	output wire [7:0] rxDataOUT
);

UART_TX 
#(
	.CLOCK_FREQUENCY(CLOCK_FREQUENCY),
	.BAUD_RATE(BAUD_RATE)
) uart_tx
(
	.clockIN(clockIN),
	.TxResetIN(ResetIN),
	
	.txDataIN(txDataIN),
	.txLoadIN(txLoadIN),
	.txIdleOUT(txIdleOUT),
	.txReadyOUT(txReadyOUT),
	.txOUT(txOUT)
);

UART_RX 
#(
	.CLOCK_FREQUENCY(CLOCK_FREQUENCY),
	.BAUD_RATE(BAUD_RATE)
) uart_rx
(
	.clockIN(clockIN),
	.RxResetIN(ResetIN),
	
	.rxIN(rxIN), 
	.rxIdleOUT(rxIdleOUT),
	.rxReadyOUT(rxReadyOUT),
	.rxDataOUT(rxDataOUT)
);

endmodule
