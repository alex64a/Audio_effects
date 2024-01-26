`timescale 1ns / 1ps

module echo_module#(
    	parameter DATA_WIDTH=16,
    	parameter MEM_DEPTH = 4,
    	parameter ADDR_WIDTH =  $clog2(MEM_DEPTH)
    )
    (
    	input logic pi_clk,
    	input logic pi_sreset,
    
    	AXIS.slave pi_data,
	AXIS.master po_data,
	
	input logic [15:0] pi_feedback_delay,
	input logic [15:0] pi_gain_c,
	input logic [15:0] pi_gain_g,
	
	output logic po_echo_clip,
	output logic po_cmp_gain_clip,
	output logic po_fback_gain_clip,
	
	output logic po_wr2full,
	output logic po_rdempty
    );
   
    logic reg_en_s0;
    logic reg_en_s1;
    logic we_en;
    logic rd_en;
    logic sreset;
    logic mux_sel;
	
    fsm_echo#()
        fsm(
            .pi_clk(pi_clk),
            .pi_sreset(pi_sreset),
            .pi_feedback_delay(pi_feedback_delay),
            .pi_valid(pi_data.tvalid),
            .pi_tlast(pi_data.tlast),
            .po_ready(pi_data.tready),
            .po_tlast(po_data.tlast),
            .po_valid(po_data.tvalid),
            .pi_ready(po_data.tready),
            .po_clk_en_s0(reg_en_s0),
            .po_clk_en_s1(reg_en_s1),
            .po_we_en(we_en),
            .po_rd_en(rd_en),
            .po_sreset(sreset),
	    .po_mux_sel(mux_sel)
            );
   
    logic [2*(DATA_WIDTH-1):0] mult2reg_s0;
    assign mult2reg_s0 = signed'(pi_data.tdata) * signed'(pi_gain_c);
    
    logic [2*(DATA_WIDTH-1):0] reg_s0_2rac;
    always @(posedge pi_clk) begin
        if(reg_en_s0)
            reg_s0_2rac <= mult2reg_s0;   
    end
    
    logic [DATA_WIDTH-1:0] rac_s0_2add;
    round_and_clip#(.WIDTH(2*DATA_WIDTH-1),
                    .FINAL(DATA_WIDTH),
                    .SCALE(15))
             rac_s0(
                    .rac_in(reg_s0_2rac),
                    .rac_out(rac_s0_2add),
					.sat(po_cmp_gain_clip));
    
    logic [DATA_WIDTH:0] add2rac_s1;
    logic [DATA_WIDTH-1:0] rac_s2_2add; 
    assign add2rac_s1 = signed'(rac_s0_2add) + signed'(rac_s2_2add);
    
    logic [(DATA_WIDTH-1):0] rac_s1_2reg_s1;
    round_and_clip#(.WIDTH(DATA_WIDTH+1),
                    .FINAL(DATA_WIDTH),
                    .SCALE(1))
             rac_s1(
                    .rac_in(add2rac_s1),
                    .rac_out(rac_s1_2reg_s1),
					.sat(po_echo_clip));
                    
    logic [DATA_WIDTH-1:0] reg_s1_2fifo;
    always_ff @(posedge pi_clk) begin
        if(reg_en_s1)
            reg_s1_2fifo <= rac_s1_2reg_s1;   
    end
    
    logic [DATA_WIDTH-1:0] fifo2mux;
    fifo#(.DATA_WIDTH(DATA_WIDTH),
          .MEM_DEPTH(MEM_DEPTH),
          .ADDR_WIDTH(ADDR_WIDTH))
        fifo(
			 .pi_clk(pi_clk),
			 .pi_sreset(pi_sreset),
			 .pi_sreset_fsm(sreset),
             .pi_wr_en(we_en),
             .pi_rd_en(rd_en),
             .pi_data(reg_s1_2fifo),
             .po_data(fifo2mux),
             .po_wr2full(po_wr2full),
             .po_rdempty(po_rdempty)
             );
    
    logic [DATA_WIDTH-1:0] mux2mult; 
    always_comb begin
        case (mux_sel)
			1'b1 : mux2mult =  fifo2mux;
        default :  mux2mult = 0;
        endcase
    end
    
    logic [2*(DATA_WIDTH-1):0] mult2reg_s2;
    assign mult2reg_s2 = signed'(pi_gain_g) * signed'(mux2mult);
    
    logic [2*(DATA_WIDTH-1):0] reg_s2_2rac_s2;
    always_ff @(posedge pi_clk) begin
            reg_s2_2rac_s2 <= mult2reg_s2;   
    end
    
    round_and_clip#(.WIDTH(2*DATA_WIDTH-1),
                    .FINAL(DATA_WIDTH),
                    .SCALE(15))
             rac_2(
                    .rac_in(reg_s2_2rac_s2),
                    .rac_out(rac_s2_2add),
					.sat(po_fback_gain_clip));
    
    assign po_data.tdata =  reg_s1_2fifo;                        
endmodule
