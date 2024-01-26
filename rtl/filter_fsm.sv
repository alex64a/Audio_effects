`timescale 1ns / 1ps

module filter_fsm#(
		parameter MEM_DEPTH = 512
	)
	(
		input logic pi_clk,
		input logic pi_sreset,
		input logic pi_tvalid,
		input logic pi_tlast,
		input logic pi_tready,
		input logic pi_start_c_load,
		input logic [9:0] pi_filt_ord,
		
		output logic po_tvalid,
		output logic po_tlast,
		output logic po_tready,
		output logic po_w_en_dpm,
		output logic [$clog2(MEM_DEPTH)-1:0] po_w_addr_dpm,
		output logic [$clog2(MEM_DEPTH)-1:0] po_r_addr_dpm,
		output logic po_r_en_dpm,
		output logic po_w_en_spm,
		output logic [$clog2(MEM_DEPTH)-1:0] po_addr_spm,
		output logic po_r_en_spm,
		output logic po_clk_en,
		output logic po_mux_sel,
		output logic po_start_next_sample,
		output logic po_err,
		output logic po_lddone
	);
	
	logic tlast_reg;
	logic tlast_next;
	logic flag_reg;
	logic flag_next;
	logic flag_next1;
	logic po_mux_sel_current;
	logic po_mux_sel_next;
	logic [$clog2(MEM_DEPTH)-1:0] po_addr_spm_next;
	logic [$clog2(MEM_DEPTH)-1:0] po_addr_spm_current;
	logic [$clog2(MEM_DEPTH)-1:0] po_w_addr_dpm_next;
	logic [$clog2(MEM_DEPTH)-1:0] po_w_addr_dpm_current;
	logic [$clog2(MEM_DEPTH)-1:0] po_r_addr_dpm_next;
	logic [$clog2(MEM_DEPTH)-1:0] po_r_addr_dpm_current;

	typedef enum logic [2:0] { IDLE, LOADING, WAIT_FOT_DATA, STOR_IN, CALC, OUT_VALID} State;
	
	State currentState, nextState;
	
    always_ff @(posedge pi_clk) begin
        if (pi_sreset)
	        currentState <= IDLE;
		else 
			currentState <= nextState;
	end

	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			tlast_reg <= 0;
		else
			tlast_reg <= tlast_next;
	end
	
	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			flag_reg <= 0;
		else
			flag_reg <= flag_next || flag_reg && flag_next1;
	end
	
	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			po_addr_spm_current <= 0;
		else
			po_addr_spm_current <= po_addr_spm_next;
	end
	
	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			po_w_addr_dpm_current <= 0;
		else
			po_w_addr_dpm_current <= po_w_addr_dpm_next;
	end
	
	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			po_r_addr_dpm_current <= 0;
		else
			po_r_addr_dpm_current <= po_r_addr_dpm_next;
	end
	
	always_ff @(posedge pi_clk)begin
		if(pi_sreset)
			po_mux_sel_current <= 0;
		else
			po_mux_sel_current <= po_mux_sel_next;
	end
	
	assign po_addr_spm = po_addr_spm_current;
	assign po_w_addr_dpm = po_w_addr_dpm_current;
	assign po_r_addr_dpm = po_r_addr_dpm_current;
	assign po_mux_sel = po_mux_sel_current;
	
	always_comb begin
		po_tvalid = 0;
		po_tlast = 0;
		po_tready = 0;
		po_w_en_dpm = 0;
		po_r_en_dpm = 0;
		po_w_en_spm = 0;
		po_r_en_spm = 0;
		po_clk_en = 0;
		po_err = 0;
		po_lddone = 0;
		flag_next1 = 1;
		po_start_next_sample = 0;
		nextState = currentState;
		tlast_next = tlast_reg;
		flag_next = flag_reg;
		po_addr_spm_next = po_addr_spm_current;
		po_w_addr_dpm_next = po_w_addr_dpm_current;
		po_r_addr_dpm_next = po_r_addr_dpm_current;
		po_mux_sel_next = po_mux_sel_current;
		
		case(currentState)	
			IDLE:begin
				po_tready = 1;
				if(pi_start_c_load)
					nextState = LOADING;
				else
					nextState = IDLE;
			end
			LOADING:begin
				po_tready = 1;
				if(pi_tvalid )begin
					po_w_en_spm = 1;
					po_addr_spm_next = po_addr_spm_current + 1;
				end
				if(pi_tlast && pi_tvalid)begin
					nextState = WAIT_FOT_DATA;
					po_lddone = 1;
					if(po_addr_spm_current != pi_filt_ord + 1)
					   po_err = 1;
				end else
					nextState = LOADING;

			end
			WAIT_FOT_DATA:begin
				po_tready = 1;
				po_w_en_dpm = 1;
				po_w_addr_dpm_next = po_w_addr_dpm_current;
				if(pi_tvalid)begin
					tlast_next = pi_tlast;
					po_addr_spm_next = 0;
					nextState = STOR_IN;
				end else begin
					nextState = WAIT_FOT_DATA;
				end
			end
			STOR_IN:begin
				po_w_addr_dpm_next = po_w_addr_dpm_current + 1;
				if(pi_filt_ord <= po_w_addr_dpm_current)begin
					flag_next = 1;
				end else begin
					flag_next = 0;
				end
				nextState = CALC;
			end
			CALC:begin
				po_clk_en = 1;
				po_r_en_dpm = 1;
				po_r_en_spm = 1;
				if(po_addr_spm_current == pi_filt_ord)begin
					po_addr_spm_next = 0;
					nextState = OUT_VALID;
				end else begin
					po_addr_spm_next = po_addr_spm_current + 1;
				end	
				if(po_r_addr_dpm_current >= 0)begin
					po_r_addr_dpm_next = po_r_addr_dpm_current - 1;
					
				end else begin
					po_r_addr_dpm_next = MEM_DEPTH - 1;
				end
				if(flag_reg)begin
					po_mux_sel_next = 1;
				end else begin
					if(po_r_addr_dpm_current > po_w_addr_dpm_current)begin
						po_mux_sel_next = 0;
					end else begin
						po_mux_sel_next = 1;
					end
				end	
			end
			OUT_VALID:begin
				po_tvalid = 1;
				po_clk_en = 1;
				po_start_next_sample = 1;
				if(tlast_reg && pi_tready)begin
					po_tlast = 1;
					tlast_next = 0;
					flag_next1 = 0;
					flag_next = 0;
					nextState = IDLE;
                end else begin
					if(pi_tready)
						nextState = WAIT_FOT_DATA;
						po_r_addr_dpm_next = po_w_addr_dpm_current;
			    end
			end
		    
		endcase
	end

endmodule
