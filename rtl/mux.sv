`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2020 01:27:50 PM
// Design Name: 
// Module Name: mux
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


module mux(
    input logic pi_coef_load,
    
    AXIS.slave pi_data_bc,
    AXIS.slave pi_data_fb,
	AXIS.master po_data
	
    );
    always_comb begin
        if(pi_coef_load)begin
            po_data.tdata = pi_data_fb.tdata;
            po_data.tlast = pi_data_fb.tlast;
            po_data.tvalid = pi_data_fb.tvalid;
            pi_data_fb.tready = po_data.tready;
            pi_data_bc.tready = 0;
        end else begin
            po_data.tdata = pi_data_bc.tdata;
            po_data.tlast = pi_data_bc.tlast;
            po_data.tvalid = pi_data_bc.tvalid;
            pi_data_bc.tready = po_data.tready;
            pi_data_fb.tready = 0;
        end
    end

endmodule
