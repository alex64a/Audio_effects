`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: fbe
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


module fbe #(
    	parameter DATA_WIDTH=16,
	parameter MEM_DEPTH = 16,
	parameter ADDR_WIDTH = $clog2(MEM_DEPTH)
   )   
   (
    	input logic pi_clk,
   	input logic pi_sreset,
   	input logic [DATA_WIDTH-1:0] pi_data,
   	input logic pi_valid,
   	input logic pi_last,
    	output logic pi_ready,

    	input logic [1:0] pi_echo_input_sel,
    	input logic [15:0] pi_feedback_delay,
    	input logic [9:0] pi_lp_order,
    	input logic [9:0] pi_bp_order,
    	input logic [9:0] pi_hp_order,
    	input logic [15:0] pi_gain_c,
    	input logic [15:0] pi_gain_g,
    	input logic pi_lp_coeff_init,
    	input logic pi_bp_coeff_init,
    	input logic pi_hp_coeff_init,
   
    	output logic [DATA_WIDTH-1:0] po_data,
    	output logic po_valid,
    	output logic po_last,
    	input  logic po_ready,
   
    	output logic po_echo_clip,
    	output logic po_cmp_gain_clip,
    	output logic po_fback_gain_clip,
    	output logic po_cfnum_err_lp,
    	output logic po_cfnum_err_bp,
    	output logic po_cfnum_err_hp,
    	output logic po_cf_lddone_lp,
    	output logic po_cf_lddone_bp,
    	output logic po_cf_lddone_hp,
    	output logic po_wr2full,
	output logic po_rdempty,
	output logic po_clip_lp,
	output logic po_clip_bp,
	output logic po_clip_hp
	
    );     
	logic coef_load;
	
	assign coef_load = (pi_lp_coeff_init || pi_hp_coeff_init || pi_bp_coeff_init);

	AXIS #(.DATA_WIDTH(DATA_WIDTH)) pi_data_axi();
  	assign pi_data_axi.tdata = pi_data;
   	assign pi_data_axi.tvalid = pi_valid;
    	assign pi_data_axi.tlast = pi_last;
    	assign pi_ready = pi_data_axi.tready;
    	        
	AXIS #(.DATA_WIDTH(3*DATA_WIDTH)) fb_out();  
	filter_bank #(.DATA_WIDTH(DATA_WIDTH),
	              .MEM_DEPTH(MEM_DEPTH)
					)
		fb(
			.pi_clk(pi_clk),
			.pi_sreset(pi_sreset),
			.pi_hp_order(pi_hp_order),
			.pi_bp_order(pi_bp_order),
			.pi_lp_order(pi_lp_order),
			.pi_bp_coeff_init(pi_bp_coeff_init),
			.pi_lp_coeff_init(pi_lp_coeff_init),
			.pi_hp_coeff_init(pi_hp_coeff_init),
			.pi_data(pi_data_axi),
			.po_data(fb_out),
			.po_cfnum_err_lp(po_cfnum_err_lp),
			.po_cfnum_err_bp(po_cfnum_err_bp),
			.po_cfnum_err_hp(po_cfnum_err_hp),
			.po_cf_lddone_lp(po_cf_lddone_lp),
			.po_cf_lddone_bp(po_cf_lddone_bp),
			.po_cf_lddone_hp(po_cf_lddone_hp),
			.po_clip_lp(po_clip_lp),
			.po_clip_bp(po_clip_bp),
			.po_clip_hp(po_clip_hp)
			);
			
	AXIS #(.DATA_WIDTH(DATA_WIDTH)) ss_out();  
    	signal_selector #(.DATA_WIDTH(DATA_WIDTH))
                ss(
                    .pi_echo_input_sel(pi_echo_input_sel),
                    .pi_data(pi_data_axi),
                    .pi_data_fb(fb_out),
                    .po_data(ss_out)
                    );
     
                    
   	 AXIS #(.DATA_WIDTH(DATA_WIDTH)) echo_out();
   	 echo_module #(.DATA_WIDTH(DATA_WIDTH),
                       .MEM_DEPTH(MEM_DEPTH),
                       .ADDR_WIDTH(ADDR_WIDTH))
           	echo(
               		.pi_clk(pi_clk),
                	.pi_sreset(pi_sreset),
                	.pi_feedback_delay(pi_feedback_delay),
                	.pi_data(ss_out),
                	.pi_gain_c(pi_gain_c),
                	.pi_gain_g(pi_gain_g),
                	.po_data(echo_out),
                	.po_echo_clip(po_echo_clip),
                	.po_cmp_gain_clip(po_cmp_gain_clip),
                	.po_fback_gain_clip(po_fback_gain_clip),
                	.po_wr2full(po_wr2full),
                	.po_rdempty(po_rdempty)
                ); 
        
	assign po_data = echo_out.tdata;
   	assign po_valid = echo_out.tvalid;
   	assign po_last = echo_out.tlast;
   	assign echo_out.tready = po_ready;          
                         
endmodule
