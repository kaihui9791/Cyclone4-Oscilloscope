//上位机指令模块，用来选择触发方式，复位，触发沿，与触发电平
module command_platform(clk,rx_data,gather_set,trigger_level,trigger_set);

//input or output
input[7:0] rx_data;
input clk;

output reg[1:0] gather_set; //采集方式设定(F0:重置[默认],F1:连续采样,F2:单次采样)
output reg trigger_set; //触发方式设定(F3:上升沿触发[默认],F4:下降沿触发)
output reg[7:0] trigger_level; //触发电平设定 (00-AB)(-5V~+5V)



always @(posedge clk) begin
	case(rx_data)
		8'hF0: //重置
			gather_set <= 2'b00;
		8'hF1: //连续采样
			gather_set <= 2'b01;
		8'hF2: //单次采样
			gather_set <= 2'b10;
		8'hF3: //上升沿触发
			trigger_set <= 1'b0;
		8'hF4: //下降沿触发
			trigger_set <= 1'b1;
		default: //触发电平
			trigger_level <= rx_data;
		endcase
	end
	
endmodule