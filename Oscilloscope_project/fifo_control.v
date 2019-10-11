//FIFO总控制模块
module fifo_control(clk_20M,fifo_1_full,fifo_1_empty,fifo_2_empty,fifo_1_wr,fifo_1_rd,fifo_2_wr,fifo_2_rd,fifo_full_rst,gather_set,trigger_activation);

input clk_20M;
input fifo_1_full;
input fifo_1_empty;
input fifo_2_empty;
input[1:0] gather_set;
input trigger_activation;

//FIFO读写信号及重置信号控制
output reg fifo_1_wr;
output reg fifo_1_rd;
output reg fifo_2_wr;
output reg fifo_2_rd;
output reg fifo_full_rst = 1'b1; //重置所有FIFO信号

//计数器模块
reg[11:0] cnt;
reg flag;

//FIFO计数器，工作模式与采样控制有关
always @(posedge clk_20M) begin
	if(cnt == 11'b10000000000 || gather_set == 2'b00) //重置计数器
		cnt <= 0;
	else if(fifo_1_wr == 1) //只在开始采样时启用计数器
		cnt <= cnt + 1'b1;
	end
	

	
always @(posedge clk_20M) begin
	case(gather_set)
	2'b00: //RESET
	begin
		fifo_full_rst <= 1;
		flag <= 0;
	end
	2'b01: //连续采样
	begin	if(cnt == 11'b00000000000 && trigger_activation == 1 && fifo_2_empty == 1) 
		begin
			fifo_1_wr <= 1;
			fifo_1_rd <= 0;
			fifo_2_wr <= 0;
			fifo_full_rst <= 0;
		end
	else if(cnt == 11'b01000000000) // 采集到512个数据，开始发送
		begin
			fifo_1_wr <= 1;
			fifo_1_rd <= 1;
			fifo_2_wr <= 1;
		end
	else if(cnt == 11'b10000000000) //采集1024个数据，关闭写入，继续发送
		begin
			fifo_1_wr <= 0;
			fifo_1_rd <= 1;
			fifo_2_wr <= 1;
		end
	else if(fifo_1_empty == 1 && fifo_2_empty == 0) //发送完毕，锁定FIFO，准备进入下一个循环
		begin
			fifo_1_wr <= 0;
			fifo_1_rd <= 0;
			fifo_2_wr <= 0;
		end
	end
	2'b10: //单次采样，每次采样后必须手工复位
	begin	if(cnt == 11'b00000000000 && trigger_activation == 1 && fifo_1_empty == 1) 
		begin
			fifo_1_wr <= 1;
			fifo_1_rd <= 0;
			fifo_2_wr <= 0;
			fifo_full_rst <= 0;
		end
	else if(cnt == 11'b01000000000) 
		begin
			fifo_1_wr <= 1;
			fifo_1_rd <= 1;
			fifo_2_wr <= 1;
		end
	else if(cnt == 11'b10000000000) 
		begin
			fifo_1_wr <= 0;
			fifo_1_rd <= 1;
			fifo_2_wr <= 1;
		end
	else if(fifo_1_empty == 1 && fifo_2_empty == 0)
		begin
			fifo_1_wr <= 0;
			fifo_1_rd <= 0;
			fifo_2_wr <= 0;
		end
	end	
	default: //保险
	begin
			fifo_1_wr <= 0;
			fifo_1_rd <= 0;
			fifo_2_wr <= 0;
	end
	endcase
end

//FIFO_2读取控制，与串口同步
always @(posedge clk_20M) begin
	if(fifo_2_empty == 0)
		fifo_2_rd <= 1;
	else
		fifo_2_rd <=0;
end


endmodule
	
	