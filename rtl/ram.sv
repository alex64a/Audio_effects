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


module ram#(parameter DATA_WIDTH = 16,
			parameter MEM_DEPTH = 4,
			parameter ADDR_WIDTH = $clog2(MEM_DEPTH))
	(
		input logic pi_clk,
		input logic pi_sreset,
		input logic pi_wr_en,
		input logic pi_rd_en,
		input logic [ADDR_WIDTH-1:0] pi_rd_addr,
		input logic [ADDR_WIDTH-1:0] pi_wr_addr,
		input logic [DATA_WIDTH-1:0] pi_data,
		
		output logic [DATA_WIDTH-1:0] po_data
		
	);

	logic [DATA_WIDTH-1:0] ram [MEM_DEPTH-1:0];
	
	//write
	always @(posedge pi_clk) begin 
		if (pi_wr_en) begin 
			ram[pi_wr_addr] <= pi_data;
		end
	end
    
	//read
	always @(posedge pi_clk) begin
		if(pi_sreset)begin
			po_data <= 0;
		end else if(pi_rd_en) begin
				po_data <= ram[pi_rd_addr];
		end
	end
	
endmodule
