//串口发送与FIFO_2读取同步模块
module uart_control(clk,gather_set,bps_start,rd_uart_signal,flag);


input clk;
input[1:0] gather_set;
input bps_start;
input flag;

output reg rd_uart_signal = 1'b1;


//FIFO_2读取在信号上升沿有效，发送在下降沿有效
always @(posedge clk) begin
	if(gather_set == 2'b01 || gather_set == 2'b10) begin //只在采样模式设定后有效
		if(bps_start == 0 && flag == 0) //串口发送空闲且FIFO_2不为0
			rd_uart_signal <= 0;
				else if(bps_start == 1 && flag == 0) //串口忙且FIFO_2不为0
			rd_uart_signal <= 1;
		else if(flag == 1) //FIFO_2为空
			rd_uart_signal <= 1;
		end
	end
	
endmodule
	