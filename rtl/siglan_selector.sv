`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: siglan_selector
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

module signal_selector #(
        parameter DATA_WIDTH=16
        )
        (
			AXIS.slave pi_data,
			AXIS.slave pi_data_fb,
			AXIS.master po_data,
	       
			input logic [1:0] pi_echo_input_sel
        );
        
        typedef struct packed{
			logic [DATA_WIDTH-1:0] high;
			logic [DATA_WIDTH-1:0] mid;
			logic [DATA_WIDTH-1:0] low;
	   } pi_ss_fb;
	   
	    pi_ss_fb pi_ss_fb_in;
	    
	    assign pi_ss_fb_in = pi_data_fb.tdata;
        always_comb begin
            case (pi_echo_input_sel)
                2'b00 : begin
			po_data.tdata     = pi_data.tdata;
                        po_data.tvalid    = pi_data.tvalid;
                        po_data.tlast     = pi_data.tlast;
                        pi_data.tready    = po_data.tready;
                        pi_data_fb.tready = 1;              
                end
		2'b01 : begin
                        po_data.tdata     = pi_ss_fb_in.high;
                        po_data.tvalid    = pi_data_fb.tvalid;
                        po_data.tlast     = pi_data_fb.tlast;
                        pi_data_fb.tready = po_data.tready;
                        pi_data.tready    = 1;
                        
                end
		2'b10 : begin
                        po_data.tdata     = pi_ss_fb_in.mid;
                        po_data.tvalid    = pi_data_fb.tvalid;
                        po_data.tlast     = pi_data_fb.tlast;
                        pi_data_fb.tready = po_data.tready;
                        pi_data.tready    = 1;
                        
                end
		default: begin
                        po_data.tdata     = pi_ss_fb_in.low;
                        po_data.tvalid    = pi_data_fb.tvalid;
                        po_data.tlast     = pi_data_fb.tlast;
                        pi_data_fb.tready = po_data.tready;
                        pi_data.tready    = 1;
                        
                end
		endcase
	   end
endmodule
