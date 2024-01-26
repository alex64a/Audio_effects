module filter#(
		parameter DATA_WIDTH = 16,
		parameter MEM_DEPTH = 512
	)
	(
		input logic pi_clk,
		input logic pi_sreset,
		input logic pi_start_c_load,
		input logic [9:0] pi_filt_ord,
		
		AXIS.slave pi_data,
		AXIS.master po_data,
		
		output logic po_err,
		output logic po_lddone,
	    output logic po_filter_clip
	);
	
	logic mux_sel;
	logic w_en_dpm;
	logic r_en_dpm;
	logic [$clog2(MEM_DEPTH)-1:0] w_addr_dpm;
	logic [$clog2(MEM_DEPTH)-1:0] r_addr_dpm;

	logic clk_en;
	
	logic w_en_spm;
	logic r_en_spm;
	logic [$clog2(MEM_DEPTH)-1:0] addr_spm;
	logic start_next_sample;
	
	filter_fsm#(.MEM_DEPTH(MEM_DEPTH))
		fsm(
		    .pi_clk(pi_clk),
		    .pi_sreset(pi_sreset),
			.pi_tvalid(pi_data.tvalid),
			.pi_tlast(pi_data.tlast),
			.po_tready(pi_data.tready),
			.pi_start_c_load(pi_start_c_load),
			.pi_filt_ord(pi_filt_ord),
			.po_tvalid(po_data.tvalid),
			.po_tlast(po_data.tlast),
			.pi_tready(po_data.tready),
			.po_w_en_dpm(w_en_dpm),
			.po_w_addr_dpm(w_addr_dpm),
			.po_r_addr_dpm(r_addr_dpm),
			.po_r_en_dpm(r_en_dpm),
			.po_w_en_spm(w_en_spm),
			.po_addr_spm(addr_spm),
			.po_r_en_spm(r_en_spm),
			.po_clk_en(clk_en),
			.po_mux_sel(mux_sel),
            .po_start_next_sample(start_next_sample),
            .po_lddone(po_lddone),
            .po_err(po_err)
			);
	
	logic [DATA_WIDTH-1:0] coeff_out;
	single_port_memory#(.DATA_WIDTH(DATA_WIDTH),
						.MEM_DEPTH(MEM_DEPTH))
		s_p_m(
			  .pi_clk(pi_clk),
			  .pi_sreset(pi_sreset),
			  .pi_data(pi_data.tdata),
			  .pi_w_en(w_en_spm),
			  .pi_r_en(r_en_spm),
			  .pi_addr(addr_spm),
			  .po_data(coeff_out)
			  );
	
	logic [DATA_WIDTH-1:0] sample_out;
	dual_port_memory#(.DATA_WIDTH(DATA_WIDTH),
					  .MEM_DEPTH(MEM_DEPTH))
		d_p_m(
			  .pi_clk(pi_clk),
			  .pi_sreset(pi_sreset),
			  .pi_data(pi_data.tdata),
			  .pi_w_en(w_en_dpm),
			  .pi_w_addr(w_addr_dpm),
			  .pi_r_addr(r_addr_dpm),
			  .pi_r_en(r_en_dpm),
			  .po_data(sample_out)
			  );
	
	logic [DATA_WIDTH-1:0] dpm2mult;		
	assign dpm2mult = (mux_sel == 0) ? 0 : sample_out;
	
	logic [2*DATA_WIDTH-1:0] accum_reg;
	
	always_ff @(posedge pi_clk)begin
		if (pi_sreset)begin
			accum_reg <= 0;
		end else begin
			if(clk_en)begin
				if (start_next_sample)
					accum_reg <= 0;
				else
					accum_reg <= accum_reg + signed'(coeff_out) * signed'(dpm2mult);
			end
		end
	end
				  
	round_and_clip#(.WIDTH(2*DATA_WIDTH),
	                .FINAL(DATA_WIDTH),
	                .SCALE(16))
		rac(
			.rac_in(accum_reg),
			.rac_out(po_data.tdata),
			.sat(po_filter_clip)
			);					
endmodule