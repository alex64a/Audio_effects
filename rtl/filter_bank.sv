`timescale 1ns / 1ps
//Djordje

module filter_bank #(
		parameter DATA_WIDTH = 16,
		parameter MEM_DEPTH = 16
	)
	(
	
		input logic pi_clk,
   		input logic pi_sreset,
    
		input logic pi_hp_coeff_init,
		input logic pi_bp_coeff_init,
		input logic pi_lp_coeff_init,
	
		input logic [9:0] pi_hp_order,
		input logic [9:0] pi_bp_order,
		input logic [9:0] pi_lp_order,
	
		AXIS.slave pi_data,
		AXIS.master po_data,
	
		output logic po_cfnum_err_lp,
		output logic po_cfnum_err_bp,
		output logic po_cfnum_err_hp,
	
		output logic po_cf_lddone_lp,
		output logic po_cf_lddone_bp,
		output logic po_cf_lddone_hp,
	
		output logic po_clip_lp,
		output logic po_clip_bp,
		output logic po_clip_hp
	
	);
	logic [2:0] coeff_init;
	logic all_valid;
	assign coeff_init = {pi_hp_coeff_init,pi_bp_coeff_init,pi_lp_coeff_init};
	always_comb begin
	    case(coeff_init)
			3'b001:begin
				hp_filter_in.tvalid = 0;  
				bp_filter_in.tvalid = 0;
				lp_filter_in.tvalid = all_valid;
			end
			3'b010:begin
				hp_filter_in.tvalid = 0;  
				bp_filter_in.tvalid = all_valid;
				lp_filter_in.tvalid = 0;
			end
			3'b100:begin
				hp_filter_in.tvalid = all_valid;  
				bp_filter_in.tvalid = 0;
				lp_filter_in.tvalid = 0;
			end
			default:begin
				hp_filter_in.tvalid = all_valid;  
				bp_filter_in.tvalid = all_valid;
				lp_filter_in.tvalid = all_valid;
	       end
	   endcase
	end
	
	assign hp_filter_in.tdata = pi_data.tdata; 
	assign bp_filter_in.tdata = pi_data.tdata; 
	assign lp_filter_in.tdata = pi_data.tdata; 
	
	assign hp_filter_in.tlast = pi_data.tlast;
	assign bp_filter_in.tlast = pi_data.tlast;
	assign lp_filter_in.tlast = pi_data.tlast;
	
	assign pi_data.tready = hp_filter_in.tready && bp_filter_in.tready && lp_filter_in.tready;
	assign all_valid = pi_data.tready && pi_data.tvalid;
	AXIS #(.DATA_WIDTH(DATA_WIDTH)) hp_filter_in();
	AXIS #(.DATA_WIDTH(DATA_WIDTH)) hp_filter_out();
	filter #(.DATA_WIDTH(DATA_WIDTH),
		.MEM_DEPTH(MEM_DEPTH))
		hp_filter(
				  .pi_clk(pi_clk),
				  .pi_sreset(pi_sreset),
				  .pi_start_c_load(pi_hp_coeff_init),
				  .pi_filt_ord(pi_hp_order),
				  .pi_data(hp_filter_in),
				  .po_data(hp_filter_out),
				  .po_err(po_cfnum_err_hp),
				  .po_lddone(po_cf_lddone_hp),
				  .po_filter_clip(po_clip_hp)
				  );
				  
	AXIS #(.DATA_WIDTH(DATA_WIDTH)) bp_filter_in();
	AXIS #(.DATA_WIDTH(DATA_WIDTH)) bp_filter_out();
	filter #(.DATA_WIDTH(DATA_WIDTH),
		.MEM_DEPTH(MEM_DEPTH))
		bp_filter(
				  .pi_clk(pi_clk),
				  .pi_sreset(pi_sreset),
				  .pi_start_c_load(pi_bp_coeff_init),
				  .pi_filt_ord(pi_bp_order),
				  .pi_data(bp_filter_in),
				  .po_data(bp_filter_out),
				  .po_err(po_cfnum_err_bp),
				  .po_lddone(po_cf_lddone_bp),
				  .po_filter_clip(po_clip_bp)
				  );
				  
	AXIS #(.DATA_WIDTH(DATA_WIDTH)) lp_filter_in();
	AXIS #(.DATA_WIDTH(DATA_WIDTH)) lp_filter_out();
	filter #(.DATA_WIDTH(DATA_WIDTH),
		.MEM_DEPTH(MEM_DEPTH))
		lp_filter(
				  .pi_clk(pi_clk),
				  .pi_sreset(pi_sreset),
				  .pi_start_c_load(pi_lp_coeff_init),
				  .pi_filt_ord(pi_lp_order),
				  .pi_data(lp_filter_in),
				  .po_data(lp_filter_out),
				  .po_err(po_cfnum_err_lp),
				  .po_lddone(po_cf_lddone_lp),
				  .po_filter_clip(po_clip_lp)
				  );
	
	assign po_data.tvalid = hp_filter_out.tvalid && bp_filter_out.tvalid && lp_filter_out.tvalid;
	assign po_data.tdata = {hp_filter_out.tdata, bp_filter_out.tdata, lp_filter_out.tdata};
	assign po_data.tlast = po_data.tvalid && lp_filter_out.tlast;
	assign hp_filter_out.tready = po_data.tvalid && po_data.tready;
	assign bp_filter_out.tready = po_data.tvalid && po_data.tready;
	assign lp_filter_out.tready = po_data.tvalid && po_data.tready;	
endmodule
