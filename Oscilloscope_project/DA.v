//DA生成正弦波自调试信号模块
module DA (CLK,DA_DATA,DA_CLK);
input CLK;
output DA_CLK;
output reg[8:0] DA_DATA = 9'b000000000;
assign DA_CLK = CLK ;
	
	always @(posedge CLK) 
	begin
		DA_DATA <= DA_DATA + 9'b000000001;
	end
	
endmodule