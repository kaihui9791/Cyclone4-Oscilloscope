//触发控制模块，用于产生触发信号激活采样
module trigger_control(trigger_activation,trigger_level,trigger_set,clk_20M,data);

input trigger_set;
input[7:0] trigger_level;
input[7:0] data;
input clk_20M;

reg activation;
reg temp_0,temp_1;

output trigger_activation;

//触发信号只在被测信号上升沿或者下降沿时拉高一个时钟周期
assign trigger_activation = ~temp_1 & temp_0;


//上升沿下降沿触发判定
always @(posedge clk_20M) begin
	if(data > trigger_level)
		begin
			if (trigger_set == 1'b0)
				activation <= 1;
			else
				activation <= 0;
		end
	else
		begin
			if (trigger_set == 1'b0)
				activation <= 0;
			else
				activation <= 1;
		end
	end
	


always @(posedge clk_20M) begin //00,10,11,11,11,01,00 只捕获上升沿
	temp_0 <= activation;
	temp_1 <= temp_0;
	end
	
endmodule	