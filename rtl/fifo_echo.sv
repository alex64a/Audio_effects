`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2020 11:38:02 AM
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo#(parameter DATA_WIDTH = 16,
			 parameter MEM_DEPTH = 4,
			 parameter ADDR_WIDTH = $clog2(MEM_DEPTH))
	(
	input logic pi_clk,
	input logic pi_sreset,
	input logic pi_sreset_fsm,
	input logic pi_wr_en,
	input logic pi_rd_en,
	input logic [DATA_WIDTH-1:0] pi_data,
		
	output logic [DATA_WIDTH-1:0] po_data,
	output logic po_wr2full,
	output logic po_rdempty
    );
	
	logic [ADDR_WIDTH:0] wr_pointer;
	logic [ADDR_WIDTH:0] rd_pointer;
	logic [DATA_WIDTH-1:0] data_ram;
	
	assign po_w_addr = wr_pointer;
	//write pointer
	always_ff @(posedge pi_clk)begin
		if(pi_sreset || pi_sreset_fsm)
			wr_pointer <= 0;
		else if(pi_wr_en)
			wr_pointer <= wr_pointer + 1;
	end
	
	//read pointer
	always_ff @(posedge pi_clk)begin
		if(pi_sreset || pi_sreset_fsm)
			rd_pointer <= 0;
		else if(pi_rd_en)
			rd_pointer <= rd_pointer + 1;
	end
	
	//read data
	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			po_data <= 0;
		else
			po_data <= data_ram;
	end
	
	//status full/ empty
	always_comb begin
	   po_rdempty = 0;
	   po_wr2full = 0;
		if(wr_pointer[ADDR_WIDTH-1:0] == rd_pointer[ADDR_WIDTH-1:0])
			if(wr_pointer [ADDR_WIDTH] == rd_pointer[ADDR_WIDTH])begin
				po_rdempty = 1;
				po_wr2full = 0;
			end else begin
				po_rdempty = 0;
				po_wr2full = 1;
			end
		
	end
	
	//ram
	ram#(.DATA_WIDTH(DATA_WIDTH),
		 .MEM_DEPTH(MEM_DEPTH),
		 .ADDR_WIDTH(ADDR_WIDTH))
		ram(
			.pi_clk(pi_clk),
			.pi_sreset(pi_sreset),
			.pi_wr_en(pi_wr_en),
			.pi_rd_en(pi_rd_en),
			.pi_wr_addr(wr_pointer[ADDR_WIDTH-1:0]),
			.pi_rd_addr(rd_pointer[ADDR_WIDTH-1:0]),
			.pi_data(pi_data),
			.po_data(data_ram)
			);		
endmodule
