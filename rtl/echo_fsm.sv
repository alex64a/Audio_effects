`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2020 12:15:21 PM
// Design Name: 
// Module Name: fsm_echo
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

module fsm_echo(

	input logic pi_clk,
	input logic pi_sreset,
	input logic pi_tlast,
	input logic pi_valid,
	input logic pi_ready,
	input logic [15:0] pi_feedback_delay,
	
	output logic po_sreset,
	output logic po_ready,
	output logic po_we_en,
	output logic po_rd_en,
	output logic po_clk_en_s0,
	output logic po_clk_en_s1,
	output logic po_valid,
	output logic po_tlast,
	output logic po_mux_sel
	
	);
	
	logic [15:0] echo_delay_next;
	logic [15:0] echo_delay_current;
	
	logic tlast_current;
	logic tlast_next;
	logic flag_rd_en;
	logic flag_rd_en_reg;
	logic po_rd_en_1;
	
	typedef enum logic [1:0] {IDLE, IN_VALID, ALL_VALID, OUT_VALID} State;
	
	State currentState, nextState;
	
	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			tlast_current <= 0;
		else
			tlast_current <=  tlast_current || tlast_next;
	end
	
	always_ff @(posedge pi_clk) begin
        if (pi_sreset)
	       echo_delay_current <= 0;
		else
			echo_delay_current <= echo_delay_next;
  	end
    
	always_comb begin
	    flag_rd_en = 0;
		po_mux_sel = 0;
		if(pi_sreset)begin
			flag_rd_en = 0;
			po_mux_sel = 0;
		end else if(echo_delay_current > pi_feedback_delay-1)begin
			flag_rd_en = 1;
			po_mux_sel = 1;
		end
	end
	
	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			flag_rd_en_reg <= 0;
		else
			flag_rd_en_reg <= flag_rd_en;
	end

    always_ff @(posedge pi_clk) begin
        if (pi_sreset)
	       currentState <= IDLE;
		else
			currentState <= nextState;
  	end
	
	always_ff @(posedge pi_clk)begin
		po_rd_en <= po_rd_en_1;
	end
	
	always_comb begin
      		po_sreset = 0;
			po_ready  = 0;
			po_rd_en_1  = 0;
			po_we_en  = 0;
			po_tlast  = 0;
			po_valid  = 0;
			po_clk_en_s0 = 0;
			po_clk_en_s1 = 0;
			tlast_next = tlast_current;
			echo_delay_next = echo_delay_current;
			nextState = currentState;
		case(currentState)			
			IDLE:begin
				po_ready  = 1;
				tlast_next = pi_tlast;	
				if(pi_valid)begin
					po_clk_en_s0 = 1;
					po_clk_en_s1 = 0;
					nextState = IN_VALID;
				end else begin
					nextState = IDLE;
				end
			end
			IN_VALID:begin
				po_ready = 1;
				tlast_next = pi_tlast;
				echo_delay_next = echo_delay_current + 1;
				if(pi_valid)begin
					po_clk_en_s0 = 1;
					po_clk_en_s1 = 1;
					po_we_en = 1;
					nextState = ALL_VALID;
				end else begin
					po_clk_en_s0 = 1;
					po_clk_en_s1 = 1;
					if(flag_rd_en_reg)
						po_rd_en_1 = 1;
					nextState = OUT_VALID;
				end
			end
			ALL_VALID:begin
				po_valid = 1;
				tlast_next = pi_tlast;	
				if(pi_valid)
				    if(pi_ready)begin
						po_clk_en_s0 = 1;
						po_clk_en_s1 = 1;
						po_we_en = 1;
						echo_delay_next = echo_delay_current + 1;
						po_ready = 1;
						if(flag_rd_en_reg)
							po_rd_en_1= 1;
						nextState = ALL_VALID;			
				end else begin
					if(pi_ready)begin
						po_clk_en_s0 = 0;
						po_clk_en_s1 = 1;
						po_we_en = 1;
						echo_delay_next = echo_delay_current + 1;
						po_ready = 1;
						if(flag_rd_en_reg)
							po_rd_en_1= 1;
						nextState = OUT_VALID;
					end else begin
						po_clk_en_s0 = 0;
						po_clk_en_s1 = 0;
						po_we_en = 0;
						po_ready = 0;
						nextState = ALL_VALID;
					end
				end
			end
			OUT_VALID:begin
				po_ready = 1;
              	po_valid = 1;
              	if(tlast_current)begin
			        po_tlast = 1;
			        po_sreset = 1;
					nextState = IDLE;
				end
				if(pi_valid)begin
					if(pi_ready)begin
						po_clk_en_s0 = 1;
						po_clk_en_s1 = 0;
						po_we_en = 0;
						nextState = IN_VALID;
					end else begin
						po_clk_en_s0 = 1;
						po_clk_en_s1 = 1;
						po_we_en = 1;
						nextState = ALL_VALID;
					end
				end else begin
				    if(pi_ready)begin
						po_clk_en_s0 = 1;
						po_clk_en_s1 = 1;
						po_we_en = 1;
						nextState = IDLE;
					end else begin
						po_clk_en_s0 = 0;
						po_clk_en_s1 = 0;
						po_we_en = 0;
						nextState = OUT_VALID;
					end
				end		
			end
		endcase
	end
endmodule: fsm_echo