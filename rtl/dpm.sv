`timescale 1ns / 1ps

module dual_port_memory#(
		parameter DATA_WIDTH = 16,
		parameter MEM_DEPTH = 512
	)
	(
		input logic pi_clk,
		input logic pi_sreset,
		input logic [DATA_WIDTH-1:0]pi_data,
		input logic pi_w_en,
		input logic [$clog2(MEM_DEPTH)-1:0]pi_w_addr,
		input logic [$clog2(MEM_DEPTH)-1:0]pi_r_addr,
		input logic pi_r_en,
		
		output logic [DATA_WIDTH-1:0]po_data
	);
	
	logic [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0];
	
	always_ff @(posedge pi_clk) begin
		if(pi_w_en)
			mem[pi_w_addr] <= pi_data;
	end
	
	always_ff @(posedge pi_clk) begin
		if(pi_sreset)
			po_data <= 0;
		else
			if(pi_r_en)
				po_data <=mem[pi_r_addr];	
	end
	
endmodule
