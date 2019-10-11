// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 32-bit"
// VERSION		"Version 13.1.0 Build 162 10/23/2013 SJ Full Version"
// CREATED		"Mon Jan 14 11:57:32 2019"

module osc(
	UART_RXD,
	clk,
	S1,
	AD_DATA_IN,
	UART_TXD,
	AD_CLK,
	DA_CLK,
	DA_DATA_OUT
);


input wire	UART_RXD;
input wire	clk;
input wire	S1;
input wire	[7:0] AD_DATA_IN;
output wire	UART_TXD;
output wire	AD_CLK;
output wire	DA_CLK;
output wire	[7:0] DA_DATA_OUT;

wire	AD_DA_CLK;
wire	bps_start_rx;
wire	bps_start_tx;
wire	clk_bps_rx;
wire	clk_bps_tx;
wire	[7:0] data;
wire	[7:0] fifo_1_data;
wire	fifo_1_empty;
wire	fifo_1_full;
wire	fifo_1_rd;
wire	fifo_1_wr;
wire	[7:0] fifo_2_data;
wire	fifo_2_empty;
wire	fifo_2_rd;
wire	fifo_2_wr;
wire	fifo_rst;
wire	[1:0] gather_set;
wire	rd_uart_signal;
wire	rst;
wire	[7:0] rx_data;
wire	trigger_activation;
wire	[7:0] trigger_level;
wire	trigger_set;
wire	SYNTHESIZED_WIRE_0;
wire	[8:0] SYNTHESIZED_WIRE_1;





uart_tx	b2v_inst(
	.clk(clk),
	.rst_n(rst),
	.rx_int(rd_uart_signal),
	.clk_bps(clk_bps_tx),
	.rx_data(fifo_2_data),
	.rs232_tx(UART_TXD),
	.bps_start(bps_start_tx));


uart_rx	b2v_inst1(
	.clk(clk),
	.rst_n(rst),
	.rs232_rx(UART_RXD),
	.clk_bps(clk_bps_rx),
	
	.bps_start(bps_start_rx),
	.rx_data(rx_data));


bps	b2v_inst10(
	.clk(clk),
	.rst_n(rst),
	.bps_start(bps_start_rx),
	.clk_bps(clk_bps_rx));


DA	b2v_inst11(
	.CLK(SYNTHESIZED_WIRE_0),
	.DA_CLK(AD_DA_CLK),
	.DA_DATA(SYNTHESIZED_WIRE_1));


sin512	b2v_inst12(
	.clock(AD_DA_CLK),
	.address(SYNTHESIZED_WIRE_1),
	.q(DA_DATA_OUT));


bps	b2v_inst2(
	.clk(clk),
	.rst_n(rst),
	.bps_start(bps_start_tx),
	.clk_bps(clk_bps_tx));


command_platform	b2v_inst3(
	.clk(clk),
	.rx_data(rx_data),
	.trigger_set(trigger_set),
	.gather_set(gather_set),
	.trigger_level(trigger_level));


trigger_control	b2v_inst4(
	.trigger_set(trigger_set),
	.clk_20M(AD_DA_CLK),
	.data(data),
	.trigger_level(trigger_level),
	.trigger_activation(trigger_activation));


fifo_control	b2v_inst5(
	.clk_20M(AD_DA_CLK),
	.fifo_1_full(fifo_1_full),
	.fifo_1_empty(fifo_1_empty),
	.fifo_2_empty(fifo_2_empty),
	.trigger_activation(trigger_activation),
	.gather_set(gather_set),
	.fifo_1_wr(fifo_1_wr),
	.fifo_1_rd(fifo_1_rd),
	.fifo_2_wr(fifo_2_wr),
	.fifo_2_rd(fifo_2_rd),
	.fifo_full_rst(fifo_rst));


fifo_1	b2v_inst6(
	.wrreq(fifo_1_wr),
	.rdreq(fifo_1_rd),
	.clock(AD_DA_CLK),
	.aclr(fifo_rst),
	.data(data),
	.full(fifo_1_full),
	.empty(fifo_1_empty),
	.q(fifo_1_data));


fifo_2	b2v_inst7(
	.wrreq(fifo_2_wr),
	.wrclk(AD_DA_CLK),
	.rdreq(fifo_2_rd),
	.rdclk(rd_uart_signal),
	.aclr(fifo_rst),
	.data(fifo_1_data),
	
	.wrempty(fifo_2_empty),
	
	.q(fifo_2_data));


uart_control	b2v_inst8(
	.clk(clk),
	.bps_start(bps_start_tx),
	.flag(fifo_2_empty),
	.gather_set(gather_set),
	.rd_uart_signal(rd_uart_signal));


pll_1	b2v_inst9(
	.inclk0(clk),
	.c0(SYNTHESIZED_WIRE_0));

assign	rst = S1;
assign	data = AD_DATA_IN;
assign	AD_CLK = AD_DA_CLK;
assign	DA_CLK = AD_DA_CLK;

endmodule
