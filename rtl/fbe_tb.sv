`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2020 11:28:21 AM
// Design Name: 
// Module Name: fbe_tb
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


module fbe_tb;
    
    parameter ECHO_IN_SEL_AND_INIT_COEFF = 9;
    parameter GAIN_C_GAIN_G = 13;
    parameter FDB_DELAY_FB_GAIN = 17;
    parameter LP_ORDER_GAIN = 21;
    parameter BP_ORDER_GAIN = 25;
    parameter HP_ORDER_GAIN = 29;
    
    parameter C_CFG_AXI_ADDR_WIDTH = 16;
    parameter C_CFG_AXI_DATA_WIDTH = 32;
    parameter C_IN_AXIS_TDATA_WIDTH = 16;
    parameter C_OUT_AXIS_TDATA_WIDTH = 16;
    parameter EQ_BAND_NUM = 3;
    parameter DATA_WIDTH = 16;
     
    logic pi_clk_s;
    logic pi_sreset_s;
     
    // signals of Axi Slave Bus Interface CFG_AXI
	logic cfg_axi_aresetn_s;
	logic [C_CFG_AXI_ADDR_WIDTH-1 : 0] cfg_axi_awaddr_s;
	logic [2 : 0] cfg_axi_awprot_s;
	logic cfg_axi_awvalid_s;
	logic cfg_axi_awready_s;
	logic [C_CFG_AXI_DATA_WIDTH-1 : 0] cfg_axi_wdata_s;
	logic [(C_CFG_AXI_DATA_WIDTH/8)-1 : 0] cfg_axi_wstrb_s;
    logic cfg_axi_wvalid_s;
    logic cfg_axi_wready_s;
	logic [1 : 0] cfg_axi_bresp_s;
	logic cfg_axi_bvalid_s;
	logic cfg_axi_bready_s;
    logic [C_CFG_AXI_ADDR_WIDTH-1 : 0] cfg_axi_araddr_s;
	logic [2 : 0] cfg_axi_arprot_s;
	logic cfg_axi_arvalid_s;
	logic cfg_axi_arready_s;
    logic [C_CFG_AXI_DATA_WIDTH-1 : 0] cfg_axi_rdata_s;
	logic [1 : 0] cfg_axi_rresp_s;
	logic cfg_axi_rvalid_s;
	logic cfg_axi_rready_s;

		// signals of Axi Slave Bus Interface IN_AXIS
	logic in_axis_aresetn_s;
	logic in_axis_tready_s;
	logic [C_IN_AXIS_TDATA_WIDTH-1 : 0] in_axis_tdata_s;
	logic [(C_IN_AXIS_TDATA_WIDTH/8)-1 : 0] in_axis_tstrb_s;
	logic in_axis_tlast_s;
	logic in_axis_tvalid_s;

		// signals of Axi Master Bus Interface OUT_AXIS
	logic out_axis_aresetn_s;
	logic out_axis_tvalid_s;
	logic [C_OUT_AXIS_TDATA_WIDTH-1 : 0] out_axis_tdata_s;
	logic [(C_OUT_AXIS_TDATA_WIDTH/8)-1 : 0] out_axis_tstrb_s;
	logic out_axis_tlast_s;
	logic out_axis_tready_s;
      
    
      
    stream_vif #(.DATA_WIDTH(DATA_WIDTH)) axi_in(pi_clk_s);
    stream_vif #(.DATA_WIDTH(DATA_WIDTH)) axi_out(pi_clk_s);
      
    register_write_aix_lite #(.C_CFG_AXI_ADDR_WIDTH(C_CFG_AXI_ADDR_WIDTH),
               .C_CFG_AXI_DATA_WIDTH(C_CFG_AXI_DATA_WIDTH),
               .C_IN_AXIS_TDATA_WIDTH (C_IN_AXIS_TDATA_WIDTH),
               .C_OUT_AXIS_TDATA_WIDTH (C_OUT_AXIS_TDATA_WIDTH)) axi_lite(pi_clk_s);
      
    axi_audio_processing_v1_0 #(.C_CFG_AXI_ADDR_WIDTH(C_CFG_AXI_ADDR_WIDTH),
                                  .C_CFG_AXI_DATA_WIDTH(C_CFG_AXI_DATA_WIDTH),
                                  .C_IN_AXIS_TDATA_WIDTH(C_IN_AXIS_TDATA_WIDTH),
                                  .C_OUT_AXIS_TDATA_WIDTH(C_OUT_AXIS_TDATA_WIDTH))
        axi_audio(
                  .pi_clk(pi_clk_s),
                  .pi_sreset(pi_sreset_s),
		          .cfg_axi_aclk(pi_clk_s),
		          .cfg_axi_aresetn(cfg_axi_aresetn_s),
		          .cfg_axi_awaddr(axi_lite.axi_awaddr),
		          .cfg_axi_awprot(axi_lite.axi_awprot),
		          .cfg_axi_awvalid(axi_lite.axi_awvalid),
		          .cfg_axi_awready(axi_lite.axi_awready),
		          .cfg_axi_wdata(axi_lite.axi_wdata),
		          .cfg_axi_wstrb(axi_lite.axi_wstrb),
	              .cfg_axi_wvalid(axi_lite.axi_wvalid),
		          .cfg_axi_wready(axi_lite.axi_wready),
		          .cfg_axi_bresp(axi_lite.axi_bresp),
		          .cfg_axi_bvalid(axi_lite.axi_bvalid),
		          .cfg_axi_bready(axi_lite.axi_bready),
		          .cfg_axi_araddr(axi_lite.axi_araddr),
		          .cfg_axi_arprot(axi_lite.axi_arprot),
		          .cfg_axi_arvalid(axi_lite.axi_arvalid),
		          .cfg_axi_arready(axi_lite.axi_arready),
		          .cfg_axi_rdata(axi_lite.axi_rdata),
		          .cfg_axi_rresp(axi_lite.axi_rresp),
		          .cfg_axi_rvalid(axi_lite.axi_rvalid),
		          .cfg_axi_rready(axi_lite.axi_rready),
		          .in_axis_aclk(pi_clk_s),
		          .in_axis_aresetn(in_axis_aresetn_s),
		          .in_axis_tready(axi_in.tready),
		          .in_axis_tdata(axi_in.tdata),
		          .in_axis_tstrb(in_axis_tstrb_s),
		          .in_axis_tlast(axi_in.tlast),
		          .in_axis_tvalid(axi_in.tvalid),
		          .out_axis_aclk(pi_clk_s),
		          .out_axis_aresetn(out_axis_aresetn_s),
		          .out_axis_tvalid(axi_out.tvalid),
		          .out_axis_tdata(axi_out.tdata),
		          //.out_axis_tstrb(out_axis_tstrb_s),
		          .out_axis_tlast(axi_out.tlast),
		          .out_axis_tready(axi_out.tready)
	              );
    int filt_ord_and_gain[3];
    
	int array_push[12] = '{16'hfa01,16'hcdab,16'had05,16'hb05f,16'h0a01,16'hcdab,16'had05,16'hb05f,16'h3,16'h1,16'h2,16'h3};
    int array_pull[12] = '{16'h007d,16'h00e4,16'h013b,16'h019a,16'h01a6,16'h0212,16'h026e,16'h02c7,16'h02ce,16'h02d4,16'h025d,16'h0273};
      
    int lp_filter_coeff[11] = '{16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff};
    int bp_filter_coeff[11] = '{16'h00ff,16'h00ff,16'h00ff,16'h00ff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff};
    int hp_filter_coeff[11] = '{16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff,16'h0fff};
      
    always begin
		pi_clk_s = 1;
		forever #10ns pi_clk_s = ~pi_clk_s;
	end     
    
    assign filt_ord_and_gain = '{32'h000a0111,32'h000a0111,32'h000a0111};
    assign cfg_axi_aresetn_s = ~pi_sreset_s;
    
	initial begin
        init_drivers();
        
        in_axis_tstrb_s = 1;
        in_axis_tdata_s = 16'h00;
        in_axis_tlast_s = 0;
        in_axis_tvalid_s = 0;
        pi_sreset_s = 1;
        #70
        pi_sreset_s = 0;
        
		//axi lite
        axi_lite.regisret_write(FDB_DELAY_FB_GAIN,32'h00020001);
        
		//filter order and gain in eq module
		for(int i = 0; i < EQ_BAND_NUM; i++)begin
        axi_lite.regisret_write(LP_ORDER_GAIN+(i*4),filt_ord_and_gain[i]);
        end
		
		//echo gain
		axi_lite.regisret_write(GAIN_C_GAIN_G,32'h0fff0fff);
		
		//lp filter coeff
		axi_lite.regisret_write(ECHO_IN_SEL_AND_INIT_COEFF,32'h0000008b);
		for(int i = 0; i < 11; i++)begin
		
			if(i!=10)begin
				axi_in.push(3, lp_filter_coeff[i], 1'b0);
			end else begin
				axi_in.push(3, lp_filter_coeff[i], 1'b1);
				axi_lite.regisret_write(ECHO_IN_SEL_AND_INIT_COEFF,32'h0000080b);
			end
        end
		
		//bp filter coeff
		axi_lite.regisret_write(ECHO_IN_SEL_AND_INIT_COEFF,32'h0000080b);
		for(int i = 0; i < 11; i++)begin
			if(i!=10)begin
				axi_in.push(3, bp_filter_coeff[i], 1'b0);
			end else begin
				axi_in.push(3, bp_filter_coeff[i], 1'b1);
				axi_lite.regisret_write(ECHO_IN_SEL_AND_INIT_COEFF,32'h0000800b);
			end
        end
		
		//hp filter coeff
		axi_lite.regisret_write(ECHO_IN_SEL_AND_INIT_COEFF,32'h0000800b);
        for(int i = 0; i < 11; i++)begin
			if(i!=10)begin
				axi_in.push(3, hp_filter_coeff[i], 1'b0);
			end else begin
				axi_in.push(3, hp_filter_coeff[i], 1'b1);
				axi_lite.regisret_write(ECHO_IN_SEL_AND_INIT_COEFF,32'h0000000b);
			end
        end
		
		
		
         run_inputs();
    end
    
    //axi stream and check  
    logic [DATA_WIDTH-1:0] output_result;
    logic output_tlast;
    
   task run_inputs();
        fork
            begin
                for(int i = 0; i < 12; i++)begin
					if(i<11)
						axi_in.push(3, array_push[i], 1'b0);
					else
						axi_in.push(4,array_push[i],1'b1);
				end    
            end
            begin
                for(int i = 0; i < 13; i++)begin
                    axi_out.pull(3, output_result, output_tlast);
                    if(output_result != array_pull[i])
                        $error("pulled %d is wrong expected %d sampled %d", i, array_pull[i], output_result);
                end
            end
        join
        $display("test pass");
 
    endtask
    
    task init_drivers();
        axi_out.init_slave();
        axi_in.init_master();
    endtask
endmodule
